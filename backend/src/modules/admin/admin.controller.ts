import { Request, Response } from 'express';
import { z } from 'zod';
import bcrypt from 'bcryptjs';
import { prisma } from '../../utils/prisma';
import { AuthenticatedRequest } from '../../middleware/auth.middleware';
import { io } from '../../server';

// Audit Logger Helper
async function logAuditAction(
  adminId: string,
  action: string,
  entityType: string,
  entityId: string,
  beforeData?: any,
  afterData?: any,
  ipAddress?: string
) {
  try {
    await prisma.auditLog.create({
      data: {
        adminId,
        action,
        entityType,
        entityId,
        beforeData: beforeData ? JSON.stringify(beforeData) : null,
        afterData: afterData ? JSON.stringify(afterData) : null,
        ipAddress: ipAddress || null,
      },
    });
  } catch (e) {
    console.error('Failed to record audit log:', e);
  }
}

// 1. OVERVIEW DASHBOARD
export const getAdminOverview = async (req: Request, res: Response) => {
  try {
    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);

    const [
      todayOrdersCount,
      activeOrdersCount,
      pendingMerchantOrders,
      searchingCourierOrders,
      inTransitOrders,
      completedOrdersCount,
      cancelledOrdersCount,
      pendingMerchantsCount,
      approvedMerchantsCount,
      suspendedMerchantsCount,
      availableCouriersCount,
      busyCouriersCount,
      offlineCouriersCount,
      pendingCouriersCount,
      pendingBankakCount,
      recentOrders,
      serviceAreasCount,
      openTicketsCount,
    ] = await Promise.all([
      prisma.order.count({ where: { createdAt: { gte: todayStart } } }),
      prisma.order.count({
        where: {
          status: {
            in: [
              'PENDING_MERCHANT',
              'MERCHANT_ACCEPTED',
              'PREPARING',
              'READY_FOR_PICKUP',
              'SEARCHING_COURIER',
              'COURIER_ASSIGNED',
              'COURIER_ACCEPTED',
              'COURIER_TO_MERCHANT',
              'AT_MERCHANT',
              'PICKED_UP',
              'ON_THE_WAY',
              'ARRIVED',
            ],
          },
        },
      }),
      prisma.order.count({ where: { status: 'PENDING_MERCHANT' } }),
      prisma.order.count({ where: { status: 'SEARCHING_COURIER' } }),
      prisma.order.count({ where: { status: { in: ['PICKED_UP', 'ON_THE_WAY', 'ARRIVED'] } } }),
      prisma.order.count({ where: { status: 'COMPLETED' } }),
      prisma.order.count({ where: { status: { in: ['MERCHANT_REJECTED', 'CUSTOMER_CANCELLED', 'COURIER_CANCELLED', 'FAILED'] } } }),
      prisma.merchantProfile.count({ where: { status: 'PENDING' } }),
      prisma.merchantProfile.count({ where: { status: 'APPROVED' } }),
      prisma.merchantProfile.count({ where: { status: 'SUSPENDED' } }),
      prisma.courierProfile.count({ where: { status: 'AVAILABLE', verificationStatus: 'APPROVED' } }),
      prisma.courierProfile.count({ where: { status: 'BUSY', verificationStatus: 'APPROVED' } }),
      prisma.courierProfile.count({ where: { status: 'OFFLINE', verificationStatus: 'APPROVED' } }),
      prisma.courierProfile.count({ where: { verificationStatus: 'PENDING' } }),
      prisma.order.count({ where: { paymentMethod: 'BANKAK', paymentStatus: 'BANKAK_PENDING' } }),
      prisma.order.findMany({
        take: 10,
        orderBy: { createdAt: 'desc' },
        include: {
          store: { select: { name: true, category: true } },
          customer: { select: { name: true, phone: true } },
          courier: { select: { name: true, phone: true } },
        },
      }),
      prisma.serviceArea.count({ where: { isActive: true } }),
      prisma.supportTicket.count({ where: { status: 'OPEN' } }),
    ]);

    // Operational alerts
    const alerts: string[] = [];
    if (pendingMerchantOrders > 5) {
      alerts.push(`يوجد ${pendingMerchantOrders} طلبات تنتظر موافقة المتجر منذ أكثر من 10 دقائق`);
    }
    if (searchingCourierOrders > 3 && availableCouriersCount === 0) {
      alerts.push(`تنبيه: يوجد ${searchingCourierOrders} طلب يبحث عن مندوب ولا يوجد مناديب متاحين حالياً`);
    }
    if (pendingBankakCount > 0) {
      alerts.push(`تنبيه مالي: يوجد ${pendingBankakCount} تحويل بنكك بانتظار التوثيق`);
    }

    return res.json({
      metrics: {
        todayOrdersCount,
        activeOrdersCount,
        pendingMerchantOrders,
        searchingCourierOrders,
        inTransitOrders,
        completedOrdersCount,
        cancelledOrdersCount,
        merchants: {
          pending: pendingMerchantsCount,
          approved: approvedMerchantsCount,
          suspended: suspendedMerchantsCount,
        },
        couriers: {
          available: availableCouriersCount,
          busy: busyCouriersCount,
          offline: offlineCouriersCount,
          pending: pendingCouriersCount,
        },
        pendingBankakCount,
        activeCoverageAreas: serviceAreasCount,
        openTicketsCount,
      },
      recentOrders,
      alerts,
      systemHealth: {
        api: 'ONLINE',
        database: 'CONNECTED',
        socket: 'ACTIVE',
        lastChecked: new Date(),
      },
    });
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل جلب بيانات اللوحة الإدارية' });
  }
};

