import { Request, Response } from 'express';
import { z } from 'zod';
import { prisma } from '../../utils/prisma';
import { AuthenticatedRequest } from '../../middleware/auth.middleware';
import { io } from '../../server';

const updateLocationSchema = z.object({
  latitude: z.number(),
  longitude: z.number(),
  heading: z.number().optional().default(0.0),
  speed: z.number().optional().default(0.0),
  orderId: z.string().optional(),
});

const updateStatusSchema = z.object({
  status: z.enum(['OFFLINE', 'AVAILABLE', 'BUSY']),
});

export const updateCourierLocation = async (req: Request, res: Response) => {
  try {
    const userId = (req as AuthenticatedRequest).user?.id;
    if (!userId) return res.status(401).json({ error: 'غير مصرح به' });

    const validated = updateLocationSchema.parse(req.body);

    const courierProfile = await prisma.courierProfile.update({
      where: { userId },
      data: {
        currentLatitude: validated.latitude,
        currentLongitude: validated.longitude,
        lastLocationUpdate: new Date(),
      },
    });

    if (validated.orderId) {
      await prisma.courierLocationLog.create({
        data: {
          courierId: userId,
          orderId: validated.orderId,
          latitude: validated.latitude,
          longitude: validated.longitude,
          heading: validated.heading,
          speed: validated.speed,
        },
      });

      // Broadcast location to order room
      io.to(`order_${validated.orderId}`).emit('courier.location_updated', {
        courierId: userId,
        orderId: validated.orderId,
        latitude: validated.latitude,
        longitude: validated.longitude,
        heading: validated.heading,
        speed: validated.speed,
      });
    }

    return res.json({ success: true, profile: courierProfile });
  } catch (error: any) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'موقع غير صالح', details: error.errors });
    }
    return res.status(500).json({ error: error.message || 'فشل تحديث الموقع' });
  }
};

export const updateCourierStatus = async (req: Request, res: Response) => {
  try {
    const userId = (req as AuthenticatedRequest).user?.id;
    if (!userId) return res.status(401).json({ error: 'غير مصرح به' });

    const validated = updateStatusSchema.parse(req.body);

    const profile = await prisma.courierProfile.update({
      where: { userId },
      data: {
        status: validated.status,
        isOnline: validated.status !== 'OFFLINE',
      },
    });

    return res.json(profile);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل تحديث حالة المندوب' });
  }
};
