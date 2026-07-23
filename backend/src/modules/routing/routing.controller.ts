import { Request, Response } from 'express';
import { z } from 'zod';
import { RoutingService } from '../../services/routing.service';
import { prisma } from '../../utils/prisma';

// Active localities geofence polygons (Khartoum, Bahri, Omdurman)
const KHARTOUM_STATE_BOUNDS = {
  minLat: 15.4500,
  maxLat: 15.7500,
  minLng: 32.3500,
  maxLng: 32.7000,
};

const routeRequestSchema = z.object({
  origin: z.object({
    latitude: z.number(),
    longitude: z.number(),
  }),
  destination: z.object({
    latitude: z.number(),
    longitude: z.number(),
  }),
  vehicleType: z.enum(['BICYCLE', 'ELECTRIC_BICYCLE', 'MOTORCYCLE']).optional().default('MOTORCYCLE'),
});

const deliveryFeeRequestSchema = z.object({
  storeId: z.string(),
  customerLatitude: z.number(),
  customerLongitude: z.number(),
  subtotal: z.number().optional().default(0),
});

export const computeRouteHandler = async (req: Request, res: Response) => {
  try {
    const validated = routeRequestSchema.parse(req.body);
    const result = await RoutingService.computeRoute(
      validated.origin,
      validated.destination,
      validated.vehicleType
    );
    return res.json(result);
  } catch (error: any) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'إحداثيات المسار غير صالحة', details: error.errors });
    }
    return res.status(500).json({ error: error.message || 'فشل حساب المسار' });
  }
};

export const calculateDeliveryFeeHandler = async (req: Request, res: Response) => {
  try {
    const validated = deliveryFeeRequestSchema.parse(req.body);

    // 1. Geofence Active Service Area Check (Khartoum, Bahri, Omdurman)
    const { customerLatitude, customerLongitude } = validated;
    const isWithinActiveLocality =
      customerLatitude >= KHARTOUM_STATE_BOUNDS.minLat &&
      customerLatitude <= KHARTOUM_STATE_BOUNDS.maxLat &&
      customerLongitude >= KHARTOUM_STATE_BOUNDS.minLng &&
      customerLongitude <= KHARTOUM_STATE_BOUNDS.maxLng;

    if (!isWithinActiveLocality) {
      return res.status(400).json({
        error: 'عفواً، عنوان التوصيل المحدد خارج نطاق تغطية طلباتي الحالية في ولاية الخرطوم (الخرطوم، بحري، أم درمان)',
        code: 'OUT_OF_SERVICE_AREA',
        serviceAreaActive: false,
      });
    }

    const store = await prisma.store.findUnique({
      where: { id: validated.storeId },
    });

    if (!store) {
      return res.status(404).json({ error: 'المتجر غير موجود' });
    }

    const storeLat = store.latitude ?? 15.5007;
    const storeLng = store.longitude ?? 32.5599;

    const routeResult = await RoutingService.computeRoute(
      { latitude: storeLat, longitude: storeLng },
      { latitude: customerLatitude, longitude: customerLongitude }
    );

    const distanceKm = routeResult.distanceMeters / 1000;
    const pricePerKm = 500; // SDG per km
    const minimumFee = store.deliveryFee || 500;
    const calculatedFee = Math.max(minimumFee, Math.ceil(distanceKm * pricePerKm));

    const serviceFeeRate = 0.06; // 6% service fee
    const serviceFee = Math.ceil(validated.subtotal * serviceFeeRate);
    const total = validated.subtotal + calculatedFee + serviceFee;

    return res.json({
      serviceAreaActive: true,
      locality: 'ولاية الخرطوم',
      distanceKm: Math.round(distanceKm * 100) / 100,
      distanceMeters: routeResult.distanceMeters,
      durationSeconds: routeResult.durationSeconds,
      deliveryFee: calculatedFee,
      serviceFee,
      total,
      encodedPolyline: routeResult.encodedPolyline,
      routeStatus: routeResult.status,
    });
  } catch (error: any) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'بيانات حساب رسوم التوصيل غير صالحة' });
    }
    return res.status(500).json({ error: error.message || 'فشل حساب رسوم التوصيل' });
  }
};
