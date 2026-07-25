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
    latitude: z.number().min(-90).max(90),
    longitude: z.number().min(-180).max(180),
  }),
  destination: z.object({
    latitude: z.number().min(-90).max(90),
    longitude: z.number().min(-180).max(180),
  }),
  vehicleType: z.enum(['BICYCLE', 'ELECTRIC_BICYCLE', 'MOTORCYCLE']).optional().default('MOTORCYCLE'),
});

const deliveryFeeRequestSchema = z.object({
  storeId: z.string(),
  customerLatitude: z.number().min(-90).max(90),
  customerLongitude: z.number().min(-180).max(180),
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

    if (
      store.latitude == null ||
      store.longitude == null ||
      !Number.isFinite(store.latitude) ||
      !Number.isFinite(store.longitude)
    ) {
      return res.status(409).json({
        error: 'موقع المتجر غير مكتمل',
        code: 'STORE_LOCATION_INVALID',
      });
    }

    const routeResult = await RoutingService.computeRoute(
      {
        latitude: store.latitude,
        longitude: store.longitude,
      },
      { latitude: customerLatitude, longitude: customerLongitude }
    );

    const distanceKm = routeResult.distanceMeters / 1000;
    const pricePerKm = 500; // SDG per km
    const minimumFee = store.deliveryFee || 500;
    const calculatedFee = Math.max(minimumFee, Math.ceil(distanceKm * pricePerKm));

    const applicationFeeSettings = await prisma.platformSetting.findMany({
      where: {
        key: {
          in: ['applicationFeeEnabled', 'applicationFeeType', 'applicationFeeValue'],
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
      Number.isFinite(parsedFeeValue) && parsedFeeValue > 0 ? parsedFeeValue : 0;

    let applicationFee = 0;
    if (applicationFeeEnabled) {
      applicationFee = applicationFeeType === 'PERCENT'
        ? validated.subtotal * (Math.min(applicationFeeValue, 100) / 100)
        : applicationFeeValue;
    }
    applicationFee = Math.round(Math.max(0, applicationFee) * 100) / 100;
    const total = validated.subtotal + calculatedFee + applicationFee;

    return res.json({
      serviceAreaActive: true,
      locality: 'ولاية الخرطوم',
      distanceKm: Math.round(distanceKm * 100) / 100,
      distanceMeters: routeResult.distanceMeters,
      durationSeconds: routeResult.durationSeconds,
      deliveryFee: calculatedFee,
      applicationFee,
      serviceFee: applicationFee,
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