// 2. LIVE ORDERS MANAGEMENT
export const getAdminOrders = async (req: Request, res: Response) => {
  try {
    const { page = '1', limit = '20', status, category, paymentMethod, q, storeId, courierId } = req.query;

    const pageNum = parseInt(page as string, 10) || 1;
    const limitNum = parseInt(limit as string, 10) || 20;
    const skip = (pageNum - 1) * limitNum;

    const whereClause: any = {};

    if (status && status !== 'ALL') {
      whereClause.status = status;
    }

    if (category && category !== 'ALL') {
      whereClause.store = { category: category };
    }

    if (paymentMethod && paymentMethod !== 'ALL') {
      whereClause.paymentMethod = paymentMethod;
    }

    if (storeId) whereClause.storeId = storeId;
    if (courierId) whereClause.courierId = courierId;

    if (q && typeof q === 'string' && q.trim() !== '') {
      const term = q.trim();
      whereClause.OR = [
        { orderNumber: { contains: term, mode: 'insensitive' } },
        { customerNotes: { contains: term, mode: 'insensitive' } },
        { customer: { name: { contains: term, mode: 'insensitive' } } },
        { customer: { phone: { contains: term } } },
        { store: { name: { contains: term, mode: 'insensitive' } } },
      ];
    }

    const [total, orders] = await Promise.all([
      prisma.order.count({ where: whereClause }),
      prisma.order.findMany({
        where: whereClause,
        skip,
        take: limitNum,
        orderBy: { createdAt: 'desc' },
        include: {
          items: true,
          store: { select: { id: true, name: true, category: true } },
          customer: { select: { id: true, name: true, phone: true } },
          courier: { select: { id: true, name: true, phone: true } },
        },
      }),
    ]);

    return res.json({
      orders,
      pagination: {
        total,
        page: pageNum,
        limit: limitNum,
        totalPages: Math.ceil(total / limitNum),
      },
    });
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل جلب قائمة الطلبات' });
  }
};

