import { Request, Response } from 'express';
import { z } from 'zod';
import { prisma } from '../../utils/prisma';
import { AuthenticatedRequest } from '../../middleware/auth.middleware';
import { io } from '../../server';
import { RoutingService } from '../../services/routing.service';
import { NotificationService } from '../../services/notification.service';
import { DispatchService } from '../../services/dispatch.service';

function calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 6371; // Radius of Earth in KM
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

// Helper to generate readable order number
function generateOrderNumber(): string {
  const randomNum = Math.floor(1000 + Math.random() * 9000);
  return `TLB-${Date.now().toString().slice(-4)}${randomNum}`;
}

const createOrderSchema = z.object({
  storeId: z.string().min(1),
  items: z.array(
    z.object({
      productId: z.string().min(1),
      quantity: z.number().int().positive(),
    })
  ).min(1),
  deliveryAddress: z.string().min(3),
  deliveryLatitude: z.number(),
  deliveryLongitude: z.number(),
  paymentMethod: z.enum(['CASH', 'BANKAK']).default('CASH'),
  customerNotes: z.string().optional(),
  bankakProofImage: z.string().optional(),
  bankakTxnRef: z.string().optional(),
});

export const createOrder = async (req: Request, res: Response) => {
  try {
    const userId = (req as AuthenticatedRequest).user?.id;
    if (!userId) {
      return res.status(401).json({ error: 'غير مصرح به، يرجى تسجيل الدخول' });
    }

    const validated = createOrderSchema.parse(req.body);

    const store = await prisma.store.findUnique({
      where: { id: validated.storeId },
    });

    if (!store || !store.isActive || !store.isOpen) {
      return res.status(400).json({ error: 'المتجر المطلوب مغلق أو غير متاح حالياً' });
    }

    // Fetch DB products and recalculate prices authoritatively
    const productIds = validated.items.map((i) => i.productId);
    const uniqueProductIds = [...new Set(productIds)];
    const dbProducts = await prisma.product.findMany({
      where: {
        id: { in: uniqueProductIds },
        storeId: validated.storeId,
        isAvailable: true,
      },
    });

    if (dbProducts.length !== uniqueProductIds.length) {
      return res.status(400).json({
        error: 'بعض المنتجات في الطلب غير متوفرة حالياً',
        code: 'PRODUCT_UNAVAILABLE',
      });
    }

    let subtotal = 0;
    const orderItemsData = validated.items.map((item) => {
      const dbProduct = dbProducts.find((p) => p.id === item.productId)!;
      const unitPrice = dbProduct.discountPrice && dbProduct.discountPrice > 0 ? dbProduct.discountPrice : dbProduct.price;
      const itemSubtotal = unitPrice * item.quantity;
      subtotal += itemSubtotal;

      return {
        productId: dbProduct.id,
        productName: dbProduct.nameAr,
        unitPrice,
        quantity: item.quantity,
        subtotal: itemSubtotal,
      };
    });

    const deliveryFee = store.deliveryFee ?? 500.0;

    // Application fee is controlled by Super Admin through PlatformSetting.
    // Safe default: disabled with a zero fee.
    const applicationFeeSettings = await prisma.platformSetting.findMany({
      where: {
        key: {
          in: [
            'applicationFeeEnabled',
            'applicationFeeType',
            'applicationFeeValue',
          ],
        },
      },
    });

    const feeSettings = new Map(
      applicationFeeSettings.map((setting) => [setting.key, setting.value])
    );

    const applicationFeeEnabled =
      (feeSettings.get('applicationFeeEnabled') ?? 'false').toLowerCase() === 'true';

    const applicationFeeType =
      (feeSettings.get('applicationFeeType') ?? 'FIXED').toUpperCase();

    const parsedFeeValue = Number.parseFloat(
      feeSettings.get('applicationFeeValue') ?? '0'
    );

    const applicationFeeValue =
      Number.isFinite(parsedFeeValue) && parsedFeeValue > 0
        ? parsedFeeValue
        : 0;

    let applicationFee = 0;

    if (applicationFeeEnabled) {
      if (applicationFeeType === 'PERCENT') {
        const safePercentage = Math.min(applicationFeeValue, 100);
        applicationFee = subtotal * (safePercentage / 100);
      } else if (applicationFeeType === 'FIXED') {
        applicationFee = applicationFeeValue;
      }
    }

    applicationFee =
      Math.round(Math.max(0, applicationFee) * 100) / 100;

    const discount = 0.0;

    const total =
      Math.round(
        Math.max(
          0,
          subtotal + deliveryFee + applicationFee - discount
        ) * 100
      ) / 100;

    const orderNumber = generateOrderNumber();

    const paymentStatus = validated.paymentMethod === 'BANKAK' ? 'BANKAK_PENDING' : 'UNPAID';

    // Execute atomic creation transaction
    const order = await prisma.$transaction(async (tx) => {
      const newOrder = await tx.order.create({
        data: {
          orderNumber,
          customerId: userId,
          storeId: store.id,
          status: 'PENDING_MERCHANT',
          subtotal,
          deliveryFee,
          applicationFee,
          discount,
          total,
          paymentMethod: validated.paymentMethod,
          paymentStatus,
          deliveryAddress: validated.deliveryAddress,
          deliveryLatitude: validated.deliveryLatitude,
          deliveryLongitude: validated.deliveryLongitude,
          customerNotes: validated.customerNotes,
          bankakProofImage: validated.bankakProofImage,
          bankakTxnRef: validated.bankakTxnRef,
          items: {
            create: orderItemsData,
          },
          statusHistory: {
            create: {
              toStatus: 'PENDING_MERCHANT',
              actorType: 'CUSTOMER',
              actorId: userId,
              note: 'تم إرسال الطلب بواسطة العميل',
            },
          },
        },
        include: {
          items: true,
          store: {
            include: { merchant: true },
          },
          customer: {
            select: { id: true, name: true, phone: true },
          },
        },
      });

      return newOrder;
    });

    // Real-Time Socket Emission & Push Notification
    try {
      io.to(`user_${userId}`).emit('order.created', order);
      io.to('admins').emit('order.created', order);

      // Gate Bankak orders until verified by admin/accounting
      if (validated.paymentMethod !== 'BANKAK') {
        io.to(`store_${store.id}`).emit('order.created', order);

        const merchantUserId = order.store?.merchant?.userId;
        if (merchantUserId) {
          NotificationService.sendToUser({
            userId: merchantUserId,
            title: 'طلب جديد 📦',
            body: `لديك طلب جديد #${order.orderNumber}`,
            data: { type: 'ORDER_CREATED', orderId: order.id },
            appType: 'MERCHANT',
          });
        }
      }
    } catch (e) {
      console.error('Socket emission or notification error:', e);
    }

    return res.status(201).json(order);
  } catch (error: any) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'بيانات الطلب غير صالحة', details: error.errors });
    }
    return res.status(500).json({ error: error.message || 'حدث خطأ أثناء إنشاء الطلب' });
  }
};

