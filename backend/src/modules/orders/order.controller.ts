import { Request, Response } from 'express';
import { z } from 'zod';
import { prisma } from '../../utils/prisma';
import { AuthenticatedRequest } from '../../middleware/auth.middleware';
import { io } from '../../server';

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
    const dbProducts = await prisma.product.findMany({
      where: {
        id: { in: productIds },
        storeId: validated.storeId,
        isAvailable: true,
      },
    });

    if (dbProducts.length !== productIds.length) {
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

    const deliveryFee = store.deliveryFee || 500.0;
    const total = subtotal + deliveryFee;
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
          discount: 0.0,
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
          store: true,
          customer: {
            select: { id: true, name: true, phone: true },
          },
        },
      });

      return newOrder;
    });

    // Real-Time Socket Emission
    try {
      io.to(`store_${store.id}`).emit('order.created', order);
      io.to(`user_${userId}`).emit('order.created', order);
    } catch (e) {
      console.error('Socket emission error:', e);
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
      whereClause.storeId = { in: storeIds };
    } else if (user.role === 'COURIER') {
      // Courier can see assigned orders OR orders searching for courier
      whereClause.OR = [
        { courierId: user.id },
        { status: 'SEARCHING_COURIER', courierId: null },
        { status: 'READY_FOR_PICKUP', courierId: null },
      ];
    }

    const orders = await prisma.order.findMany({
      where: whereClause,
      include: {
        items: true,
        store: true,
        customer: { select: { id: true, name: true, phone: true } },
        courier: { select: { id: true, name: true, phone: true } },
      },
      orderBy: { createdAt: 'desc' },
    });

    return res.json(orders);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'حدث خطأ أثناء جلب الطلبات' });
  }
};

export const getOrderById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const order = await prisma.order.findUnique({
      where: { id },
      include: {
        items: true,
        store: true,
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
      },
    });

    if (!order) {
      return res.status(404).json({ error: 'الطلب غير موجود' });
    }

    return res.json(order);
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
      return res.status(400).json({ error: 'حالة الطلب الحالية لا تسمح بتقديمه كجاهز للاستلام' });
    }

    const updated = await prisma.order.update({
      where: { id },
      data: {
        status: 'SEARCHING_COURIER',
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
      include: { items: true, store: true },
    });

    io.to(`order_${id}`).emit('order.status_updated', updated);
    io.to('couriers_available').emit('courier.offer_received', updated);

    return res.json(updated);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل تحديث حالة الطلب كجاهز' });
  }
};

// COURIER ACTIONS
export const courierAcceptOrder = async (req: Request, res: Response) => {
  try {
    const userId = (req as AuthenticatedRequest).user?.id;
    const { id } = req.params;

    const courierUser = await prisma.user.findUnique({
      where: { id: userId },
      include: { courierProfile: true },
    });

    if (!courierUser || courierUser.role !== 'COURIER' || !courierUser.courierProfile) {
      return res.status(403).json({ error: 'حسابك ليس حساب مندوب معتمد' });
    }

    if (courierUser.courierProfile.verificationStatus !== 'APPROVED') {
      return res.status(403).json({ error: 'حسابك في انتظار الاعتماد من الإدارة' });
    }

    // Atomic transaction to prevent double courier acceptance
    const result = await prisma.$transaction(async (tx) => {
      const order = await tx.order.findUnique({
        where: { id },
      });

      if (!order) {
        throw new Error('الطلب غير موجود');
      }

      if (order.courierId && order.courierId !== userId) {
        throw new Error('الطلب تم قبوله مسبقاً بواسطة مندوب آخر');
      }

      if (order.status !== 'SEARCHING_COURIER' && order.status !== 'READY_FOR_PICKUP') {
        throw new Error('الطلب غير متاح للقبول حالياً');
      }

      const updatedOrder = await tx.order.update({
        where: { id },
        data: {
          courierId: userId,
          status: 'COURIER_ACCEPTED',
          statusHistory: {
            create: {
              fromStatus: order.status,
              toStatus: 'COURIER_ACCEPTED',
              actorType: 'COURIER',
              actorId: userId!,
              note: 'تم قبول الطلب بواسطة المندوب',
            },
          },
        },
        include: {
          items: true,
          store: true,
          customer: { select: { id: true, name: true, phone: true } },
          courier: { select: { id: true, name: true, phone: true } },
        },
      });

      await tx.courierProfile.update({
        where: { userId },
        data: { status: 'BUSY' },
      });

      return updatedOrder;
    });

    io.to(`order_${id}`).emit('order.status_updated', result);
    io.to(`user_${result.customerId}`).emit('order.courier_assigned', result);
    io.to(`store_${result.storeId}`).emit('order.courier_assigned', result);

    return res.json(result);
  } catch (error: any) {
    return res.status(400).json({ error: error.message || 'فشل قبول الطلب للمندوب' });
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

    const updated = await prisma.$transaction(async (tx) => {
      const ord = await tx.order.update({
        where: { id },
        data: {
          status: 'COMPLETED',
          paymentStatus: 'PAID',
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