export const getAdminOrderById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const order = await prisma.order.findUnique({
      where: { id },
      include: {
        items: true,
        store: { select: { id: true, name: true, category: true, address: true, latitude: true, longitude: true } },
        customer: { select: { id: true, name: true, phone: true, email: true } },
        courier: {
          select: {
            id: true,
            name: true,
            phone: true,
            courierProfile: { select: { vehicleType: true, currentLatitude: true, currentLongitude: true } },
          },
        },
        statusHistory: { orderBy: { timestamp: 'asc' } },
        locationLogs: { orderBy: { createdAt: 'desc' }, take: 5 },
      },
    });

    if (!order) {
      return res.status(404).json({ error: 'الطلب غير موجود' });
    }

    return res.json(order);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل تفاصيل الطلب' });
  }
};

// COURIER REASSIGNMENT BY ADMIN/OPERATIONS
const reassignCourierSchema = z.object({
  courierId: z.string().min(1),
  reason: z.string().optional(),
});

export const adminReassignCourier = async (req: Request, res: Response) => {
  try {
    const adminId = (req as AuthenticatedRequest).user?.id!;
    const { id } = req.params;
    const validated = reassignCourierSchema.parse(req.body);

    const targetCourier = await prisma.user.findUnique({
      where: { id: validated.courierId },
      include: { courierProfile: true },
    });

    if (!targetCourier || targetCourier.role !== 'COURIER' || !targetCourier.courierProfile) {
      return res.status(400).json({ error: 'المندوب المحدد غير موجود' });
    }

    if (targetCourier.courierProfile.verificationStatus !== 'APPROVED') {
      return res.status(400).json({ error: 'المندوب المحدد غير معتمد من الإدارة' });
    }

    const updatedOrder = await prisma.$transaction(async (tx) => {
      const order = await tx.order.findUnique({ where: { id } });
      if (!order) throw new Error('الطلب غير موجود');

      const oldCourierId = order.courierId;

      // Reset old courier status if any
      if (oldCourierId) {
        await tx.courierProfile.update({
          where: { userId: oldCourierId },
          data: { status: 'AVAILABLE' },
        });
      }

      // Assign new courier atomically
      const updated = await tx.order.update({
        where: { id },
        data: {
          courierId: validated.courierId,
          status: 'COURIER_ACCEPTED',
          statusHistory: {
            create: {
              fromStatus: order.status,
              toStatus: 'COURIER_ACCEPTED',
              actorType: 'ADMIN',
              actorId: adminId,
              note: `تم إعادة تعيين المندوب بواسطة الإدارة: ${targetCourier.name}. السبب: ${validated.reason || 'تغيير تشغيلي'}`,
            },
          },
        },
        include: { store: true, courier: true, customer: true },
      });

      await tx.courierProfile.update({
        where: { userId: validated.courierId },
        data: { status: 'BUSY' },
      });

      return updated;
    });

    await logAuditAction(adminId, 'ADMIN_REASSIGNED_COURIER', 'ORDER', id, null, { newCourierId: validated.courierId });

    io.to(`order_${id}`).emit('order.status_updated', updatedOrder);

    return res.json(updatedOrder);
  } catch (error: any) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'بيانات غير صالحة', details: error.errors });
    }
    return res.status(500).json({ error: error.message || 'فشل إعادة تعيين المندوب' });
  }
};

export const adminCancelOrder = async (req: Request, res: Response) => {
  try {
    const adminId = (req as AuthenticatedRequest).user?.id!;
    const { id } = req.params;
    const { reason } = req.body;

    const order = await prisma.order.findUnique({ where: { id } });
    if (!order) return res.status(404).json({ error: 'الطلب غير موجود' });

    const updated = await prisma.$transaction(async (tx) => {
      const ord = await tx.order.update({
        where: { id },
        data: {
          status: 'FAILED',
          statusHistory: {
            create: {
              fromStatus: order.status,
              toStatus: 'FAILED',
              actorType: 'ADMIN',
              actorId: adminId,
              note: `تم إلغاء الطلب من قِبَل الإدارة: ${reason || 'إلغاء أداري'}`,
            },
          },
        },
      });

      if (order.courierId) {
        await tx.courierProfile.update({
          where: { userId: order.courierId },
          data: { status: 'AVAILABLE' },
        });
      }

      return ord;
    });

    await logAuditAction(adminId, 'ADMIN_CANCELLED_ORDER', 'ORDER', id, { previousStatus: order.status }, { reason });

    io.to(`order_${id}`).emit('order.status_updated', updated);

    return res.json(updated);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل إلغاء الطلب' });
  }
};

