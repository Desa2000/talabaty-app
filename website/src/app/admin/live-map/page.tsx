'use client';

import React, { useEffect, useMemo, useState } from 'react';
import { io, Socket } from 'socket.io-client';
import AdminMap, {
  AdminMapMarker,
  AdminRoutePoint,
} from '@/components/admin/AdminMap';
import { adminFetch, getAdminToken } from '@/lib/admin-api';

type CourierStatus = 'ONLINE' | 'BUSY' | 'OFFLINE';

interface LiveOrder {
  id: string;
  orderNumber?: string;
  status: string;
  etaMinutes?: number | null;
  distanceMeters?: number | null;

  store?: {
    id: string;
    name: string;
    latitude: number;
    longitude: number;
  } | null;

  customer?: {
    id: string;
    name?: string;
    latitude: number;
    longitude: number;
  } | null;

  routePath?: AdminRoutePoint[];
}

interface LiveCourier {
  id: string;
  name: string;
  phone?: string;
  status: CourierStatus;
  latitude: number | null;
  longitude: number | null;
  heading?: number | null;
  lastLocationAt?: string | null;
  activeOrder?: LiveOrder | null;
}

interface LiveMapResponse {
  couriers: LiveCourier[];
}

interface CourierLocationUpdate {
  courierId: string;
  orderId?: string | null;
  latitude: number;
  longitude: number;
  heading?: number;
  lastLocationAt?: string;
}

interface LiveRouteResponse {
  courierId: string;
  orderId: string;
  orderNumber: string;
  orderStatus: string;
  phase: 'TO_STORE' | 'TO_CUSTOMER';
  distanceMeters: number;
  durationSeconds: number;
  etaMinutes: number;
  encodedPolyline: string;
  provider:
    | 'GOOGLE_ROUTES'
    | 'FALLBACK_OSRM'
    | 'FALLBACK_HAVERSINE';
}

type Filter = 'ALL' | CourierStatus;

function decodePolyline(
  encoded: string
): AdminRoutePoint[] {
  if (!encoded) return [];

  const points: AdminRoutePoint[] = [];

  let index = 0;
  let latitude = 0;
  let longitude = 0;

  while (index < encoded.length) {
    let result = 0;
    let shift = 0;
    let byte: number;

    do {
      byte = encoded.charCodeAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20);

    const latitudeChange =
      result & 1
        ? ~(result >> 1)
        : result >> 1;

    latitude += latitudeChange;

    result = 0;
    shift = 0;

    do {
      byte = encoded.charCodeAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20);

    const longitudeChange =
      result & 1
        ? ~(result >> 1)
        : result >> 1;

    longitude += longitudeChange;

    points.push({
      lat: latitude / 1e5,
      lng: longitude / 1e5,
    });
  }

  return points;
}

