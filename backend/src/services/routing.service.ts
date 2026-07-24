export interface RoutePoint {
  latitude: number;
  longitude: number;
}

export interface RouteResponse {
  distanceMeters: number;
  durationSeconds: number;
  encodedPolyline: string;
  status: 'GOOGLE_ROUTES' | 'FALLBACK_OSRM' | 'FALLBACK_HAVERSINE';
}

export interface RouteMatrixEntry {
  courierId: string;
  distanceMeters: number;
  durationSeconds: number;
}

// ────────────────────────────────────────────────────────────────────────────
// Usage monitoring counters (in-memory; reset on service restart)
// These are surfaced via GET /api/admin/routing-stats
// ────────────────────────────────────────────────────────────────────────────
export const routingStats = {
  computeRouteCalls: 0,
  routeMatrixCalls: 0,
  routeMatrixElementsTotal: 0,
  osrmFallbackCalls: 0,
  haversineFallbackCalls: 0,
  lastResetAt: new Date().toISOString(),
};

export class RoutingService {
  private static googleApiKey = process.env.GOOGLE_ROUTES_API_KEY || '';

  // ─── Public: Compute single route ──────────────────────────────────────────
  static async computeRoute(
    origin: RoutePoint,
    destination: RoutePoint,
    vehicleType: 'BICYCLE' | 'ELECTRIC_BICYCLE' | 'MOTORCYCLE' = 'MOTORCYCLE'
  ): Promise<RouteResponse> {
    if (this.isGoogleConfigured()) {
      try {
        routingStats.computeRouteCalls++;
        const travelMode = vehicleType === 'BICYCLE' ? 'BICYCLE' : 'TWO_WHEELER';

        const response = await fetch(
          'https://routes.googleapis.com/directions/v2:computeRoutes',
          {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'X-Goog-Api-Key': this.googleApiKey,
              // Field mask — only request what we need (cost control)
              'X-Goog-FieldMask':
                'routes.distanceMeters,routes.duration,routes.polyline.encodedPolyline',
            },
            body: JSON.stringify({
              origin: { location: { latLng: { latitude: origin.latitude, longitude: origin.longitude } } },
              destination: { location: { latLng: { latitude: destination.latitude, longitude: destination.longitude } } },
              travelMode,
              routingPreference: 'TRAFFIC_UNAWARE', // Essentials tier — no real-time traffic
              units: 'METRIC',
            }),
          }
        );

        if (response.ok) {
          const data: any = await response.json();
          if (data?.routes?.length > 0) {
            const route = data.routes[0];
            const durationSeconds = parseInt((route.duration || '0s').replace('s', ''), 10) || 0;
            return {
              distanceMeters: route.distanceMeters || 0,
              durationSeconds,
              encodedPolyline: route.polyline?.encodedPolyline || '',
              status: 'GOOGLE_ROUTES',
            };
          }
        }
      } catch (e) {
        console.warn('[RoutingService] Google Routes API failed:', (e as Error).message);
      }
    }

    // Fallback 1: OSRM (emergency only)
    try {
      routingStats.osrmFallbackCalls++;
      const url = `http://router.project-osrm.org/route/v1/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=polyline`;
      const res = await fetch(url, { signal: AbortSignal.timeout(4000) });
      if (res.ok) {
        const data: any = await res.json();
        if (data?.code === 'Ok' && data.routes?.length > 0) {
          const route = data.routes[0];
          return {
            distanceMeters: route.distance || 0,
            durationSeconds: route.duration || 0,
            encodedPolyline: route.geometry || '',
            status: 'FALLBACK_OSRM',
          };
        }
      }
    } catch (e) {
      console.warn('[RoutingService] OSRM fallback failed, using Haversine');
    }