export const getMyOrders = async (req: Request, res: Response) => {
  try {
    const user = (req as AuthenticatedRequest).user;
    if (!user) {
      return res.status(401).json({ error: 'غير مصرح به' });
    }

    let whereClause: any = {};

    if (user.role === 'CUSTOMER') {
      whereClause.customerId = user.id;
    } else if (user.role === 'MERCHANT') {
      const merchantProfile = await prisma.merchantProfile.findUnique({
        where: { userId: user.id },
        include: { stores: true },
      });
      if (!merchantProfile) {
        return res.status(403).json({ error: 'حساب تاجر غير موجود' });
      }
      const storeIds = merchantProfile.stores.map((s) => s.id);
      whereClause.AND = [
        { storeId: { in: storeIds } },
        {
          OR: [
            { paymentMethod: { not: 'BANKAK' } },
            { paymentStatus: 'BANKAK_VERIFIED' },
          ],
        },
      ];
    } else if (user.role === 'COURIER') {
      const now = new Date();

      // Courier may only see:
      // 1. Orders already assigned to this courier.
      // 2. A searching order for which this courier currently holds
      //    a live targeted dispatch offer.
      whereClause.OR = [
        {
          courierId: user.id,
        },
        {
          status: 'SEARCHING_COURIER',
          courierId: null,
          dispatchOffers: {
            some: {
              courierId: user.id,
              status: 'OFFERED',
              expiresAt: {
                gt: now,
              },
            },
          },
        },
      ];
    }

    const orders = await prisma.order.findMany({
      where: whereClause,
      include: {
        items: true,
        store: true,
        customer: { select: { id: true, name: true, phone: true } },
        courier: { select: { id: true, name: true, phone: true } },

        // Only the authenticated courier's currently-live offer can
        // be exposed. For every other role this relation will be empty.
        dispatchOffers: {
          where: {
            courierId: user.id,
            status: 'OFFERED',
            expiresAt: {
              gt: new Date(),
            },
          },
          select: {
            id: true,
            rank: true,
            expiresAt: true,
          },
          orderBy: {
            rank: 'asc',
          },
          take: 1,
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    // Never expose the internal dispatchOffers relation directly.
    // Courier receives only the metadata required by the mobile app.
    if (user.role === 'COURIER') {
      const courierOrders = orders.map(
        ({ dispatchOffers, ...order }) => {
          const activeOffer = dispatchOffers[0];

          return {
            ...order,
            dispatchOfferId: activeOffer?.id ?? null,
            offerRank: activeOffer?.rank ?? null,
            offerExpiresAt: activeOffer?.expiresAt ?? null,
            _targeted: Boolean(activeOffer),
          };
        }
      );

      return res.json(courierOrders);
    }

    const sanitizedOrders = orders.map(
      ({ dispatchOffers, ...order }) => order
    );

    return res.json(sanitizedOrders);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'حدث خطأ أثناء جلب الطلبات' });
  }
};

export const getOrderById = async (req: Request, res: Response) => {
  try {
    const user = (req as AuthenticatedRequest).user;
    const { id } = req.params;

    if (!user) {
      return res.status(401).json({ error: 'غير مصرح به، يرجى تسجيل الدخول' });
    }

    const order = await prisma.order.findUnique({
      where: { id },
      include: {
        items: true,
        store: { include: { merchant: { select: { userId: true } } } },
        customer: { select: { id: true, name: true, phone: true } },
        courier: {
          select: {
            id: true,
            name: true,
            phone: true,
            courierProfile: {
              select: {
                vehicleType: true,
                currentLatitude: true,
                currentLongitude: true,
              },
            },
          },
        },
        statusHistory: { orderBy: { timestamp: 'asc' } },
        locationLogs: { orderBy: { createdAt: 'desc' }, take: 1 },
        dispatchOffers: {
          where: {
            courierId: user.id,
            status: 'OFFERED',
            expiresAt: { gt: new Date() },
          },
          select: { id: true, rank: true, expiresAt: true },
          take: 1,
        },
      },
    });

    if (!order) {
      return res.status(404).json({ error: 'الطلب غير موجود' });
    }

    const isAdmin = ['SUPER_ADMIN', 'ADMIN', 'OPERATIONS', 'FINANCE', 'SUPPORT'].includes(user.role);
    const isCustomer = user.role === 'CUSTOMER' && order.customerId === user.id;
    const isMerchant = user.role === 'MERCHANT' && order.store.merchant.userId === user.id;
    const isAssignedCourier = user.role === 'COURIER' && order.courierId === user.id;
    const hasLiveOffer = user.role === 'COURIER' && order.dispatchOffers.length > 0;

    if (!isAdmin && !isCustomer && !isMerchant && !isAssignedCourier && !hasLiveOffer) {
      return res.status(403).json({ error: 'غير مصرح لك بعرض هذا الطلب' });
    }

    const {
      dispatchOffers,
      store: storeWithMerchant,
      ...orderWithoutInternalRelations
    } = order;
    const { merchant: _merchantOwner, ...safeStore } = storeWithMerchant;
    const safeOrder = { ...orderWithoutInternalRelations, store: safeStore };

    if (user.role === 'COURIER' && hasLiveOffer && !isAssignedCourier) {
      return res.json({
        ...safeOrder,
        deliveryAddress: null,
        deliveryLatitude: null,
        deliveryLongitude: null,
        customer: {
          id: safeOrder.customer.id,
          name: safeOrder.customer.name,
        },
        courier: null,
        locationLogs: [],
        dispatchOfferId: dispatchOffers[0]?.id ?? null,
        offerRank: dispatchOffers[0]?.rank ?? null,
        offerExpiresAt: dispatchOffers[0]?.expiresAt ?? null,
        _targeted: true,
      });
    }

    return res.json(
      user.role === 'COURIER'
        ? {
            ...safeOrder,
            dispatchOfferId: dispatchOffers[0]?.id ?? null,
            offerRank: dispatchOffers[0]?.rank ?? null,
            offerExpiresAt: dispatchOffers[0]?.expiresAt ?? null,
            _targeted: dispatchOffers.length > 0,
          }
        : safeOrder
    );
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل في جلب تفاصيل الطلب' });
  }
};

// MERCHANT ACTIONS
export const merchantAcceptOrder = async (req: Request, res: Response) => {
  try {
    const userId = (req as AuthenticatedRequest).user?.id;
    const { id } = req.params;

    const order = await prisma.order.findUnique({
      where: { id },
      include: { store: { include: { merchant: true } } },
    });

    if (!order || order.store.merchant.userId !== userId) {
      return res.status(403).json({ error: 'غير مصرح للتاجر بتعديل هذا الطلب' });
    }

    if (
      order.paymentMethod === 'BANKAK' &&
      order.paymentStatus !== 'BANKAK_VERIFIED'
    ) {
      return res.status(409).json({
        error: 'طلب بنكك ما زال في انتظار تأكيد الدفع',
        code: 'BANKAK_NOT_VERIFIED',
      });
    }
    if (order.status !== 'PENDING_MERCHANT') {
      return res.status(400).json({ error: `لا يمكن قبول طلب بحالة ${order.status}` });
    }

    const updated = await prisma.order.update({
      where: { id },
      data: {
        status: 'MERCHANT_ACCEPTED',
        statusHistory: {
          create: {
            fromStatus: 'PENDING_MERCHANT',
            toStatus: 'MERCHANT_ACCEPTED',
            actorType: 'MERCHANT',
            actorId: userId!,
            note: 'تم قبول الطلب بواسطة التاجر',
          },
        },
      },
      include: { items: true, store: true, customer: true },
    });

    io.to(`order_${id}`).emit('order.status_updated', updated);
    io.to(`user_${order.customerId}`).emit('order.merchant_accepted', updated);

    return res.json(updated);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل قبول الطلب' });
  }
};

export const merchantRejectOrder = async (req: Request, res: Response) => {
  try {
    const userId = (req as AuthenticatedRequest).user?.id;
    const { id } = req.params;
    const { note } = req.body;

    const order = await prisma.order.findUnique({
      where: { id },
      include: { store: { include: { merchant: true } } },
    });

    if (!order || order.store.merchant.userId !== userId) {
      return res.status(403).json({ error: 'غير مصرح للتاجر بتعديل هذا الطلب' });
    }

    if (
      order.paymentMethod === 'BANKAK' &&
      order.paymentStatus !== 'BANKAK_VERIFIED'
    ) {
      return res.status(409).json({
        error: 'طلب بنكك ما زال في انتظار تأكيد الدفع',
        code: 'BANKAK_NOT_VERIFIED',
      });
    }
    if (order.status !== 'PENDING_MERCHANT') {
      return res.status(400).json({ error: 'لا يمكن رفض طلب تم إعداده أو معالجته مسبقاً' });
    }

    const updated = await prisma.order.update({
      where: { id },
      data: {
        status: 'MERCHANT_REJECTED',
        merchantNotes: note || 'تم اعتذار المتجر عن قبول الطلب حالياً',
        statusHistory: {
          create: {
            fromStatus: 'PENDING_MERCHANT',
            toStatus: 'MERCHANT_REJECTED',
            actorType: 'MERCHANT',
            actorId: userId!,
            note: note || 'تم رفض الطلب بواسطة التاجر',
          },
        },
      },
      include: { items: true, store: true },
    });

    io.to(`order_${id}`).emit('order.status_updated', updated);
    io.to(`user_${order.customerId}`).emit('order.rejected', updated);

    return res.json(updated);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل رفض الطلب' });
  }
};

export const merchantPreparing = async (req: Request, res: Response) => {
  try {
    const userId = (req as AuthenticatedRequest).user?.id;
    const { id } = req.params;

    const order = await prisma.order.findUnique({
      where: { id },
      include: { store: { include: { merchant: true } } },
    });

    if (!order || order.store.merchant.userId !== userId) {
      return res.status(403).json({ error: 'غير مصرح للتاجر' });
    }

    if (
      order.paymentMethod === 'BANKAK' &&
      order.paymentStatus !== 'BANKAK_VERIFIED'
    ) {
      return res.status(409).json({
        error: 'طلب بنكك ما زال في انتظار تأكيد الدفع',
        code: 'BANKAK_NOT_VERIFIED',
      });
    }
    if (order.status !== 'MERCHANT_ACCEPTED') {
      return res.status(400).json({ error: 'يجب قبول الطلب أولاً قبل بدء التجهيز' });
    }

    const updated = await prisma.order.update({
      where: { id },
      data: {
        status: 'PREPARING',
        statusHistory: {
          create: {
            fromStatus: 'MERCHANT_ACCEPTED',
            toStatus: 'PREPARING',
            actorType: 'MERCHANT',
            actorId: userId!,
            note: 'بدأ المتجر في تحضير الطلب',
          },
        },
      },
      include: { items: true, store: true },
    });

    io.to(`order_${id}`).emit('order.status_updated', updated);
    io.to(`user_${order.customerId}`).emit('order.preparing', updated);

    return res.json(updated);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل بدء التجهيز' });
  }
};

export const merchantReadyForPickup = async (req: Request, res: Response) => {
  try {
    const userId = (req as AuthenticatedRequest).user?.id;
    const { id } = req.params;

    const order = await prisma.order.findUnique({
      where: { id },
      include: { store: { include: { merchant: true } } },
    });

    if (!order || order.store.merchant.userId !== userId) {
      return res.status(403).json({ error: 'غير مصرح للتاجر' });
    }

    if (order.status !== 'PREPARING' && order.status !== 'MERCHANT_ACCEPTED') {
      return res.status(400).json({
        error: 'حالة الطلب الحالية لا تسمح بتقديمه كجاهز للاستلام',
      });
    }

    // Bankak orders must never enter dispatch before payment verification.
    if (
      order.paymentMethod === 'BANKAK' &&
      order.paymentStatus !== 'BANKAK_VERIFIED'
    ) {
      return res.status(409).json({
        error: 'طلب بنكك ما زال في انتظار تأكيد الدفع',
        code: 'BANKAK_NOT_VERIFIED',
      });
    }

    // Validate store coordinates BEFORE changing the order status.
    const storeLat = order.store.latitude;
    const storeLng = order.store.longitude;

    if (
      storeLat == null ||
      storeLng == null ||
      !Number.isFinite(storeLat) ||
      !Number.isFinite(storeLng) ||
      (storeLat === 0 && storeLng === 0)
    ) {
      console.error(
        `[Dispatch Error] Store ${order.store.id} missing valid location coordinates (lat: ${storeLat}, lng: ${storeLng}).`
      );

      return res.status(400).json({
        error: 'موقع المتجر غير مكتمل على الخريطة. يرجى ضبط موقع المتجر في إعدادات المتجر.',
        code: 'STORE_LOCATION_INVALID',
      });
    }

    // Atomic state transition. If the status changed concurrently, do not
    // create a stale history record.
    const updated = await prisma.$transaction(async (tx) => {
      const transition = await tx.order.updateMany({
        where: {
          id,
          status: order.status,
        },
        data: {
          status: 'SEARCHING_COURIER',
        },
      });

      if (transition.count !== 1) {
        throw new Error('ORDER_STATE_CHANGED');
      }

      return tx.order.update({
        where: { id },
        data: {
          statusHistory: {
            create: {
              fromStatus: order.status,
              toStatus: 'SEARCHING_COURIER',
              actorType: 'MERCHANT',
              actorId: userId!,
              note: 'الطلب جاهز للاستلام وجاري البحث عن مندوب توصيل',
            },
          },
        },
        include: {
          items: true,
          store: true,
        },
      });
    });

    io.to(`order_${id}`).emit('order.status_updated', updated);

    // Persistent ranked courier dispatch.
    // The queue and expiry timestamps are stored in PostgreSQL.
    try {
      const availableCouriers = await prisma.courierProfile.findMany({
        where: {
          verificationStatus: 'APPROVED',
          status: 'AVAILABLE',
          isOnline: true,
          currentLatitude: { not: null },
          currentLongitude: { not: null },
        },
        select: {
          userId: true,
          currentLatitude: true,
          currentLongitude: true,
        },
      });

      if (availableCouriers.length > 0) {
        const [radiusSetting, limitSetting, timeoutSetting] =
          await Promise.all([
            prisma.platformSetting.findUnique({
              where: { key: 'courierSearchRadiusKm' },
            }),
            prisma.platformSetting.findUnique({
              where: { key: 'courierCandidateLimit' },
            }),
            prisma.platformSetting.findUnique({
              where: { key: 'courierOfferTimeoutSeconds' },
            }),
          ]);

        const parsedRadius = Number.parseFloat(
          radiusSetting?.value ?? ''
        );

        const parsedLimit = Number.parseInt(
          limitSetting?.value ?? '',
          10
        );

        const parsedTimeout = Number.parseInt(
          timeoutSetting?.value ?? '',
          10
        );

        const searchRadiusKm =
          Number.isFinite(parsedRadius) && parsedRadius > 0
            ? Math.min(parsedRadius, 100)
            : 10;

        const candidateLimit =
          Number.isInteger(parsedLimit) && parsedLimit > 0
            ? Math.min(parsedLimit, 20)
            : 5;

        const offerTimeoutSeconds =
          Number.isInteger(parsedTimeout) && parsedTimeout > 0
            ? Math.min(Math.max(parsedTimeout, 10), 120)
            : 20;

        const candidates = availableCouriers
          .map((courier) => ({
            courierId: courier.userId,
            lat: courier.currentLatitude as number,
            lng: courier.currentLongitude as number,
            distanceKm: calculateDistance(
              storeLat,
              storeLng,
              courier.currentLatitude as number,
              courier.currentLongitude as number
            ),
          }))
          .filter(
            (courier) =>
              courier.distanceKm <= searchRadiusKm
          );

        if (candidates.length > 0) {
          const rankedCouriers =
            await RoutingService.rankCouriers(
              candidates,
              storeLat,
              storeLng,
              candidateLimit
            );

          await DispatchService.createOfferQueue(
            id,
            rankedCouriers
          );

          const activation =
            await DispatchService.activateNextOffer(
              id,
              offerTimeoutSeconds
            );

          if (
            activation.activated &&
            activation.offer
          ) {
            const offer = activation.offer;

            io.to(`user_${offer.courierId}`).emit(
              'courier.offer_received',
              {
                ...updated,
                _targeted: true,
                dispatchOfferId: offer.id,
                offerRank: offer.rank,
                offerExpiresAt: offer.expiresAt,
              }
            );

            NotificationService.sendToUser({
              userId: offer.courierId,
              title: 'طلب توصيل جديد',
              body: `عندك طلب توصيل جديد #${updated.orderNumber}`,
              data: {
                type: 'COURIER_OFFER',
                orderId: updated.id,
                offerId: offer.id,
              },
              appType: 'COURIER',
            });
          }
        }
      }
    } catch (dispatchError) {
      console.error('[Dispatch Error]', dispatchError);
    }
    return res.json(updated);
  } catch (error: any) {
    if (error.message === 'ORDER_STATE_CHANGED') {
      return res.status(409).json({
        error: 'حالة الطلب تغيرت بواسطة عملية أخرى. يرجى تحديث الطلب والمحاولة مجدداً.',
      });
    }

    return res.status(500).json({
      error: error.message || 'فشل تحديث حالة الطلب كجاهز',
    });
  }
};
// COURIER ACTIONS
export const courierAcceptOrder = async (req: Request, res: Response) => {
  try {
    const userId = (req as AuthenticatedRequest).user?.id;
    const { id } = req.params;

    if (!userId) {
      return res.status(401).json({
        error: 'غير مصرح به',
      });
    }

    const courierUser = await prisma.user.findUnique({
      where: { id: userId },
      include: { courierProfile: true },
    });

    if (
      !courierUser ||
      courierUser.role !== 'COURIER' ||
      !courierUser.courierProfile
    ) {
      return res.status(403).json({
        error: 'حسابك ليس حساب مندوب معتمد',
      });
    }

    if (
      courierUser.courierProfile.verificationStatus !==
      'APPROVED'
    ) {
      return res.status(403).json({
        error: 'حسابك في انتظار الاعتماد من الإدارة',
      });
    }

    if (
      courierUser.courierProfile.status !== 'AVAILABLE' ||
      !courierUser.courierProfile.isOnline
    ) {
      return res.status(409).json({
        error: 'المندوب غير متاح حالياً لقبول طلب جديد',
        code: 'COURIER_NOT_AVAILABLE',
      });
    }

    const result = await prisma.$transaction(async (tx) => {
      // Serialize dispatch/accept operations for this order.
      await tx.$executeRaw`
        SELECT pg_advisory_xact_lock(
          hashtext(${`dispatch:${id}`})
        )
      `;

      const now = new Date();

      // Only the courier holding the current live offer may accept.
      const activeOffer =
        await tx.courierDispatchOffer.findFirst({
          where: {
            orderId: id,
            courierId: userId,
            status: 'OFFERED',
            expiresAt: {
              gt: now,
            },
          },
        });

      if (!activeOffer) {
        throw new Error('COURIER_OFFER_NOT_ACTIVE');
      }

      // Atomically reserve this courier.
      const courierClaim =
        await tx.courierProfile.updateMany({
          where: {
            userId,
            verificationStatus: 'APPROVED',
            status: 'AVAILABLE',
            isOnline: true,
          },
          data: {
            status: 'BUSY',
          },
        });

      if (courierClaim.count !== 1) {
        throw new Error('COURIER_NOT_AVAILABLE');
      }

      const currentOrder = await tx.order.findUnique({
        where: { id },
        select: {
          id: true,
          status: true,
          courierId: true,
        },
      });

      if (!currentOrder) {
        throw new Error('ORDER_NOT_FOUND');
      }

      if (currentOrder.courierId !== null) {
        throw new Error('ORDER_ALREADY_ACCEPTED');
      }

      if (currentOrder.status !== 'SEARCHING_COURIER') {
        throw new Error('ORDER_NOT_AVAILABLE');
      }

      // Atomic single-winner order claim.
      const orderClaim = await tx.order.updateMany({
        where: {
          id,
          courierId: null,
          status: 'SEARCHING_COURIER',
        },
        data: {
          courierId: userId,
          status: 'COURIER_ACCEPTED',
        },
      });

      if (orderClaim.count !== 1) {
        throw new Error('ORDER_ALREADY_ACCEPTED');
      }

      // Mark this offer accepted.
      await tx.courierDispatchOffer.update({
        where: {
          id: activeOffer.id,
        },
        data: {
          status: 'ACCEPTED',
          respondedAt: now,
        },
      });

      // Cancel every remaining pending offer for this order.
      await tx.courierDispatchOffer.updateMany({
        where: {
          orderId: id,
          id: {
            not: activeOffer.id,
          },
          status: {
            in: ['QUEUED', 'OFFERED'],
          },
        },
        data: {
          status: 'CANCELLED',
          respondedAt: now,
        },
      });

      return tx.order.update({
        where: { id },
        data: {
          statusHistory: {
            create: {
              fromStatus: 'SEARCHING_COURIER',
              toStatus: 'COURIER_ACCEPTED',
              actorType: 'COURIER',
              actorId: userId,
              note: 'تم قبول الطلب بواسطة المندوب',
            },
          },
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
          courier: {
            select: {
              id: true,
              name: true,
              phone: true,
            },
          },
        },
      });
    });

    io.to(`order_${id}`).emit(
      'order.status_updated',
      result
    );

    io.to(`user_${result.customerId}`).emit(
      'order.courier_assigned',
      result
    );

    io.to(`store_${result.storeId}`).emit(
      'order.courier_assigned',
      result
    );

    return res.json(result);
  } catch (error: any) {
    if (error.message === 'ORDER_NOT_FOUND') {
      return res.status(404).json({
        error: 'الطلب غير موجود',
      });
    }

    if (error.message === 'COURIER_OFFER_NOT_ACTIVE') {
      return res.status(409).json({
        error:
          'عرض التوصيل غير موجه لك أو انتهت مهلة قبوله',
        code: 'COURIER_OFFER_NOT_ACTIVE',
      });
    }

    if (error.message === 'COURIER_NOT_AVAILABLE') {
      return res.status(409).json({
        error: 'المندوب غير متاح حالياً لقبول طلب جديد',
        code: 'COURIER_NOT_AVAILABLE',
      });
    }

    if (error.message === 'ORDER_ALREADY_ACCEPTED') {
      return res.status(409).json({
        error: 'تم قبول الطلب بواسطة مندوب آخر',
        code: 'ORDER_ALREADY_ACCEPTED',
      });
    }

    if (error.message === 'ORDER_NOT_AVAILABLE') {
      return res.status(409).json({
        error: 'الطلب غير متاح للقبول حالياً',
        code: 'ORDER_NOT_AVAILABLE',
      });
    }

    return res.status(500).json({
      error: error.message || 'فشل قبول الطلب للمندوب',
    });
  }
};
export const courierRejectOffer = async (req: Request, res: Response) => {
  try {
    const userId = (req as AuthenticatedRequest).user?.id;
    const { id } = req.params;

    if (!userId) {
      return res.status(401).json({
        error: 'غير مصرح به',
      });
    }

    const result = await prisma.$transaction(async (tx) => {
      // Serialize reject / accept / timeout / next-offer operations
      // for this specific order.
      await tx.$executeRaw`
        SELECT pg_advisory_xact_lock(
          hashtext(${`dispatch:${id}`})
        )
      `;

      const now = new Date();

      const order = await tx.order.findUnique({
        where: {
          id,
        },
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
        throw new Error('ORDER_NOT_AVAILABLE');
      }

      const activeOffer =
        await tx.courierDispatchOffer.findFirst({
          where: {
            orderId: id,
            courierId: userId,
            status: 'OFFERED',
            expiresAt: {
              gt: now,
            },
          },
          select: {
            id: true,
          },
        });

      if (!activeOffer) {
        throw new Error('COURIER_OFFER_NOT_ACTIVE');
      }

      const rejected =
        await tx.courierDispatchOffer.updateMany({
          where: {
            id: activeOffer.id,
            orderId: id,
            courierId: userId,
            status: 'OFFERED',
            expiresAt: {
              gt: now,
            },
          },
          data: {
            status: 'REJECTED',
            respondedAt: now,
          },
        });

      if (rejected.count !== 1) {
        throw new Error('COURIER_OFFER_NOT_ACTIVE');
      }

      return {
        orderId: id,
        offerId: activeOffer.id,
        status: 'REJECTED',
      };
    });

    return res.status(200).json({
      success: true,
      message: 'تم تجاهل عرض التوصيل',
      ...result,
    });
  } catch (error: any) {
    console.error(
      '[Courier Reject Offer] Error:',
      error
    );

    if (error.message === 'ORDER_NOT_FOUND') {
      return res.status(404).json({
        error: 'الطلب غير موجود',
        code: 'ORDER_NOT_FOUND',
      });
    }

    if (error.message === 'ORDER_NOT_AVAILABLE') {
      return res.status(409).json({
        error: 'الطلب لم يعد متاحاً للمندوبين',
        code: 'ORDER_NOT_AVAILABLE',
      });
    }

    if (
      error.message === 'COURIER_OFFER_NOT_ACTIVE'
    ) {
      return res.status(409).json({
        error:
          'عرض التوصيل غير نشط أو انتهت مهلته',
        code: 'COURIER_OFFER_NOT_ACTIVE',
      });
    }

    return res.status(500).json({
      error: 'فشل تجاهل عرض التوصيل',
    });
  }
};

export const courierPickupOrder = async (req: Request, res: Response) => {
  try {
    const userId = (req as AuthenticatedRequest).user?.id;
    const { id } = req.params;

    const order = await prisma.order.findUnique({
      where: { id },
    });

    if (!order || order.courierId !== userId) {
      return res.status(403).json({ error: 'هذا الطلب غير مسند إليك' });
    }

    if (order.status !== 'COURIER_ACCEPTED') {
      return res.status(409).json({
        error: 'لا يمكن تنفيذ هذه الخطوة من حالة الطلب الحالية',
        code: 'INVALID_ORDER_STATE',
        expectedStatus: 'COURIER_ACCEPTED',
        currentStatus: order.status,
      });
    }

    const updated = await prisma.order.update({
      where: { id },
      data: {
        status: 'PICKED_UP',
        statusHistory: {
          create: {
            fromStatus: order.status,
            toStatus: 'PICKED_UP',
            actorType: 'COURIER',
            actorId: userId!,
            note: 'تم استلام الطلب من المتجر بواسطة المندوب',
          },
        },
      },
      include: { items: true, store: true, courier: true },
    });

    io.to(`order_${id}`).emit('order.status_updated', updated);
    io.to(`user_${order.customerId}`).emit('order.picked_up', updated);

    return res.json(updated);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل تحديث حالة استلام الطلب' });
  }
};

export const courierOnTheWay = async (req: Request, res: Response) => {
  try {
    const userId = (req as AuthenticatedRequest).user?.id;
    const { id } = req.params;

    const order = await prisma.order.findUnique({
      where: { id },
    });

    if (!order || order.courierId !== userId) {
      return res.status(403).json({ error: 'غير مصرح به' });
    }

    if (order.status !== 'PICKED_UP') {
      return res.status(409).json({
        error: 'لا يمكن تنفيذ هذه الخطوة من حالة الطلب الحالية',
        code: 'INVALID_ORDER_STATE',
        expectedStatus: 'PICKED_UP',
        currentStatus: order.status,
      });
    }

    const updated = await prisma.order.update({
      where: { id },
      data: {
        status: 'ON_THE_WAY',
        statusHistory: {
          create: {
            fromStatus: order.status,
            toStatus: 'ON_THE_WAY',
            actorType: 'COURIER',
            actorId: userId!,
            note: 'المندوب في الطريق للعميل',
          },
        },
      },
      include: { items: true, store: true, courier: true },
    });

    io.to(`order_${id}`).emit('order.status_updated', updated);
    io.to(`user_${order.customerId}`).emit('order.on_the_way', updated);

    return res.json(updated);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل تحديث حالة الطلب في الطريق' });
  }
};

export const courierArrived = async (req: Request, res: Response) => {
  try {
    const userId = (req as AuthenticatedRequest).user?.id;
    const { id } = req.params;

    const order = await prisma.order.findUnique({
      where: { id },
    });

    if (!order || order.courierId !== userId) {
      return res.status(403).json({ error: 'غير مصرح به' });
    }

    if (order.status !== 'ON_THE_WAY') {
      return res.status(409).json({
        error: 'لا يمكن تنفيذ هذه الخطوة من حالة الطلب الحالية',
        code: 'INVALID_ORDER_STATE',
        expectedStatus: 'ON_THE_WAY',
        currentStatus: order.status,
      });
    }

    const updated = await prisma.order.update({
      where: { id },
      data: {
        status: 'ARRIVED',
        statusHistory: {
          create: {
            fromStatus: order.status,
            toStatus: 'ARRIVED',
            actorType: 'COURIER',
            actorId: userId!,
            note: 'وصل المندوب لموقع العميل',
          },
        },
      },
      include: { items: true, store: true, courier: true },
    });

    io.to(`order_${id}`).emit('order.status_updated', updated);
    io.to(`user_${order.customerId}`).emit('order.arrived', updated);

    return res.json(updated);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل تحديث وصول المندوب' });
  }
};

export const courierDelivered = async (req: Request, res: Response) => {
  try {
    const userId = (req as AuthenticatedRequest).user?.id;
    const { id } = req.params;

    const order = await prisma.order.findUnique({
      where: { id },
    });

    if (!order || order.courierId !== userId) {
      return res.status(403).json({ error: 'غير مصرح به' });
    }

    if (order.status !== 'ARRIVED') {
      return res.status(409).json({
        error: 'لا يمكن تنفيذ هذه الخطوة من حالة الطلب الحالية',
        code: 'INVALID_ORDER_STATE',
        expectedStatus: 'ARRIVED',
        currentStatus: order.status,
      });
    }

    const updated = await prisma.$transaction(async (tx) => {
      const ord = await tx.order.update({
        where: { id },
        data: {
          status: 'COMPLETED',
          paymentStatus: order.paymentMethod === 'CASH' ? 'PAID' : order.paymentStatus,
          statusHistory: {
            create: {
              fromStatus: order.status,
              toStatus: 'COMPLETED',
              actorType: 'COURIER',
              actorId: userId!,
              note: 'تم تسليم الطلب واكتمال الدفع بنجاح',
            },
          },
        },
        include: { items: true, store: true, courier: true },
      });

      await tx.courierProfile.update({
        where: { userId },
        data: { status: 'AVAILABLE' },
      });

      return ord;
    });

    io.to(`order_${id}`).emit('order.status_updated', updated);
    io.to(`user_${order.customerId}`).emit('order.completed', updated);

    return res.json(updated);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل إكمال الطلب' });
  }
};

export const customerCancelOrder = async (req: Request, res: Response) => {
  try {
    const userId = (req as AuthenticatedRequest).user?.id;
    const { id } = req.params;

    const order = await prisma.order.findUnique({
      where: { id },
    });

    if (!order || order.customerId !== userId) {
      return res.status(403).json({ error: 'غير مصرح به' });
    }

    if (order.status !== 'PENDING_MERCHANT') {
      return res.status(400).json({ error: 'لا يمكن إلغاء الطلب بعد قبول المتجر له' });
    }

    const updated = await prisma.order.update({
      where: { id },
      data: {
        status: 'CUSTOMER_CANCELLED',
        statusHistory: {
          create: {
            fromStatus: 'PENDING_MERCHANT',
            toStatus: 'CUSTOMER_CANCELLED',
            actorType: 'CUSTOMER',
            actorId: userId!,
            note: 'تم إلغاء الطلب بواسطة العميل',
          },
        },
      },
    });

    io.to(`order_${id}`).emit('order.status_updated', updated);

    return res.json(updated);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل إلغاء الطلب' });
  }
};

const rateOrderSchema = z.object({
  rating: z.number().int().min(1).max(5),
  comment: z.string().optional(),
});

export const rateOrder = async (req: Request, res: Response) => {
  try {
    const userId = (req as AuthenticatedRequest).user?.id;
    const { id } = req.params;
    const validated = rateOrderSchema.parse(req.body);

    const order = await prisma.order.findUnique({
      where: { id },
    });

    if (!order) {
      return res.status(404).json({ error: 'الطلب غير موجود' });
    }

    if (order.customerId !== userId) {
      return res.status(403).json({ error: 'يمكن فقط للعميل صاحب الطلب تقييم هذا الطلب' });
    }

    if (order.status !== 'DELIVERED' && order.status !== 'COMPLETED') {
      return res.status(400).json({ error: 'يمكن فقط تقييم الطلبات المكتملة أو المسلمة' });
    }

    const existingReview = await prisma.review.findUnique({
      where: { orderId: id },
    });

    if (existingReview) {
      return res.status(400).json({ error: 'لقد قمت بتقييم هذا الطلب من قبل' });
    }

    const result = await prisma.$transaction(async (tx) => {
      const review = await tx.review.create({
        data: {
          orderId: id,
          storeId: order.storeId,
          userId: userId!,
          rating: validated.rating,
          comment: validated.comment || null,
        },
      });

      const storeReviews = await tx.review.findMany({
        where: { storeId: order.storeId },
        select: { rating: true },
      });

      const count = storeReviews.length;
      const sum = storeReviews.reduce((acc, r) => acc + r.rating, 0);
      const avgRating = count > 0 ? Math.round((sum / count) * 10) / 10 : 5.0;

      await tx.store.update({
        where: { id: order.storeId },
        data: {
          rating: avgRating,
          reviewCount: count,
        },
      });

      return review;
    });

    return res.status(201).json({
      message: 'تم تقييم الطلب بنجاح',
      review: result,
    });
  } catch (error: any) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'بيانات التقييم غير صالحة', details: error.errors });
    }
    return res.status(500).json({ error: error.message || 'فشل تقييم الطلب' });
  }
};

