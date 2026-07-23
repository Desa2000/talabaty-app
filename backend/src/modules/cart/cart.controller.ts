import { Request, Response } from 'express';
import { z } from 'zod';
import { prisma } from '../../utils/prisma';

const validateCartSchema = z.object({
  storeId: z.string().min(1),
  items: z.array(
    z.object({
      productId: z.string().min(1),
      quantity: z.number().int().positive(),
    })
  ).min(1),
  deliveryLatitude: z.number().optional(),
  deliveryLongitude: z.number().optional(),
});

export const validateCart = async (req: Request, res: Response) => {
  try {
    const validated = validateCartSchema.parse(req.body);

    const store = await prisma.store.findUnique({
      where: { id: validated.storeId },
    });

    if (!store || !store.isActive) {
      return res.status(400).json({ error: 'المتجر المطلوب غير متاح حالياً' });
    }

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
        error: 'بعض المنتجات في السلة غير متوفرة أو لم تعد معروضة في هذا المتجر',
        code: 'PRODUCT_UNAVAILABLE',
      });
    }

    let subtotal = 0;
    let totalDiscount = 0;

    const validatedItems = validated.items.map((item) => {
      const dbProduct = dbProducts.find((p) => p.id === item.productId)!;
      const unitPrice = dbProduct.discountPrice && dbProduct.discountPrice > 0 ? dbProduct.discountPrice : dbProduct.price;
      const itemSubtotal = unitPrice * item.quantity;
      
      subtotal += itemSubtotal;
      if (dbProduct.discountPrice && dbProduct.discountPrice < dbProduct.price) {
        totalDiscount += (dbProduct.price - dbProduct.discountPrice) * item.quantity;
      }

      return {
        productId: dbProduct.id,
        productName: dbProduct.nameAr,
        unitPrice,
        originalPrice: dbProduct.price,
        quantity: item.quantity,
        subtotal: itemSubtotal,
        imageUrl: dbProduct.imageUrl,
      };
    });

    const deliveryFee = store.deliveryFee || 500.0;
    const total = subtotal + deliveryFee;

    return res.json({
      store: {
        id: store.id,
        name: store.name,
        category: store.category,
        deliveryFee,
        minOrderAmount: store.minOrderAmount,
        estimatedPrepTime: store.estimatedPrepTime,
      },
      items: validatedItems,
      subtotal,
      discount: totalDiscount,
      deliveryFee,
      total,
      isMinOrderMet: subtotal >= store.minOrderAmount,
    });
  } catch (error: any) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'بيانات السلة غير صالحة', details: error.errors });
    }
    return res.status(500).json({ error: error.message || 'حدث خطأ أثناء حساب السلة' });
  }
};
