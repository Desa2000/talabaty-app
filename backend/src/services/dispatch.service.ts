import { prisma } from '../utils/prisma';

export class DispatchService {
  static async createOfferQueue(
    orderId: string,
    rankedCouriers: Array<{
      courierId: string;
      distanceMeters: number;
      durationSeconds: number;
    }>
  ) {
    const seen = new Set<string>();

    const uniqueRanked = rankedCouriers
      .filter((courier) => {
        if (seen.has(courier.courierId)) return false;
        seen.add(courier.courierId);
        return true;
      })
      .slice(0, 20);

    return prisma.$transaction(async (tx) => {
      await tx.$queryRaw`
        SELECT pg_advisory_xact_lock(
          hashtext(${`dispatch:${orderId}`})
        )
      `;

      const order = await tx.order.findUnique({
        where: { id: orderId },
        select: {
          id: true,
          status: true,
          courierId: true,
        },
      });

      if (!order) {
        throw new Error('ORDER_NOT_FOUND');
      }

      if (
        order.status !== 'SEARCHING_COURIER' ||
        order.courierId !== null
      ) {
        throw new Error('ORDER_NOT_SEARCHING');
      }

      // Another worker may already have created or activated
      // the queue while this worker was waiting for the lock.
      // Never cancel a live queue here.
      const existingQueue =
        await tx.courierDispatchOffer.findMany({
          where: {
            orderId,
            status: {
              in: ['QUEUED', 'OFFERED'],
            },
          },
          orderBy: {
            rank: 'asc',
          },
        });

      if (existingQueue.length > 0) {
        return existingQueue;
      }

      if (uniqueRanked.length === 0) {
        return [];
      }

      // Preserve historical EXPIRED / REJECTED / CANCELLED offers.
      // A courier must not be silently re-offered through an upsert.
      await tx.courierDispatchOffer.createMany({
        data: uniqueRanked.map((courier, index) => ({
          orderId,
          courierId: courier.courierId,
          rank: index + 1,
          status: 'QUEUED',
          distanceMeters: courier.distanceMeters,
          durationSeconds: courier.durationSeconds,
        })),
        skipDuplicates: true,
      });

      return tx.courierDispatchOffer.findMany({
        where: {
          orderId,
          status: 'QUEUED',
        },
        orderBy: {
          rank: 'asc',
        },
      });
    });
  }
  static async activateNextOffer(
    orderId: string,
    timeoutSeconds = 20
  ) {
    const safeTimeout = Math.min(
      Math.max(Math.floor(timeoutSeconds), 10),
      120
    );

    return prisma.$transaction(async (tx) => {
      await tx.$queryRaw`
        SELECT pg_advisory_xact_lock(
          hashtext(${`dispatch:${orderId}`})
        )
      `;

      const order = await tx.order.findUnique({
        where: { id: orderId },
        select: {
          id: true,
          status: true,
          courierId: true,
        },
      });

      if (!order) {
        throw new Error('ORDER_NOT_FOUND');
      }

      if (
        order.status !== 'SEARCHING_COURIER' ||
        order.courierId !== null
      ) {
        return {
          offer: null,
          activated: false,
        };
      }

      const now = new Date();

      await tx.courierDispatchOffer.updateMany({
        where: {
          orderId,
          status: 'OFFERED',
          OR: [
            { expiresAt: null },
            {
              expiresAt: {
                lte: now,
              },
            },
          ],
        },
        data: {
          status: 'EXPIRED',
          respondedAt: now,
        },
      });

      const activeOffer =
        await tx.courierDispatchOffer.findFirst({
          where: {
            orderId,
            status: 'OFFERED',
            expiresAt: {
              gt: now,
            },
          },
          orderBy: {
            rank: 'asc',
          },
        });

      if (activeOffer) {
        return {
          offer: activeOffer,
          activated: false,
        };
      }

      while (true) {
        const next =
          await tx.courierDispatchOffer.findFirst({
            where: {
              orderId,
              status: 'QUEUED',
            },
            orderBy: {
              rank: 'asc',
            },
          });

        if (!next) {
          return {
            offer: null,
            activated: false,
          };
        }

        const courier =
          await tx.courierProfile.findUnique({
            where: {
              userId: next.courierId,
            },
            select: {
              verificationStatus: true,
              status: true,
              isOnline: true,
            },
          });

        const eligible =
          courier?.verificationStatus === 'APPROVED' &&
          courier.status === 'AVAILABLE' &&
          courier.isOnline === true;

        if (!eligible) {
          await tx.courierDispatchOffer.updateMany({
            where: {
              id: next.id,
              status: 'QUEUED',
            },
            data: {
              status: 'EXPIRED',
              respondedAt: now,
            },
          });

          continue;
        }

        const expiresAt = new Date(
          now.getTime() + safeTimeout * 1000
        );

        const claim =
          await tx.courierDispatchOffer.updateMany({
            where: {
              id: next.id,
              status: 'QUEUED',
            },
            data: {
              status: 'OFFERED',
              offeredAt: now,
              expiresAt,
              respondedAt: null,
            },
          });

        if (claim.count !== 1) {
          continue;
        }

        const offer =
          await tx.courierDispatchOffer.findUnique({
            where: {
              id: next.id,
            },
          });

        return {
          offer,
          activated: true,
        };
      }
    });
  }

  static async findOrdersNeedingNextOffer() {
    const now = new Date();

    const orders = await prisma.order.findMany({
      where: {
        status: 'SEARCHING_COURIER',
        courierId: null,
        AND: [
          {
            dispatchOffers: {
              none: {
                status: 'OFFERED',
                expiresAt: {
                  gt: now,
                },
              },
            },
          },
          {
            OR: [
              {
                dispatchOffers: {
                  some: {
                    status: 'QUEUED',
                  },
                },
              },
              {
                dispatchOffers: {
                  some: {
                    status: 'OFFERED',
                    OR: [
                      { expiresAt: null },
                      {
                        expiresAt: {
                          lte: now,
                        },
                      },
                    ],
                  },
                },
              },
            ],
          },
        ],
      },
      select: {
        id: true,
      },
    });

    return orders.map((order) => order.id);
  }

  static async getActiveOffer(
    orderId: string,
    courierId: string
  ) {
    return prisma.courierDispatchOffer.findFirst({
      where: {
        orderId,
        courierId,
        status: 'OFFERED',
        expiresAt: {
          gt: new Date(),
        },
      },
    });
  }
}