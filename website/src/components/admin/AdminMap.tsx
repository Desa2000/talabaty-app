'use client';

import React, { useEffect, useRef, useState } from 'react';

export interface AdminMapMarker {
  id: string;
  type: 'CUSTOMER' | 'STORE' | 'COURIER';
  lat: number;
  lng: number;
  heading?: number;
  title: string;
  subtitle?: string;
  status?: 'ONLINE' | 'BUSY' | 'OFFLINE';
}

export interface AdminRoutePoint {
  lat: number;
  lng: number;
}

interface AdminMapProps {
  markers?: AdminMapMarker[];
  routePath?: AdminRoutePoint[];
  showCoverage?: boolean;
  height?: string;
}

let googleMapsPromise: Promise<any> | null = null;

function loadGoogleMaps(): Promise<any> {
  if (typeof window === 'undefined') {
    return Promise.reject(new Error('Google Maps requires a browser.'));
  }

  const existingGoogle = (window as any).google;
  if (existingGoogle?.maps) {
    return Promise.resolve(existingGoogle);
  }

  if (googleMapsPromise) {
    return googleMapsPromise;
  }

  const apiKey = process.env.NEXT_PUBLIC_GOOGLE_MAPS_API_KEY;

  if (!apiKey) {
    return Promise.reject(
      new Error('NEXT_PUBLIC_GOOGLE_MAPS_API_KEY is not configured.'),
    );
  }

  googleMapsPromise = new Promise((resolve, reject) => {
    const callbackName = '__talabatyGoogleMapsReady';

    (window as any)[callbackName] = () => {
      const google = (window as any).google;

      delete (window as any)[callbackName];

      if (google?.maps) {
        resolve(google);
      } else {
        reject(new Error('Google Maps failed to initialize.'));
      }
    };

    const existingScript = document.getElementById(
      'talabaty-google-maps-script',
    ) as HTMLScriptElement | null;

    if (existingScript) {
      const check = window.setInterval(() => {
        const google = (window as any).google;

        if (google?.maps) {
          window.clearInterval(check);
          resolve(google);
        }
      }, 100);

      window.setTimeout(() => {
        window.clearInterval(check);
      }, 15000);

      return;
    }

    const script = document.createElement('script');

    script.id = 'talabaty-google-maps-script';
    script.async = true;
    script.defer = true;

    script.src =
      'https://maps.googleapis.com/maps/api/js' +
      `?key=${encodeURIComponent(apiKey)}` +
      '&loading=async' +
      '&v=weekly' +
      '&libraries=marker' +
      '&language=ar' +
      '&region=SD' +
      `&callback=${callbackName}`;

    script.onerror = () => {
      googleMapsPromise = null;
      reject(new Error('Unable to load Google Maps.'));
    };

    document.head.appendChild(script);
  });

  return googleMapsPromise;
}

function markerColor(marker: AdminMapMarker): string {
  if (marker.type === 'COURIER') {
    if (marker.status === 'OFFLINE') return '#6B7280';
    if (marker.status === 'BUSY') return '#F59E0B';
    return '#FF5722';
  }

  if (marker.type === 'STORE') {
    return '#059669';
  }

  return '#2563EB';
}

function markerTypeLabel(marker: AdminMapMarker): string {
  switch (marker.type) {
    case 'COURIER':
      return 'مندوب';
    case 'STORE':
      return 'متجر';
    case 'CUSTOMER':
      return 'عميل';
  }
}

function escapeHtml(value: string): string {
  return value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#039;');
}

function createMarkerContent(marker: AdminMapMarker): HTMLElement {
  const root = document.createElement('div');
  const color = markerColor(marker);

  root.style.background = '#16191D';
  root.style.border = `2px solid ${color}`;
  root.style.borderRadius = '10px';
  root.style.padding = '7px 10px';
  root.style.color = '#FFFFFF';
  root.style.fontFamily = 'inherit';
  root.style.fontSize = '11px';
  root.style.fontWeight = '700';
  root.style.whiteSpace = 'nowrap';
  root.style.boxShadow = '0 8px 24px rgba(0,0,0,0.22)';
  root.style.cursor = 'pointer';
  root.style.direction = 'rtl';

  root.textContent = marker.title || markerTypeLabel(marker);

  return root;
}

