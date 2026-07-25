import type { Server as SocketIOServer } from 'socket.io';
import { prisma } from '../utils/prisma';
import { DispatchService } from '../services/dispatch.service';
import { RoutingService } from '../services/routing.service';
import { NotificationService } from '../services/notification.service';

let timer: NodeJS.Timeout | null = null;
let workerRunning = false;

const DEFAULT_WORKER_INTERVAL_MS = 5000;
const DEFAULT_OFFER_TIMEOUT_SECONDS = 20;

async function getDispatchSettings() {
  const settings = await prisma.platformSetting.findMany({
    where: {
      key: {
        in: [
          'courierSearchRadiusKm',
          'courierCandidateLimit',
          'courierOfferTimeoutSeconds',
        ],
      },
    },
  });

  const map = new Map(
    settings.map((setting) => [
      setting.key,
      setting.value,
    ])
  );

  const parsedRadius = Number.parseFloat(
    map.get('courierSearchRadiusKm') ?? ''
  );

  const parsedLimit = Number.parseInt(
    map.get('courierCandidateLimit') ?? '',
    10
  );

  const parsedTimeout = Number.parseInt(
    map.get('courierOfferTimeoutSeconds') ?? '',
    10
  );

  return {
    searchRadiusKm:
      Number.isFinite(parsedRadius) &&
      parsedRadius > 0
        ? Math.min(parsedRadius, 100)
        : 10,

    candidateLimit:
      Number.isInteger(parsedLimit) &&
      parsedLimit > 0
        ? Math.min(parsedLimit, 20)
        : 5,

    offerTimeoutSeconds:
      Number.isInteger(parsedTimeout) &&
      parsedTimeout > 0
        ? Math.min(
            Math.max(parsedTimeout, 10),
            120
          )
        : DEFAULT_OFFER_TIMEOUT_SECONDS,
  };
}

async function emitCourierOffer(
  io: SocketIOServer,
  orderId: string,
  offer: {
    id: string;
    courierId: string;
    rank: number;
    expiresAt: Date | null;
  }
) {
  const order = await prisma.order.findUnique({
    where: {
      id: orderId,
    },
    include: {
      items: true,
      store: true,
      customer: {
        select: {
          id: true,
          name: true,
          phone: true,
        },
      },
    },
  });

  if (!order) {
    return;
  }

  io.to(`user_${offer.courierId}`).emit(
    'courier.offer_received',
    {
      ...order,
      _targeted: true,
      dispatchOfferId: offer.id,
      offerRank: offer.rank,
      offerExpiresAt: offer.expiresAt,
    }
  );

  try {
    await NotificationService.sendToUser({
      userId: offer.courierId,
      title: 'طلب توصيل جديد',
      body: `عندك طلب توصيل جديد #${order.orderNumber}`,
      data: {
        type: 'COURIER_OFFER',
        orderId: order.id,
        offerId: offer.id,
      },
      appType: 'COURIER',
    });
  } catch (error) {
    console.error(
      '[DispatchWorker] Courier notification failed:',
      error
    );
  }
}