const bankakSubmitSchema = z.object({
  last4: z.string().regex(/^\d{4}$/, 'يرجى إدخال آخر 4 أرقام من رقم العملية بشكل صحيح'),
});

export const submitBankakPayment = async (req: Request, res: Response) => {
  try {
    const userId = (req as AuthenticatedRequest).user?.id;
    if (!userId) {
      return res.status(401).json({ error: 'غير مصرح به' });
    }

    const { id } = req.params;
    const { last4 } = bankakSubmitSchema.parse(req.body);

    const updated = await prisma.$transaction(async (tx) => {
      const current = await tx.order.findUnique({
        where: { id },
        include: {
          store: true,
          customer: {
            select: { id: true, name: true, phone: true },
          },
        },
      });

      if (!current) throw new Error('ORDER_NOT_FOUND');
      if (current.customerId !== userId) throw new Error('ORDER_FORBIDDEN');

      if (
        current.status !== 'PENDING_MERCHANT' ||
        current.paymentMethod !== 'BANKAK'
      ) {
        throw new Error('BANKAK_INVALID_STATE');
      }

      // Idempotent retry.
      if (
        current.paymentStatus === 'BANKAK_SUBMITTED' &&
        current.bankakLast4 === last4
      ) {
        return current;
      }

      // A submitted payment cannot be silently changed while admin is reviewing it.
      if (
        current.paymentStatus !== 'BANKAK_PENDING' &&
        current.paymentStatus !== 'BANKAK_REJECTED'
      ) {
        throw new Error('BANKAK_INVALID_STATE');
      }

      const claim = await tx.order.updateMany({
        where: {
          id,
          customerId: userId,
          status: 'PENDING_MERCHANT',
          paymentMethod: 'BANKAK',
          paymentStatus: {
            in: ['BANKAK_PENDING', 'BANKAK_REJECTED'],
          },
        },
        data: {
          paymentStatus: 'BANKAK_SUBMITTED',
          bankakTxnRef: last4,
          bankakLast4: last4,
          paymentSubmittedAt: new Date(),
          paymentVerifiedAt: null,
          paymentVerifiedBy: null,
          paymentRejectionReason: null,
        },
      });

      if (claim.count !== 1) {
        throw new Error('BANKAK_STATE_CHANGED');
      }

      return tx.order.update({
        where: { id },
        data: {
          statusHistory: {
            create: {
              fromStatus: current.status,
              toStatus: current.status,
              actorType: 'CUSTOMER',
              actorId: userId,
              note: `تم تقديم إثبات تحويل بنكك برقم (${last4})`,
            },
          },
        },
        include: {
          store: true,
          customer: {
            select: { id: true, name: true, phone: true },
          },
        },
      });
    });

    try {
      io.to('admins').emit('order.updated', updated);
      io.to(`user_${userId}`).emit('order.updated', updated);
    } catch (_) {}

    return res.json(updated);
  } catch (error: any) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        error: error.errors[0]?.message || 'بيانات رقم العملية غير صالحة',
      });
    }

    if (error.message === 'ORDER_NOT_FOUND') {
      return res.status(404).json({ error: 'الطلب غير موجود' });
    }

    if (error.message === 'ORDER_FORBIDDEN') {
      return res.status(403).json({ error: 'غير مصرح لك بتعديل هذا الطلب' });
    }

    if (
      error.message === 'BANKAK_INVALID_STATE' ||
      error.message === 'BANKAK_STATE_CHANGED'
    ) {
      return res.status(409).json({
        error: 'حالة دفع بنكك الحالية لا تسمح بتنفيذ هذه العملية',
        code: 'BANKAK_INVALID_STATE',
      });
    }

    return res.status(500).json({
      error: error.message || 'فشل إرسال رقم العملية',
    });
  }
};


