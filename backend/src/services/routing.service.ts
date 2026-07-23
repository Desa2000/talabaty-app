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

export class RoutingService {
  private static googleApiKey = process.env.GOOGLE_ROUTES_API_KEY || '';

  /**
   * Computes route using Google Routes API with fallback to OSRM / Haversine
   */
  static async computeRoute(
    origin: RoutePoint,
    destination: RoutePoint,
    vehicleType: 'BICYCLE' | 'ELECTRIC_BICYCLE' | 'MOTORCYCLE' = 'MOTORCYCLE'
  ): Promise<RouteResponse> {
    if (this.googleApiKey && this.googleApiKey !== 'YOUR_GOOGLE_ROUTES_SERVER_KEY') {
      try {
        const response = await fetch(
          'https://routes.googleapis.com/directions/v2:computeRoutes',
          {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'X-Goog-Api-Key': this.googleApiKey,
              'X-Goog-FieldMask': 'routes.distanceMeters,routes.duration,routes.polyline.encodedPolyline',
            },
            body: JSON.stringify({
              origin: {
                location: {
                  latLng: {
                    latitude: origin.latitude,
                    longitude: origin.longitude,
                  },
                },
              },
              destination: {
                location: {
                  latLng: {
                    latitude: destination.latitude,
                    longitude: destination.longitude,
                  },
                },
              },
              travelMode: vehicleType === 'BICYCLE' ? 'BICYCLE' : 'TWO_WHEELER',
              routingPreference: 'TRAFFIC_AWARE',
              units: 'METRIC',
            }),
          }
        );

        if (response.ok) {
          const data: any = await response.json();
          if (data && data.routes && data.routes.length > 0) {
            const route = data.routes[0];
            const durationStr = route.duration || '0s';
            const durationSeconds = parseInt(durationStr.replace('s', ''), 10) || 0;

            return {
              distanceMeters: route.distanceMeters || 0,
              durationSeconds,
              encodedPolyline: route.polyline?.encodedPolyline || '',
              status: 'GOOGLE_ROUTES',
            };
          }
        }
      } catch (error) {
        console.warn('Google Routes API request failed, falling back to OSRM:', (error as Error).message);
      }
    }

    // Fallback 1: OSRM Public Routing
    try {
      const osrmUrl = `http://router.project-osrm.org/route/v1/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=polyline`;
      const res = await fetch(osrmUrl);

      if (res.ok) {
        const data: any = await res.json();
        if (data && data.code === 'Ok' && data.routes?.length > 0) {
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
      console.warn('OSRM routing failed, using Haversine fallback');
    }

    // Fallback 2: Haversine Straight-line
    const distKm = this.haversineDistance(origin, destination);
    const distMeters = distKm * 1000;
    const estSpeedKmh = vehicleType === 'BICYCLE' ? 15 : 30;
    const estDurationSec = (distKm / estSpeedKmh) * 3600;

    return {
      distanceMeters: Math.round(distMeters),
      durationSeconds: Math.round(estDurationSec),
      encodedPolyline: '',
      status: 'FALLBACK_HAVERSINE',
    };
  }

  /**
   * Geographic distance calculation (Haversine formula in KM)
   */
  static haversineDistance(p1: RoutePoint, p2: RoutePoint): number {
    const R = 6371; // Earth radius in km
    const dLat = this.toRad(p2.latitude - p1.latitude);
    const dLon = this.toRad(p2.longitude - p1.longitude);
    const lat1 = this.toRad(p1.latitude);
    const lat2 = this.toRad(p2.latitude);

    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.sin(dLon / 2) * Math.sin(dLon / 2) * Math.cos(lat1) * Math.cos(lat2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  private static toRad(deg: number): number {
    return (deg * Math.PI) / 180;
  }
}