export default function AdminMap({
  markers = [],
  routePath = [],
  showCoverage = false,
  height = '450px',
}: AdminMapProps) {
  const mapElementRef = useRef<HTMLDivElement | null>(null);
  const mapRef = useRef<any>(null);

  const markerInstancesRef = useRef<any[]>([]);
  const coverageInstancesRef = useRef<any[]>([]);
  const routeInstanceRef = useRef<any>(null);

  const [googleApi, setGoogleApi] = useState<any>(null);
  const [mapError, setMapError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    const initialize = async () => {
      try {
        const google = await loadGoogleMaps();

        if (cancelled || !mapElementRef.current) {
          return;
        }

        const { Map } = await google.maps.importLibrary('maps');

        await google.maps.importLibrary('marker');

        const mapId =
          process.env.NEXT_PUBLIC_GOOGLE_MAPS_MAP_ID || 'DEMO_MAP_ID';

        const map = new Map(mapElementRef.current, {
          center: {
            lat: 15.564,
            lng: 32.584,
          },
          zoom: 12,
          mapId,
          disableDefaultUI: true,
          zoomControl: true,
          fullscreenControl: true,
          mapTypeControl: false,
          streetViewControl: false,
          clickableIcons: false,
          gestureHandling: 'greedy',
        });

        mapRef.current = map;
        setGoogleApi(google);

        if (showCoverage) {
          const areas = [
            {
              center: { lat: 15.564, lng: 32.584 },
              radius: 10000,
            },
            {
              center: { lat: 15.615, lng: 32.532 },
              radius: 10000,
            },
            {
              center: { lat: 15.65, lng: 32.48 },
              radius: 10000,
            },
          ];

          coverageInstancesRef.current = areas.map(
            (area) =>
              new google.maps.Circle({
                map,
                center: area.center,
                radius: area.radius,
                strokeColor: '#FF5722',
                strokeOpacity: 0.65,
                strokeWeight: 1.5,
                fillColor: '#FF5722',
                fillOpacity: 0.06,
                clickable: false,
              }),
          );
        }
      } catch (error) {
        console.error('[AdminMap]', error);

        if (!cancelled) {
          setMapError(
            error instanceof Error
              ? error.message
              : 'تعذر تحميل خريطة Google',
          );
        }
      }
    };

    initialize();

    return () => {
      cancelled = true;

      markerInstancesRef.current.forEach((marker) => {
        marker.map = null;
      });

      coverageInstancesRef.current.forEach((circle) => {
        circle.setMap(null);
      });

      routeInstanceRef.current?.setMap(null);

      markerInstancesRef.current = [];
      coverageInstancesRef.current = [];
      routeInstanceRef.current = null;
    };
  }, [showCoverage]);

  useEffect(() => {
    if (!googleApi || !mapRef.current) {
      return;
    }

    let cancelled = false;

    const renderMarkers = async () => {
      const google = googleApi;
      const map = mapRef.current;

      const { AdvancedMarkerElement } =
        await google.maps.importLibrary('marker');

      if (cancelled) {
        return;
      }

      markerInstancesRef.current.forEach((marker) => {
        marker.map = null;
      });

      markerInstancesRef.current = [];

      const bounds = new google.maps.LatLngBounds();

      for (const markerData of markers) {
        if (
          !Number.isFinite(markerData.lat) ||
          !Number.isFinite(markerData.lng)
        ) {
          continue;
        }

        const content = createMarkerContent(markerData);

        const marker = new AdvancedMarkerElement({
          map,
          position: {
            lat: markerData.lat,
            lng: markerData.lng,
          },
          title: markerData.title,
          content,
          zIndex: markerData.type === 'COURIER' ? 30 : 20,
        });

        const infoContent = document.createElement('div');

        infoContent.style.direction = 'rtl';
        infoContent.style.minWidth = '180px';
        infoContent.style.color = '#111827';
        infoContent.style.fontFamily = 'inherit';

        infoContent.innerHTML = `
          <div style="font-weight:700;font-size:13px;margin-bottom:4px">
            ${escapeHtml(markerData.title)}
          </div>
          <div style="font-size:11px;color:#4B5563">
            ${escapeHtml(markerTypeLabel(markerData))}
          </div>
          ${
            markerData.subtitle
              ? `<div style="font-size:11px;color:#4B5563;margin-top:4px">${escapeHtml(markerData.subtitle)}</div>`
              : ''
          }
        `;

        const infoWindow = new google.maps.InfoWindow({
          content: infoContent,
        });

        content.addEventListener('click', () => {
          infoWindow.open({
            map,
            anchor: marker,
          });
        });

        markerInstancesRef.current.push(marker);
        bounds.extend(marker.position);
      }

      if (markers.length === 1) {
        map.panTo({
          lat: markers[0].lat,
          lng: markers[0].lng,
        });
      } else if (markers.length > 1) {
        map.fitBounds(bounds, 70);
      }
    };

    renderMarkers();

    return () => {
      cancelled = true;
    };
  }, [googleApi, markers]);

  useEffect(() => {
    if (!googleApi || !mapRef.current) {
      return;
    }

    if (routeInstanceRef.current) {
      routeInstanceRef.current.setMap(null);
      routeInstanceRef.current = null;
    }

    if (routePath.length < 2) {
      return;
    }

    routeInstanceRef.current = new googleApi.maps.Polyline({
      map: mapRef.current,
      path: routePath,
      geodesic: true,
      strokeColor: '#FF5722',
      strokeOpacity: 0.92,
      strokeWeight: 5,
    });

    const bounds = new googleApi.maps.LatLngBounds();

    routePath.forEach((point) => {
      bounds.extend(point);
    });

    mapRef.current.fitBounds(bounds, 80);
  }, [googleApi, routePath]);

  if (mapError) {
    return (
      <div
        className="w-full bg-[#16191D] border border-gray-800 flex items-center justify-center text-center px-6"
        style={{ height }}
        dir="rtl"
      >
        <div>
          <div className="text-sm font-bold text-white">
            خريطة Google غير متاحة حالياً
          </div>

          <div className="text-xs text-gray-400 mt-2">
            تأكد من إعداد مفتاح Maps JavaScript API و Map ID الخاص بطلباتي.
          </div>
        </div>
      </div>
    );
  }

  return (
    <div
      className="relative w-full overflow-hidden border border-gray-800 bg-[#16191D]"
      style={{ height }}
      dir="rtl"
    >
      <div ref={mapElementRef} className="absolute inset-0" />

      <div className="absolute top-4 right-4 z-10 bg-[#16191D]/95 border border-gray-800 px-4 py-3 text-right shadow-xl">
        <div className="text-xs font-bold text-white">
          العمليات المباشرة
        </div>

        <div className="text-[11px] text-gray-400 mt-1">
          المواقع والمسارات يتم تحديثها من السيرفر
        </div>
      </div>
    </div>
  );
}
