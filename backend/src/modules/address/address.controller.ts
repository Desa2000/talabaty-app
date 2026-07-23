import { Request, Response } from 'express';
import { z } from 'zod';
import { prisma } from '../../utils/prisma';
import { AuthenticatedRequest } from '../../middleware/auth.middleware';

const addressSchema = z.object({
  title: z.string().min(1).default('البيت'),
  city: z.string().optional().default('الخرطوم'),
  area: z.string().min(2),
  street: z.string().min(2),
  landmark: z.string().optional(),
  latitude: z.number(),
  longitude: z.number(),
  phone: z.string().min(6),
});

export const getAddresses = async (req: Request, res: Response) => {
  try {
    const userId = (req as AuthenticatedRequest).user?.id;
    if (!userId) return res.status(401).json({ error: 'غير مصرح به' });

    const addresses = await prisma.address.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });

    return res.json(addresses);
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل جلب العناوين' });
  }
};

export const createAddress = async (req: Request, res: Response) => {
  try {
    const userId = (req as AuthenticatedRequest).user?.id;
    if (!userId) return res.status(401).json({ error: 'غير مصرح به' });

    const validated = addressSchema.parse(req.body);

    const address = await prisma.address.create({
      data: {
        userId,
        title: validated.title,
        city: validated.city || 'الخرطوم',
        area: validated.area,
        street: validated.street,
        landmark: validated.landmark,
        latitude: validated.latitude,
        longitude: validated.longitude,
        phone: validated.phone,
      },
    });

    return res.status(201).json(address);
  } catch (error: any) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'بيانات العنوان غير صالحة', details: error.errors });
    }
    return res.status(500).json({ error: error.message || 'فشل إضافة العنوان' });
  }
};

export const deleteAddress = async (req: Request, res: Response) => {
  try {
    const userId = (req as AuthenticatedRequest).user?.id;
    const { id } = req.params;

    const existing = await prisma.address.findFirst({
      where: { id, userId },
    });

    if (!existing) {
      return res.status(404).json({ error: 'العنوان غير موجود' });
    }

    await prisma.address.delete({
      where: { id },
    });

    return res.json({ message: 'تم حذف العنوان بنجاح' });
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'فشل حذف العنوان' });
  }
};
