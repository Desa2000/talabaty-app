import { Request, Response } from 'express';
import { z } from 'zod';
import { prisma } from '../../utils/prisma';
import { AuthenticatedRequest } from '../../middleware/auth.middleware';

const createProductSchema = z.object({
  storeId: z.string().min(1),
  categoryId: z.string().optional(),
  categoryName: z.string().optional(),
  nameAr: z.string().min(2),
  nameEn: z.string().optional(),
  descriptionAr: z.string().optional(),
  descriptionEn: z.string().optional(),
  price: z.number().positive(),
  discountPrice: z.number().positive().optional(),
  imageUrl: z.string().optional(),
  isAvailable: z.boolean().optional().default(true),
  stock: z.number().int().nonnegative().optional().default(100),
  unit: z.string().optional().default('piece'),
  preparationNotes: z.string().optional(),
});

const updateProductSchema = createProductSchema.partial();

export const createProduct = async (req: Request, res: Response) => {
  try {
    const userId = (req as AuthenticatedRequest).user?.id;
    const validated = createProductSchema.parse(req.body);

    const merchantProfile = await prisma.merchantProfile.findUnique({
      where: { userId },
      include: { stores: true },
    });

    if (!merchantProfile) {
      return res.status(403).json({ error: 'ليس لديك حساب تاجر مصرح' });
    }

    const ownsStore = merchantProfile.stores.some((s) => s.id === validated.storeId);
    if (!ownsStore) {
      return res.status(403).json({ error: 'هذا المتجر لا يخص حسابك' });
    }

    let categoryId = validated.categoryId;
    if (!categoryId && validated.categoryName) {
      // Find or create category for store
      let category = await prisma.productCategory.findFirst({
        where: { storeId: validated.storeId, nameAr: validated.categoryName },
      });
      if (!category) {
        category = await prisma.productCategory.create({
          data: {
            storeId: validated.storeId,
            nameAr: validated.categoryName,
            nameEn: validated.categoryName,
          },
        });
      }
      categoryId = category.id;
    }

    const product = await prisma.product.create({
      data: {
        storeId: validated.storeId,
        categoryId: categoryId || null,
        nameAr: validated.nameAr,
        nameEn: validated.nameEn || validated.nameAr,
        descriptionAr: validated.descriptionAr,
        descriptionEn: validated.descriptionEn,
        price: validated.price,
        discountPrice: validated.discountPrice,
        imageUrl: validated.imageUrl,
        isAvailable: validated.isAvailable,
        stock: validated.stock,
        unit: validated.unit,
        preparationNotes: validated.preparationNotes,
      },
    });

    return res.status(201).json(product);
  } catch (error: any) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'بيانات المنتج غير صالحة', details: error.errors });
    }
    return res.status(500).json({ error: error.message || 'حدث خطأ أثناء إضافة المنتج' });
  }
};

export const updateProduct = async (req: Request, res: Response) => {
  try {
    const userId = (req as AuthenticatedRequest).user?.id;
    const { id } = req.params;

    const merchantProfile = await prisma.merchantProfile.findUnique({
      where: { userId },
      include: { stores: true },
    });

    if (!merchantProfile) {
      return res.status(403).json({ error: 'ليس لديك حساب تاجر مصرح' });
    }

    const existingProduct = await prisma.product.findUnique({
      where: { id },
      include: { store: true },
    });

    if (!existingProduct) {
      return res.status(404).json({ error: 'المنتج غير موجود' });
    }

    const ownsStore = merchantProfile.stores.some((s) => s.id === existingProduct.storeId);
    if (!ownsStore) {
      return res.status(403).json({ error: 'ليس لديك صلاحية لتعديل هذا المنتج' });
    }

    const validated = updateProductSchema.parse(req.body);

    const updated = await prisma.product.update({
      where: { id },
      data: validated,
    });

    return res.json(updated);
  } catch (error: any) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'بيانات غير صالحة', details: error.errors });
    }
    return res.status(500).json({ error: error.message || 'حدث خطأ أثناء تحديث المنتج' });
  }
};

export const deleteProduct = async (req: Request, res: Response) => {
  try {
    const userId = (req as AuthenticatedRequest).user?.id;
    const { id } = req.params;

    const merchantProfile = await prisma.merchantProfile.findUnique({
      where: { userId },
      include: { stores: true },
    });

    if (!merchantProfile) {
      return res.status(403).json({ error: 'ليس لديك حساب تاجر مصرح' });
    }

    const existingProduct = await prisma.product.findUnique({
      where: { id },
    });

    if (!existingProduct) {
      return res.status(404).json({ error: 'المنتج غير موجود' });
    }

    const ownsStore = merchantProfile.stores.some((s) => s.id === existingProduct.storeId);
    if (!ownsStore) {
      return res.status(403).json({ error: 'ليس لديك صلاحية لحذف هذا المنتج' });
    }

    // Soft delete / mark unavailable
    const updated = await prisma.product.update({
      where: { id },
      data: { isAvailable: false },
    });

    return res.json({ message: 'تم تعطيل المنتج بنجاح', product: updated });
  } catch (error: any) {
    return res.status(500).json({ error: error.message || 'حدث خطأ أثناء حذف المنتج' });
  }
};