// 3. MERCHANTS MANAGEMENT
export const getAdminMerchants = async (req: Request, res: Response) => {
  try {
    const { status, category, q, page = '1', limit = '20' } = req.query;
    const pageNum = parseInt(page as string, 10) || 1;
    const limitNum = parseInt(limit as string, 10) || 20;

    const whereClause: any = {};
    if (status && status !== 'ALL') whereClause.status = status;

    if (q && typeof q === 'string' && q.trim() !== '') {
      const term = q.trim();
      whereClause.OR = [
        { businessName: { contains: term, mode: 'insensitive' } },
        { user: { name: { contains: term, mode: 'insensitive' } } },
        { user: { phone: { contains: term } } },
      ];
    }

    const [total, merchants] = await Promise.all([
      prisma.merchantProfile.count({ where: whereClause }),
      prisma.merchantProfile.findMany({
        where: whereClause,
        skip: (pageNum - 1) * limitNum,
        take: limitNum,
        orderBy: { user: { createdAt: 'desc' } },
        include: {
          user: { select: { id: true, name: true, phone: true, email: true, createdAt: true } },
          stores: {
            include: {
              _count: { select: { products: true, orders: true } },
            },
          },
        },
      }),
    ]);

    return res.json({
      merchants,
      pagination: { total, page: pageNum, limit: limitNum, totalPages: Math.ceil(total / limitNum) },
    });
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل جلب التجار' });
  }
};

export const updateMerchantStatus = async (req: Request, res: Response) => {
  try {
    const adminId = (req as AuthenticatedRequest).user?.id!;
    const { id } = req.params;
    const { status, reason } = req.body;

    if (!['APPROVED', 'REJECTED', 'SUSPENDED', 'PENDING'].includes(status)) {
      return res.status(400).json({ error: 'حالة غير صالحة' });
    }

    const merchant = await prisma.merchantProfile.findUnique({ where: { id } });
    if (!merchant) return res.status(404).json({ error: 'حساب التاجر غير موجود' });

    const updated = await prisma.merchantProfile.update({
      where: { id },
      data: { status },
    });

    await logAuditAction(adminId, `ADMIN_${status}_MERCHANT`, 'MERCHANT', id, { previousStatus: merchant.status }, { newStatus: status, reason });

    return res.json(updated);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل تحديث حالة التاجر' });
  }
};

// 4. COURIERS MANAGEMENT
export const getAdminCouriers = async (req: Request, res: Response) => {
  try {
    const { verificationStatus, status, vehicleType, q, page = '1', limit = '20' } = req.query;
    const pageNum = parseInt(page as string, 10) || 1;
    const limitNum = parseInt(limit as string, 10) || 20;

    const whereClause: any = {};
    if (verificationStatus && verificationStatus !== 'ALL') whereClause.verificationStatus = verificationStatus;
    if (status && status !== 'ALL') whereClause.status = status;
    if (vehicleType && vehicleType !== 'ALL') whereClause.vehicleType = vehicleType;

    if (q && typeof q === 'string' && q.trim() !== '') {
      const term = q.trim();
      whereClause.OR = [
        { user: { name: { contains: term, mode: 'insensitive' } } },
        { user: { phone: { contains: term } } },
        { idNumber: { contains: term } },
      ];
    }

    const [total, couriers] = await Promise.all([
      prisma.courierProfile.count({ where: whereClause }),
      prisma.courierProfile.findMany({
        where: whereClause,
        skip: (pageNum - 1) * limitNum,
        take: limitNum,
        orderBy: { user: { createdAt: 'desc' } },
        include: {
          user: {
            select: {
              id: true,
              name: true,
              phone: true,
              email: true,
              createdAt: true,
              courierOrders: {
                take: 5,
                orderBy: { createdAt: 'desc' },
                select: { id: true, orderNumber: true, status: true, total: true, createdAt: true },
              },
            },
          },
        },
      }),
    ]);

    return res.json({
      couriers,
      pagination: { total, page: pageNum, limit: limitNum, totalPages: Math.ceil(total / limitNum) },
    });
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل جلب المناديب' });
  }
};