async function rebuildQueue(
  orderId: string,
  searchRadiusKm: number,
  candidateLimit: number
): Promise<boolean> {
  const order = await prisma.order.findUnique({
    where: {
      id: orderId,
    },
    select: {
      id: true,
      status: true,
      courierId: true,
      store: {
        select: {
          latitude: true,
          longitude: true,
        },
      },
      dispatchOffers: {
        select: {
          courierId: true,
        },
      },
    },
  });

  if (
    !order ||
    order.status !== 'SEARCHING_COURIER' ||
    order.courierId !== null
  ) {
    return false;
  }

  const storeLat = order.store.latitude;
  const storeLng = order.store.longitude;

  if (
    storeLat == null ||
    storeLng == null ||
    !Number.isFinite(storeLat) ||
    !Number.isFinite(storeLng) ||
    (storeLat === 0 && storeLng === 0)
  ) {
    return false;
  }

  // Do not immediately offer the same order again
  // to couriers who already received an offer.
  const attemptedCourierIds = [
    ...new Set(
      order.dispatchOffers.map(
        (offer) => offer.courierId
      )
    ),
  ];

  const availableCouriers =
    await prisma.courierProfile.findMany({
      where: {
        verificationStatus: 'APPROVED',
        status: 'AVAILABLE',
        isOnline: true,
        currentLatitude: {
          not: null,
        },
        currentLongitude: {
          not: null,
        },
        userId:
          attemptedCourierIds.length > 0
            ? {
                notIn: attemptedCourierIds,
              }
            : undefined,
      },
      select: {
        userId: true,
        currentLatitude: true,
        currentLongitude: true,
      },
    });

  const candidates = availableCouriers
    .map((courier) => {
      const lat = courier.currentLatitude as number;
      const lng = courier.currentLongitude as number;

      const distanceKm =
        RoutingService.haversineDistance(
          {
            latitude: storeLat,
            longitude: storeLng,
          },
          {
            latitude: lat,
            longitude: lng,
          }
        );

      return {
        courierId: courier.userId,
        lat,
        lng,
        distanceKm,
      };
    })
    .filter(
      (courier) =>
        courier.distanceKm <= searchRadiusKm
    );

  if (candidates.length === 0) {
    return false;
  }

  const rankedCouriers =
    await RoutingService.rankCouriers(
      candidates,
      storeLat,
      storeLng,
      candidateLimit
    );

  if (rankedCouriers.length === 0) {
    return false;
  }

  await DispatchService.createOfferQueue(
    orderId,
    rankedCouriers
  );

  return true;
}

async function processOrder(
  io: SocketIOServer,
  orderId: string,
  settings: Awaited<
    ReturnType<typeof getDispatchSettings>
  >
) {
  let activation =
    await DispatchService.activateNextOffer(
      orderId,
      settings.offerTimeoutSeconds
    );

  // Queue exhausted: look for newly available couriers.
  if (!activation.offer) {
    const rebuilt = await rebuildQueue(
      orderId,
      settings.searchRadiusKm,
      settings.candidateLimit
    );

    if (rebuilt) {
      activation =
        await DispatchService.activateNextOffer(
          orderId,
          settings.offerTimeoutSeconds
        );
    }
  }

  if (
    activation.activated &&
    activation.offer
  ) {
    await emitCourierOffer(
      io,
      orderId,
      activation.offer
    );
  }
}

async function tick(io: SocketIOServer) {
  if (workerRunning) {
    return;
  }

  workerRunning = true;

  try {
    const settings =
      await getDispatchSettings();

    const needingNext =
      await DispatchService.findOrdersNeedingNextOffer();

    // Also recover SEARCHING_COURIER orders that currently
    // have no queued or active offer at all.
    const stalledOrders =
      await prisma.order.findMany({
        where: {
          status: 'SEARCHING_COURIER',
          courierId: null,
          dispatchOffers: {
            none: {
              status: {
                in: ['QUEUED', 'OFFERED'],
              },
            },
          },
        },
        select: {
          id: true,
        },
      });

    const orderIds = [
      ...new Set([
        ...needingNext,
        ...stalledOrders.map(
          (order) => order.id
        ),
      ]),
    ];

    for (const orderId of orderIds) {
      try {
        await processOrder(
          io,
          orderId,
          settings
        );
      } catch (error) {
        console.error(
          `[DispatchWorker] Order ${orderId} failed:`,
          error
        );
      }
    }
  } catch (error) {
    console.error(
      '[DispatchWorker] Tick failed:',
      error
    );
  } finally {
    workerRunning = false;
  }
}

export function startDispatchWorker(
  io: SocketIOServer
) {
  if (timer) {
    return;
  }

  console.log(
    '[DispatchWorker] Started'
  );

  // Recover expired/stalled offers immediately after restart.
  void tick(io);

  timer = setInterval(() => {
    void tick(io);
  }, DEFAULT_WORKER_INTERVAL_MS);

  // Do not keep Node alive only because of this timer.
  timer.unref();
}

export function stopDispatchWorker() {
  if (!timer) {
    return;
  }

  clearInterval(timer);
  timer = null;

  console.log(
    '[DispatchWorker] Stopped'
  );
}