export default function AdminLiveMapPage() {
  const [couriers, setCouriers] = useState<LiveCourier[]>([]);
  const [filter, setFilter] = useState<Filter>('ALL');
  const [selectedCourierId, setSelectedCourierId] =
    useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [selectedRoutePath, setSelectedRoutePath] =
    useState<AdminRoutePoint[]>([]);

  const [selectedRouteInfo, setSelectedRouteInfo] =
    useState<LiveRouteResponse | null>(null);

  const fetchLiveMap = async () => {
    try {
      const response =
        (await adminFetch('/admin/live-map')) as LiveMapResponse;

      setCouriers(
        Array.isArray(response?.couriers)
          ? response.couriers
          : [],
      );

      setError(null);
    } catch (err) {
      setError(
        err instanceof Error
          ? err.message
          : 'تعذر جلب بيانات العمليات المباشرة',
      );
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchLiveMap();

    // Temporary recovery refresh.
    // Socket.IO will provide the continuous movement updates.
    const interval = window.setInterval(fetchLiveMap, 15000);

    return () => window.clearInterval(interval);
  }, []);

  useEffect(() => {
    const token = getAdminToken();

    if (!token) {
      return;
    }

    const apiBase =
      process.env.NEXT_PUBLIC_API_URL ||
      'https://api.mytalabaty.com/api';

    const socketUrl = apiBase.replace(/\/api\/?$/, '');

    const socket: Socket = io(socketUrl, {
      transports: ['websocket', 'polling'],
      auth: {
        token,
      },
      forceNew: true,
    });

    socket.on(
      'courier.location_updated',
      (update: CourierLocationUpdate) => {
        if (
          !update ||
          typeof update.courierId !== 'string' ||
          typeof update.latitude !== 'number' ||
          typeof update.longitude !== 'number'
        ) {
          return;
        }

        setCouriers((current) =>
          current.map((courier) => {
            if (courier.id !== update.courierId) {
              return courier;
            }

            return {
              ...courier,
              latitude: update.latitude,
              longitude: update.longitude,
              heading:
                typeof update.heading === 'number'
                  ? update.heading
                  : courier.heading,
              lastLocationAt:
                update.lastLocationAt ||
                new Date().toISOString(),
            };
          }),
        );
      },
    );

    return () => {
      socket.off('courier.location_updated');
      socket.disconnect();
    };
  }, []);

  useEffect(() => {
    if (!selectedCourierId) {
      setSelectedRoutePath([]);
      setSelectedRouteInfo(null);
      return;
    }

    let cancelled = false;

    const fetchSelectedCourierRoute = async () => {
      try {
        const response =
          (await adminFetch(
            `/admin/live-map/${selectedCourierId}/route`,
          )) as LiveRouteResponse;

        if (cancelled) return;

        setSelectedRouteInfo(response);

        if (
          response.encodedPolyline &&
          response.provider !== 'FALLBACK_HAVERSINE'
        ) {
          setSelectedRoutePath(
            decodePolyline(response.encodedPolyline),
          );
        } else {
          // Never draw a fake straight-line route.
          setSelectedRoutePath([]);
        }
      } catch (err) {
        if (cancelled) return;

        setSelectedRoutePath([]);
        setSelectedRouteInfo(null);

        console.error(
          '[LiveMap] Selected courier route unavailable:',
          err,
        );
      }
    };

    fetchSelectedCourierRoute();

    const interval = window.setInterval(
      fetchSelectedCourierRoute,
      30000,
    );

    return () => {
      cancelled = true;
      window.clearInterval(interval);
    };
  }, [selectedCourierId]);

  const filteredCouriers = useMemo(() => {
    if (filter === 'ALL') return couriers;

    return couriers.filter(
      (courier) => courier.status === filter,
    );
  }, [couriers, filter]);

  const selectedCourier =
    couriers.find(
      (courier) => courier.id === selectedCourierId,
    ) ?? null;

  const markers = useMemo<AdminMapMarker[]>(() => {
    const result: AdminMapMarker[] = [];

    for (const courier of filteredCouriers) {
      if (
        courier.latitude == null ||
        courier.longitude == null
      ) {
        continue;
      }

      result.push({
        id: `courier-${courier.id}`,
        type: 'COURIER',
        lat: courier.latitude,
        lng: courier.longitude,
        heading: courier.heading ?? undefined,
        title: courier.name,
        subtitle:
          courier.activeOrder?.orderNumber
            ? `طلب ${courier.activeOrder.orderNumber}`
            : 'بدون طلب نشط',
        status: courier.status,
      });

      const order = courier.activeOrder;

      if (!order) continue;

      if (
        order.store &&
        Number.isFinite(order.store.latitude) &&
        Number.isFinite(order.store.longitude)
      ) {
        result.push({
          id: `store-${order.store.id}`,
          type: 'STORE',
          lat: order.store.latitude,
          lng: order.store.longitude,
          title: order.store.name,
          subtitle: order.orderNumber
            ? `طلب ${order.orderNumber}`
            : undefined,
        });
      }

      if (
        order.customer &&
        Number.isFinite(order.customer.latitude) &&
        Number.isFinite(order.customer.longitude)
      ) {
        result.push({
          id: `customer-${order.customer.id}-${order.id}`,
          type: 'CUSTOMER',
          lat: order.customer.latitude,
          lng: order.customer.longitude,
          title: order.customer.name || 'العميل',
          subtitle: order.orderNumber
            ? `طلب ${order.orderNumber}`
            : undefined,
        });
      }
    }

    return result;
  }, [filteredCouriers]);

  const selectedRoute = selectedRoutePath;

  const onlineCount = couriers.filter(
    (courier) => courier.status === 'ONLINE',
  ).length;

  const busyCount = couriers.filter(
    (courier) => courier.status === 'BUSY',
  ).length;

  const offlineCount = couriers.filter(
    (courier) => courier.status === 'OFFLINE',
  ).length;

  const formatDistance = (meters?: number | null) => {
    if (meters == null) return 'غير متاح';

    if (meters < 1000) {
      return `${Math.round(meters)} متر`;
    }

    return `${(meters / 1000).toFixed(1)} كم`;
  };

  const formatLastUpdate = (value?: string | null) => {
    if (!value) return 'غير متاح';

    const date = new Date(value);

    if (Number.isNaN(date.getTime())) {
      return 'غير متاح';
    }

    return date.toLocaleTimeString('ar-SD', {
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
    });
  };

  return (
    <div className="space-y-5" dir="rtl">
      <div className="flex flex-col xl:flex-row xl:items-end justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-white">
            العمليات المباشرة
          </h1>

          <p className="text-xs text-gray-400 mt-1">
            متابعة مواقع المناديب والطلبات والمتاجر والعملاء
            على خريطة Google.
          </p>
        </div>

        <div className="flex flex-wrap gap-2 text-xs">
          <div className="bg-[#16191D] border border-gray-800 px-4 py-2">
            متاح: {onlineCount}
          </div>

          <div className="bg-[#16191D] border border-gray-800 px-4 py-2">
            مشغول: {busyCount}
          </div>

          <div className="bg-[#16191D] border border-gray-800 px-4 py-2">
            غير متصل: {offlineCount}
          </div>
        </div>
      </div>

      <div className="flex flex-wrap gap-2">
        {[
          ['ALL', 'الكل'],
          ['ONLINE', 'المتاحون'],
          ['BUSY', 'المشغولون'],
          ['OFFLINE', 'غير المتصلين'],
        ].map(([value, label]) => (
          <button
            key={value}
            type="button"
            onClick={() => setFilter(value as Filter)}
            className={`px-4 py-2 text-xs font-semibold border transition-colors ${
              filter === value
                ? 'bg-[#FF5722] border-[#FF5722] text-white'
                : 'bg-[#16191D] border-gray-800 text-gray-300 hover:border-gray-600'
            }`}
          >
            {label}
          </button>
        ))}
      </div>

      {error && (
        <div className="border border-red-500/30 bg-red-500/10 px-4 py-3 text-xs text-red-300">
          {error}
        </div>
      )}

      <div className="grid grid-cols-1 xl:grid-cols-[300px_minmax(0,1fr)] gap-4">
        <aside className="bg-[#16191D] border border-gray-800 min-h-[680px] max-h-[calc(100vh-190px)] overflow-y-auto">
          <div className="px-4 py-4 border-b border-gray-800">
            <div className="text-sm font-bold text-white">
              المناديب
            </div>

            <div className="text-[11px] text-gray-500 mt-1">
              {filteredCouriers.length} نتيجة
            </div>
          </div>

          {loading && couriers.length === 0 ? (
            <div className="p-5 text-xs text-gray-500">
              جاري تحميل البيانات...
            </div>
          ) : filteredCouriers.length === 0 ? (
            <div className="p-5 text-xs text-gray-500">
              لا توجد بيانات مناديب مطابقة.
            </div>
          ) : (
            <div>
              {filteredCouriers.map((courier) => {
                const selected =
                  courier.id === selectedCourierId;

                return (
                  <button
                    key={courier.id}
                    type="button"
                    onClick={() =>
                      setSelectedCourierId(courier.id)
                    }
                    className={`w-full text-right px-4 py-4 border-b border-gray-800 transition-colors ${
                      selected
                        ? 'bg-[#FF5722]/10 border-r-2 border-r-[#FF5722]'
                        : 'hover:bg-gray-800/40'
                    }`}
                  >
                    <div className="flex items-center justify-between gap-3">
                      <span className="text-sm font-bold text-white truncate">
                        {courier.name}
                      </span>

                      <span
                        className={`text-[10px] font-semibold ${
                          courier.status === 'ONLINE'
                            ? 'text-emerald-400'
                            : courier.status === 'BUSY'
                              ? 'text-amber-400'
                              : 'text-gray-500'
                        }`}
                      >
                        {courier.status === 'ONLINE'
                          ? 'متاح'
                          : courier.status === 'BUSY'
                            ? 'مشغول'
                            : 'غير متصل'}
                      </span>
                    </div>

                    <div className="text-[11px] text-gray-500 mt-2">
                      {courier.activeOrder?.orderNumber
                        ? `الطلب ${courier.activeOrder.orderNumber}`
                        : 'لا يوجد طلب نشط'}
                    </div>
                  </button>
                );
              })}
            </div>
          )}
        </aside>

        <div className="min-w-0">
          <AdminMap
            markers={markers}
            routePath={selectedRoute}
            showCoverage={false}
            height="calc(100vh - 190px)"
          />
        </div>
      </div>

      {selectedCourier && (
        <div className="bg-[#16191D] border border-gray-800 p-5">
          <div className="grid grid-cols-2 md:grid-cols-4 xl:grid-cols-7 gap-5">
            <div>
              <div className="text-[10px] text-gray-500">
                المندوب
              </div>
              <div className="text-xs font-bold text-white mt-1">
                {selectedCourier.name}
              </div>
            </div>

            <div>
              <div className="text-[10px] text-gray-500">
                الحالة
              </div>
              <div className="text-xs font-bold text-white mt-1">
                {selectedCourier.status === 'ONLINE'
                  ? 'متاح'
                  : selectedCourier.status === 'BUSY'
                    ? 'مشغول'
                    : 'غير متصل'}
              </div>
            </div>

            <div>
              <div className="text-[10px] text-gray-500">
                الطلب
              </div>
              <div className="text-xs font-bold text-white mt-1">
                {selectedCourier.activeOrder?.orderNumber ||
                  'لا يوجد'}
              </div>
            </div>

            <div>
              <div className="text-[10px] text-gray-500">
                حالة الطلب
              </div>
              <div className="text-xs font-bold text-white mt-1">
                {selectedCourier.activeOrder?.status ||
                  'لا يوجد'}
              </div>
            </div>

            <div>
              <div className="text-[10px] text-gray-500">
                المسافة
              </div>
              <div className="text-xs font-bold text-white mt-1">
                {formatDistance(
                  selectedRouteInfo?.distanceMeters,
                )}
              </div>
            </div>

            <div>
              <div className="text-[10px] text-gray-500">
                زمن الوصول
              </div>
              <div className="text-xs font-bold text-white mt-1">
                {selectedRouteInfo?.etaMinutes != null
                  ? `${selectedRouteInfo.etaMinutes} دقيقة`
                  : 'غير متاح'}
              </div>
            </div>

            <div>
              <div className="text-[10px] text-gray-500">
                آخر تحديث للموقع
              </div>
              <div className="text-xs font-bold text-white mt-1">
                {formatLastUpdate(
                  selectedCourier.lastLocationAt,
                )}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