export const updateCourierStatus = async (req: Request, res: Response) => {
  try {
    const adminId = (req as AuthenticatedRequest).user?.id!;
    const { id } = req.params;
    const { verificationStatus, status, reason } = req.body;

    const courier = await prisma.courierProfile.findUnique({ where: { id } });
    if (!courier) return res.status(404).json({ error: 'حساب المندوب غير موجود' });

    const updateData: any = {};
    if (verificationStatus) updateData.verificationStatus = verificationStatus;
    if (status) updateData.status = status;

    const updated = await prisma.courierProfile.update({
      where: { id },
      data: updateData,
    });

    await logAuditAction(adminId, `ADMIN_UPDATED_COURIER`, 'COURIER', id, { previous: courier }, { updated: updateData, reason });

    return res.json(updated);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل تحديث حساب المندوب' });
  }
};

// 5. CUSTOMER MANAGEMENT
export const getAdminCustomers = async (req: Request, res: Response) => {
  try {
    const { q, page = '1', limit = '20' } = req.query;
    const pageNum = parseInt(page as string, 10) || 1;
    const limitNum = parseInt(limit as string, 10) || 20;

    const whereClause: any = { role: 'CUSTOMER' };

    if (q && typeof q === 'string' && q.trim() !== '') {
      const term = q.trim();
      whereClause.OR = [
        { name: { contains: term, mode: 'insensitive' } },
        { phone: { contains: term } },
        { email: { contains: term, mode: 'insensitive' } },
      ];
    }

    const [total, customers] = await Promise.all([
      prisma.user.count({ where: whereClause }),
      prisma.user.findMany({
        where: whereClause,
        skip: (pageNum - 1) * limitNum,
        take: limitNum,
        orderBy: { createdAt: 'desc' },
        select: {
          id: true,
          name: true,
          phone: true,
          email: true,
          isActive: true,
          createdAt: true,
          _count: { select: { customerOrders: true } },
        },
      }),
    ]);

    return res.json({
      customers,
      pagination: { total, page: pageNum, limit: limitNum, totalPages: Math.ceil(total / limitNum) },
    });
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل جلب العملاء' });
  }
};

export const updateCustomerStatus = async (req: Request, res: Response) => {
  try {
    const adminId = (req as AuthenticatedRequest).user?.id!;
    const { id } = req.params;
    const { isActive, reason } = req.body;

    const user = await prisma.user.findUnique({ where: { id } });
    if (!user || user.role !== 'CUSTOMER') return res.status(404).json({ error: 'العميل غير موجود' });

    const updated = await prisma.user.update({
      where: { id },
      data: { isActive: Boolean(isActive) },
    });

    await logAuditAction(adminId, isActive ? 'ADMIN_REACTIVATED_CUSTOMER' : 'ADMIN_SUSPENDED_CUSTOMER', 'USER', id, { previousActive: user.isActive }, { isActive, reason });

    return res.json(updated);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل تحديث حالة العميل' });
  }
};

