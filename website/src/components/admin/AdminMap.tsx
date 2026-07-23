'use client';

import React, { useEffect, useState } from 'react';
import { Store, Bike, MapPin, Navigation, ShieldCheck } from 'lucide-react';

interface MapMarker {
  id: string;
  type: 'CUSTOMER' | 'STORE' | 'COURIER';
  lat: number;
  lng: number;
  heading?: number;
  title: string;
  subtitle?: string;
  category?: string;
}

interface AdminMapProps {
  markers?: MapMarker[];
  showCoverage?: boolean;
  selectedOrder?: any;
  height?: string;
}

export default function AdminMap({
  markers = [],
  showCoverage = true,
  selectedOrder,
  height = '450px',
}: AdminMapProps) {
  const [activeTab, setActiveTab] = useState<'KHARTOUM' | 'BAHRI' | 'OMDURMAN'>('KHARTOUM');

  // Khartoum Localities Boundaries
  const coverageAreas = [
    { name: 'محلية الخرطوم', state: 'نشطة 🟢', center: '15.5640, 32.5840', radius: '20 كم', fee: '500 ج.س' },
    { name: 'محلية بحري', state: 'نشطة 🟢', center: '15.6150, 32.5320', radius: '18 كم', fee: '500 ج.س' },
    { name: 'محلية أم درمان', state: 'نشطة 🟢', center: '15.6500, 32.4800', radius: '22 كم', fee: '500 ج.س' },
  ];

  return (
    <div className="relative w-full rounded-2xl overflow-hidden border border-gray-800 bg-[#14171A] dir-rtl" style={{ height }} dir="rtl">
      {/* Branded Map Background Graphic Layer */}
      <div className="absolute inset-0 bg-[#16191D] opacity-95">
        {/* Grid / Road Network Simulation */}
        <svg className="w-full h-full opacity-20" xmlns="http://www.w3.org/2000/svg">
          <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
            <path d="M 40 0 L 0 0 0 40" fill="none" stroke="#FF5722" strokeWidth="0.8" />
          </pattern>
          <rect width="100%" height="100%" fill="url(#grid)" />
        </svg>

        {/* River Nile Visual Representation */}
        <svg className="absolute inset-0 w-full h-full pointer-events-none" xmlns="http://www.w3.org/2000/svg">
          <path
            d="M 300 0 Q 340 180 320 280 T 450 600"
            fill="none"
            stroke="#1D3557"
            strokeWidth="28"
            strokeLinecap="round"
            className="opacity-70"
          />
        </svg>

        {/* Coverage Polygons Overlay (Khartoum State Localities) */}
        {showCoverage && (
          <div className="absolute inset-0 pointer-events-none flex items-center justify-center">
            {/* Khartoum Locality Zone */}
            <div className="absolute top-1/3 left-1/2 -translate-x-1/2 -translate-y-1/2 w-64 h-64 rounded-full bg-[#FF5722]/15 border-2 border-[#FF5722] border-dashed animate-pulse flex items-center justify-center">
              <span className="text-[10px] font-bold text-[#FF5722] bg-[#16191D]/90 px-2 py-0.5 rounded-full border border-[#FF5722]/30">
                منطقة تغطية طلباتي النشطة - الخرطوم
              </span>
            </div>
          </div>
        )}
      </div>

      {/* Floating Map Legend */}
      <div className="absolute top-4 right-4 z-10 bg-[#16191D]/90 backdrop-blur-md border border-gray-800 rounded-xl px-3.5 py-2 text-xs flex items-center gap-4 text-gray-300 shadow-xl">
        <div className="flex items-center gap-1.5">
          <span className="w-2.5 h-2.5 rounded-full bg-[#FF5722]" />
          <span className="font-semibold text-white">الخرطوم النشطة</span>
        </div>
        <div className="flex items-center gap-1.5">
          <span className="w-2.5 h-2.5 rounded-full bg-emerald-400" />
          <span>المتجر</span>
        </div>
        <div className="flex items-center gap-1.5">
          <span className="w-2.5 h-2.5 rounded-full bg-blue-400" />
          <span>المندوب</span>
        </div>
        <div className="flex items-center gap-1.5">
          <span className="w-2.5 h-2.5 rounded-full bg-amber-400" />
          <span>عميل التوصيل</span>
        </div>
      </div>

      {/* Render Custom Interactive Markers */}
      <div className="absolute inset-0 z-10 flex items-center justify-center p-8">
        {/* Sample Customer Destination Marker */}
        <div className="absolute top-1/4 left-1/3 flex flex-col items-center group cursor-pointer">
          <div className="bg-white text-gray-900 text-[11px] font-bold px-2.5 py-1 rounded-full shadow-lg border border-[#FF5722] flex items-center gap-1">
            <MapPin className="w-3.5 h-3.5 text-[#FF5722]" />
            <span>نقطة التوصيل (الرياض)</span>
          </div>
          <div className="w-4 h-4 bg-[#FF5722] rounded-full border-2 border-white shadow-md -mt-1" />
        </div>

        {/* Sample Merchant Store Marker */}
        <div className="absolute top-1/2 right-1/3 flex flex-col items-center group cursor-pointer">
          <div className="bg-[#16191D] border border-emerald-500/40 text-emerald-400 text-[11px] font-bold px-2.5 py-1 rounded-full shadow-lg flex items-center gap-1">
            <Store className="w-3.5 h-3.5 text-emerald-400" />
            <span>مطعم البركة (الرياض)</span>
          </div>
          <div className="w-4 h-4 bg-emerald-500 rounded-full border-2 border-white shadow-md -mt-1" />
        </div>

        {/* Sample Courier Live Directional Arrow Marker */}
        <div className="absolute bottom-1/3 left-1/2 flex flex-col items-center group cursor-pointer">
          <div className="bg-[#FF5722] text-white text-[10px] font-extrabold px-2 py-0.5 rounded-full shadow-lg flex items-center gap-1 animate-bounce">
            <Bike className="w-3.5 h-3.5" />
            <span>المندوب (في الطريق)</span>
          </div>
          <div className="w-9 h-9 bg-[#FF5722] border-2 border-white rounded-full flex items-center justify-center text-white shadow-xl rotate-45 transform">
            <Navigation className="w-5 h-5 text-white" />
          </div>
        </div>
      </div>

      {/* Floating Info Card at Bottom */}
      <div className="absolute bottom-4 left-4 right-4 z-20 bg-[#16191D]/95 backdrop-blur-md border border-gray-800 rounded-2xl p-4 shadow-2xl flex flex-col sm:flex-row items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-[#FF5722]/15 border border-[#FF5722]/30 flex items-center justify-center text-[#FF5722]">
            <ShieldCheck className="w-5 h-5" />
          </div>
          <div>
            <div className="text-xs font-bold text-white">تغطية طلباتي المعتمدة في السودان 🇸🇩</div>
            <div className="text-[11px] text-gray-400 mt-0.5">
              محلية الخرطوم &bull; محلية بحري &bull; محلية أم درمان (خدمة 24/7)
            </div>
          </div>
        </div>

        <div className="flex items-center gap-2">
          {coverageAreas.map((area, idx) => (
            <div key={idx} className="bg-[#0F1114] border border-gray-800 rounded-xl px-3 py-1.5 text-[11px] font-semibold text-gray-300">
              {area.name}: <span className="text-emerald-400">{area.fee}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
