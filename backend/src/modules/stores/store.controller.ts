import { Request, Response } from 'express';
import { z } from 'zod';
import { prisma } from '../../utils/prisma';
import { AuthenticatedRequest } from '../../middleware/auth.middleware';

// Distance calculation helper (Haversine formula in KM)
function calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 6371; // Radius of the earth in km
  const dLat = (lat2 - lat1) * (Math.PI / 180);
  const dLon = (lon2 - lon1) * (Math.PI / 180);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * (Math.PI / 180)) * Math.cos(lat2 * (Math.PI / 180)) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c; // Distance in km
}

export const getStores = async (req: Request, res: Response) => {
  try {
    const { category, lat, lng, q, radius } = req.query;

    const whereClause: any = {
      isActive: true,
      merchant: {
        status: 'APPROVED',
      },
    };

    if (category && typeof category === 'string' && ['RESTAURANT', 'SUPERMARKET', 'PHARMACY'].includes(category.toUpperCase())) {
      whereClause.category = category.toUpperCase();
    }

    if (q && typeof q === 'string' && q.trim() !== '') {
      whereClause.OR = [
        { name: { contains: q, mode: 'insensitive' } },
        { description: { contains: q, mode: 'insensitive' } },
      ];
    }

    const stores = await prisma.store.findMany({
      where: whereClause,
      include: {
        categories: true,
        _count: {
          select: { products: { where: { isAvailable: true } } },
        },
      },
      orderBy: {
        isOpen: 'desc',
      },
    });

    const userLat = lat ? parseFloat(lat as string) : null;
    const userLng = lng ? parseFloat(lng as string) : null;
    const maxRadius = radius ? parseFloat(radius as string) : 25.0; // 25km default radius

    const result = stores
      .map((store) => {
        let distanceKm: number | null = null;
        if (userLat !== null && userLng !== null && store.latitude !== null && store.longitude !== null) {
          distanceKm = calculateDistance(userLat, userLng, store.latitude, store.longitude);
        }
        return {
          id: store.id,
          name: store.name,
          description: store.description,
          logoUrl: store.logoUrl,
          coverUrl: store.coverUrl,
          address: store.address,
          latitude: store.latitude,
          longitude: store.longitude,
          category: store.category,
          isOpen: store.isOpen,
          isActive: store.isActive,
          deliveryFee: store.deliveryFee,
          minOrderAmount: store.minOrderAmount,
          estimatedPrepTime: store.estimatedPrepTime,
          distanceKm: distanceKm !== null ? Math.round(distanceKm * 10) / 10 : null,
          productCount: store._count.products,
        };
      })
      .filter((store) => {
        if (userLat !== null && userLng !== null && store.distanceKm !== null) {
          return store.distanceKm <= maxRadius;
        }
        return true;
      })
      .sort((a, b) => {
        if (a.isOpen !== b.isOpen) return a.isOpen ? -1 : 1;
        if (a.distanceKm !== null && b.distanceKm !== null) return a.distanceKm - b.distanceKm;
        return 0;
      });

    return res.json(result);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل في جلب المتاجر' });
  }
};

export const getStoreById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const store = await prisma.store.findUnique({
      where: { id },
      include: {
        categories: {
          include: {
            products: {
              where: { isAvailable: true },
            },
          },
        },
        products: {
          where: { isAvailable: true },
          include: {
            category: true,
          },
        },
      },
    });

    if (!store || !store.isActive) {
      return res.status(404).json({ error: 'المتجر غير موجود أو غير متاح حالياً' });
    }

    return res.json(store);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل في تفاصيل المتجر' });
  }
};

const updateStoreSchema = z.object({
  name: z.string().min(2).optional(),
  description: z.string().optional(),
  logoUrl: z.string().optional(),
  coverUrl: z.string().optional(),
  address: z.string().optional(),
  latitude: z.number().optional(),
  longitude: z.number().optional(),
  isOpen: z.boolean().optional(),
  deliveryFee: z.number().optional(),
  estimatedPrepTime: z.number().optional(),
});

export const updateMerchantStore = async (req: Request, res: Response) => {
  try {
    const userId = (req as AuthenticatedRequest).user?.id;
    const { id } = req.params;

    const merchantProfile = await prisma.merchantProfile.findUnique({
      where: { userId },
    });

    if (!merchantProfile) {
      return res.status(403).json({ error: 'غير مصرح للتاجر' });
    }

    const store = await prisma.store.findFirst({
      where: { id, merchantId: merchantProfile.id },
    });

    if (!store) {
      return res.status(404).json({ error: 'المتجر غير موجود أو لا يخصك' });
    }

    const validated = updateStoreSchema.parse(req.body);

    const updated = await prisma.store.update({
      where: { id },
      data: validated,
    });

    return res.json(updated);
  } catch (error: any) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'بيانات غير صالحة', details: error.errors });
    }
    return res.status(500).json({ error: error.message || 'حدث خطأ أثناء التحديث' });
  }
};