// 6. BANKAK & PAYMENTS MANAGEMENT (FINANCE ROLE)
export const getAdminPayments = async (req: Request, res: Response) => {
  try {
    const { paymentMethod, paymentStatus, page = '1', limit = '20' } = req.query;
    const pageNum = parseInt(page as string, 10) || 1;
    const limitNum = parseInt(limit as string, 10) || 20;

    const whereClause: any = {};
    if (paymentMethod && paymentMethod !== 'ALL') whereClause.paymentMethod = paymentMethod;
    if (paymentStatus && paymentStatus !== 'ALL') whereClause.paymentStatus = paymentStatus;

    const [total, orders] = await Promise.all([
      prisma.order.count({ where: whereClause }),
      prisma.order.findMany({
        where: whereClause,
        skip: (pageNum - 1) * limitNum,
        take: limitNum,
        orderBy: { createdAt: 'desc' },
        select: {
          id: true,
          orderNumber: true,
          total: true,
          paymentMethod: true,
          paymentStatus: true,
          bankakProofImage: true,
          bankakTxnRef: true,
          createdAt: true,
          customer: { select: { id: true, name: true, phone: true } },
          store: { select: { name: true } },
        },
      }),
    ]);

    return res.json({
      orders,
      pagination: { total, page: pageNum, limit: limitNum, totalPages: Math.ceil(total / limitNum) },
    });
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل جلب المدفوعات' });
  }
};

export const verifyBankakPayment = async (req: Request, res: Response) => {
  try {
    const adminId = (req as AuthenticatedRequest).user?.id!;
    const { id } = req.params;

    const order = await prisma.order.findUnique({ where: { id } });
    if (!order) return res.status(404).json({ error: 'الطلب غير موجود' });

    const updated = await prisma.order.update({
      where: { id },
      data: {
        paymentStatus: 'BANKAK_VERIFIED',
      },
    });

    await logAuditAction(adminId, 'ADMIN_VERIFIED_BANKAK', 'ORDER', id, { oldStatus: order.paymentStatus }, { newStatus: 'BANKAK_VERIFIED' });

    return res.json(updated);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل توثيق الدفع' });
  }
};

export const rejectBankakPayment = async (req: Request, res: Response) => {
  try {
    const adminId = (req as AuthenticatedRequest).user?.id!;
    const { id } = req.params;
    const { reason } = req.body;

    if (!reason || reason.trim() === '') {
      return res.status(400).json({ error: 'يرجى تقديم سبب رفض التحويل' });
    }

    const order = await prisma.order.findUnique({ where: { id } });
    if (!order) return res.status(404).json({ error: 'الطلب غير موجود' });

    const updated = await prisma.order.update({
      where: { id },
      data: {
        paymentStatus: 'BANKAK_REJECTED',
        merchantNotes: `رفض التحويل البنكي: ${reason}`,
      },
    });

    await logAuditAction(adminId, 'ADMIN_REJECTED_BANKAK', 'ORDER', id, { oldStatus: order.paymentStatus }, { newStatus: 'BANKAK_REJECTED', reason });

    return res.json(updated);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل رفض التوثيق' });
  }
};

// 7. COVERAGE & PRICING MANAGEMENT
export const getAdminCoverage = async (req: Request, res: Response) => {
  try {
    const areas = await prisma.serviceArea.findMany({
      orderBy: [{ state: 'asc' }, { locality: 'asc' }],
    });
    return res.json(areas);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل جلب مناطق التغطية' });
  }
};

export const updateAdminCoverage = async (req: Request, res: Response) => {
  try {
    const adminId = (req as AuthenticatedRequest).user?.id!;
    const { id } = req.params;
    const { isActive, deliveryRadius, minimumDeliveryFee, pricePerKm } = req.body;

    const area = await prisma.serviceArea.findUnique({ where: { id } });
    if (!area) return res.status(404).json({ error: 'المنطقة غير موجودة' });

    const updated = await prisma.serviceArea.update({
      where: { id },
      data: {
        isActive: isActive !== undefined ? Boolean(isActive) : area.isActive,
        deliveryRadius: deliveryRadius !== undefined ? parseFloat(deliveryRadius) : area.deliveryRadius,
        minimumDeliveryFee: minimumDeliveryFee !== undefined ? parseFloat(minimumDeliveryFee) : area.minimumDeliveryFee,
        pricePerKm: pricePerKm !== undefined ? parseFloat(pricePerKm) : area.pricePerKm,
      },
    });

    await logAuditAction(adminId, 'ADMIN_CHANGED_COVERAGE', 'COVERAGE', id, area, updated);

    return res.json(updated);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل تحديث المنطقة' });
  }
};