export const switchToCashPayment = async (req: Request, res: Response) => {
  try {
    const userId = (req as AuthenticatedRequest).user?.id;

    if (!userId) {
      return res.status(401).json({ error: 'غير مصرح به' });
    }

    const { id } = req.params;

    const updated = await prisma.$transaction(async (tx) => {
      const current = await tx.order.findUnique({
        where: { id },
        include: {
          store: { include: { merchant: true } },
          customer: {
            select: { id: true, name: true, phone: true },
          },
        },
      });

      if (!current) throw new Error('ORDER_NOT_FOUND');
      if (current.customerId !== userId) throw new Error('ORDER_FORBIDDEN');

      // Only rejected Bankak payments may switch to Cash.
      if (
        current.status !== 'PENDING_MERCHANT' ||
        current.paymentMethod !== 'BANKAK' ||
        current.paymentStatus !== 'BANKAK_REJECTED'
      ) {
        throw new Error('CASH_SWITCH_NOT_ALLOWED');
      }

      const claim = await tx.order.updateMany({
        where: {
          id,
          customerId: userId,
          status: 'PENDING_MERCHANT',
          paymentMethod: 'BANKAK',
          paymentStatus: 'BANKAK_REJECTED',
        },
        data: {
          paymentMethod: 'CASH',
          paymentStatus: 'UNPAID',
          paymentVerifiedAt: null,
          paymentVerifiedBy: null,
        },
      });

      if (claim.count !== 1) {
        throw new Error('CASH_SWITCH_NOT_ALLOWED');
      }

      return tx.order.update({
        where: { id },
        data: {
          statusHistory: {
            create: {
              fromStatus: current.status,
              toStatus: current.status,
              actorType: 'CUSTOMER',
              actorId: userId,
              note: 'تم تحويل طريقة الدفع إلى الدفع عند الاستلام (كاش)',
            },
          },
        },
        include: {
          store: { include: { merchant: true } },
          customer: {
            select: { id: true, name: true, phone: true },
          },
        },
      });
    });

    try {
      io.to('admins').emit('order.updated', updated);
      io.to(`user_${userId}`).emit('order.updated', updated);

      // Rejected Bankak -> Cash makes the order actionable for merchant.
      io.to(`store_${updated.storeId}`).emit('order.created', updated);

      const merchantUserId = updated.store?.merchant?.userId;

      if (merchantUserId) {
        NotificationService.sendToUser({
          userId: merchantUserId,
          title: 'طلب كاش جديد 📦',
          body: `الطلب #${updated.orderNumber} أصبح متاحاً للتنفيذ بالدفع عند الاستلام`,
          data: {
            type: 'ORDER_CREATED',
            orderId: updated.id,
          },
          appType: 'MERCHANT',
        });
      }
    } catch (_) {}

    return res.json(updated);
  } catch (error: any) {
    if (error.message === 'ORDER_NOT_FOUND') {
      return res.status(404).json({ error: 'الطلب غير موجود' });
    }

    if (error.message === 'ORDER_FORBIDDEN') {
      return res.status(403).json({ error: 'غير مصرح لك بتعديل هذا الطلب' });
    }

    if (error.message === 'CASH_SWITCH_NOT_ALLOWED') {
      return res.status(409).json({
        error: 'يمكن التحويل إلى الكاش فقط بعد رفض تحويل بنكك وقبل قبول المتجر للطلب',
        code: 'CASH_SWITCH_NOT_ALLOWED',
      });
    }

    return res.status(500).json({
      error: error.message || 'فشل تغيير طريقة الدفع إلى كاش',
    });
  }
};