    // Fallback 2: Haversine straight-line
    routingStats.haversineFallbackCalls++;
    const distKm = this.haversineDistance(origin, destination);
    const estSpeedKmh = vehicleType === 'BICYCLE' ? 14 : 28;
    return {
      distanceMeters: Math.round(distKm * 1000),
      durationSeconds: Math.round((distKm / estSpeedKmh) * 3600),
      encodedPolyline: '',
      status: 'FALLBACK_HAVERSINE',
    };
  }

  // ─── Public: Courier shortlist using Haversine + Route Matrix ──────────────
  /**
   * 1. Haversine pre-filter → top N candidates (free, no API call)
   * 2. Route Matrix (Essentials) → pick best by road duration
   */
  static async findBestCourier(
    candidates: Array<{ courierId: string; lat: number; lng: number }>,
    merchantLat: number,
    merchantLng: number,
    maxCandidates = 5
  ): Promise<string | null> {
    if (candidates.length === 0) return null;

    // Step 1: Haversine shortlist (free)
    const ranked = candidates
      .map((c) => ({
        ...c,
        distKm: this.haversineDistance(
          { latitude: c.lat, longitude: c.lng },
          { latitude: merchantLat, longitude: merchantLng }
        ),
      }))
      .sort((a, b) => a.distKm - b.distKm)
      .slice(0, maxCandidates);

    if (ranked.length === 0) return null;

    // Step 2: Route Matrix on shortlist only (if Google is configured)
    if (this.isGoogleConfigured() && ranked.length > 1) {
      try {
        const elementCount = ranked.length; // N origins × 1 destination
        routingStats.routeMatrixCalls++;
        routingStats.routeMatrixElementsTotal += elementCount;

        const response = await fetch(
          'https://routes.googleapis.com/distanceMatrix/v2:computeRouteMatrix',
          {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'X-Goog-Api-Key': this.googleApiKey,
              'X-Goog-FieldMask': 'originIndex,distanceMeters,duration,status',
            },
            body: JSON.stringify({
              origins: ranked.map((c, i) => ({
                waypoint: { location: { latLng: { latitude: c.lat, longitude: c.lng } } },
                routeModifiers: {},
              })),
              destinations: [
                {
                  waypoint: {
                    location: { latLng: { latitude: merchantLat, longitude: merchantLng } },
                  },
                },
              ],
              travelMode: 'TWO_WHEELER',
              routingPreference: 'TRAFFIC_UNAWARE',
            }),
          }
        );

        if (response.ok) {
          const matrix: any[] = (await response.json()) as any[];
          let bestIdx = 0;
          let bestDuration = Infinity;
          for (const entry of matrix) {
            if (entry.status?.code === 0 || !entry.status) {
              const dur = parseInt((entry.duration || '99999s').replace('s', ''), 10);
              if (dur < bestDuration) {
                bestDuration = dur;
                bestIdx = entry.originIndex ?? 0;
              }
            }
          }
          return ranked[bestIdx]?.courierId ?? ranked[0].courierId;
        }
      } catch (e) {
        console.warn('[RoutingService] Route Matrix failed, using Haversine winner');
      }
    }

    // Fallback: closest by Haversine
    return ranked[0].courierId;
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────
  static isGoogleConfigured(): boolean {
    return (
      !!this.googleApiKey &&
      this.googleApiKey !== '' &&
      this.googleApiKey !== 'YOUR_GOOGLE_ROUTES_SERVER_KEY'
    );
  }

  static haversineDistance(p1: RoutePoint, p2: RoutePoint): number {
    const R = 6371;
    const dLat = this.toRad(p2.latitude - p1.latitude);
    const dLon = this.toRad(p2.longitude - p1.longitude);
    const a =
      Math.sin(dLat / 2) ** 2 +
      Math.cos(this.toRad(p1.latitude)) * Math.cos(this.toRad(p2.latitude)) * Math.sin(dLon / 2) ** 2;
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  }

  private static toRad(deg: number): number {
    return (deg * Math.PI) / 180;
  }
}