// 8. SUPPORT TICKETS MANAGEMENT
export const getAdminSupportTickets = async (req: Request, res: Response) => {
  try {
    const tickets = await prisma.supportTicket.findMany({
      orderBy: { createdAt: 'desc' },
      take: 50,
    });
    return res.json(tickets);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل جلب تذاكر الدعم' });
  }
};

// 9. AUDIT LOGS
export const getAdminAuditLogs = async (req: Request, res: Response) => {
  try {
    const { page = '1', limit = '30' } = req.query;
    const pageNum = parseInt(page as string, 10) || 1;
    const limitNum = parseInt(limit as string, 10) || 30;

    const [total, logs] = await Promise.all([
      prisma.auditLog.count(),
      prisma.auditLog.findMany({
        skip: (pageNum - 1) * limitNum,
        take: limitNum,
        orderBy: { createdAt: 'desc' },
      }),
    ]);

    return res.json({
      logs,
      pagination: { total, page: pageNum, limit: limitNum, totalPages: Math.ceil(total / limitNum) },
    });
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل جلب سجل العمليات' });
  }
};

// 10. PLATFORM SETTINGS
export const getAdminSettings = async (req: Request, res: Response) => {
  try {
    const settings = await prisma.platformSetting.findMany();
    const map: Record<string, string> = {};
    settings.forEach((s) => (map[s.key] = s.value));
    return res.json(map);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل جلب الإعدادات' });
  }
};

export const updateAdminSettings = async (req: Request, res: Response) => {
  try {
    const adminId = (req as AuthenticatedRequest).user?.id!;
    const body = req.body as Record<string, string>;

    for (const [key, value] of Object.entries(body)) {
      await prisma.platformSetting.upsert({
        where: { key },
        update: { value: String(value) },
        create: { key, value: String(value) },
      });
    }

    await logAuditAction(adminId, 'ADMIN_CHANGED_SETTINGS', 'SETTINGS', 'global', null, body);

    return res.json({ message: 'تم حفظ الإعدادات بنجاح' });
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل حفظ الإعدادات' });
  }
};

// 11. SUPER ADMIN USER MANAGEMENT
export const getAdminUsers = async (req: Request, res: Response) => {
  try {
    const adminUsers = await prisma.user.findMany({
      where: {
        role: { in: ['SUPER_ADMIN', 'ADMIN', 'OPERATIONS', 'FINANCE', 'SUPPORT'] },
      },
      select: {
        id: true,
        name: true,
        phone: true,
        email: true,
        role: true,
        isActive: true,
        createdAt: true,
      },
      orderBy: { createdAt: 'desc' },
    });
    return res.json(adminUsers);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل جلب مدراء النظام' });
  }
};

export const createAdminUser = async (req: Request, res: Response) => {
  try {
    const currentAdminId = (req as AuthenticatedRequest).user?.id!;
    const { name, phone, email, password, role } = req.body;

    if (!['SUPER_ADMIN', 'ADMIN', 'OPERATIONS', 'FINANCE', 'SUPPORT'].includes(role)) {
      return res.status(400).json({ error: 'دور غير صالح' });
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const user = await prisma.user.create({
      data: {
        name,
        phone,
        email,
        passwordHash,
        role,
        isVerified: true,
        adminProfile: { create: {} },
      },
      select: { id: true, name: true, phone: true, email: true, role: true },
    });

    await logAuditAction(currentAdminId, 'SUPER_ADMIN_CREATED_USER', 'USER', user.id, null, { role });

    return res.status(201).json(user);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل إنشاء حساب المدير' });
  }
};
