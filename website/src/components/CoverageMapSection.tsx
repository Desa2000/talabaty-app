"use client";

import React, { useState } from "react";
import { useLanguage } from "@/context/LanguageContext";
import { FadeUp, StaggerContainer, StaggerChild } from "./motion/Animations";
import { motion, AnimatePresence } from "framer-motion";
import { MapPin, Navigation, CheckCircle2, Clock } from "lucide-react";

interface Region {
  id: string;
  nameAr: string;
  nameEn: string;
  status: "active" | "coming_soon" | "next_expansion";
  coordinates: { x: number; y: number }; // percentage position on Sudan map
  detailsAr: string;
  detailsEn: string;
}

export default function CoverageMapSection() {
  const { lang } = useLanguage();
  const isRTL = lang === "ar";
  const [activeRegion, setActiveRegion] = useState<Region | null>(null);

  // Regions confirmed by owner / project specs
  const regions: Region[] = [
    {
      id: "khartoum",
      nameAr: "الخرطوم",
      nameEn: "Khartoum",
      status: "active",
      coordinates: { x: 58, y: 38 },
      detailsAr: "خدمة التوصيل مفعلة بالكامل للمطاعم والسوبرماركت والصيدليات.",
      detailsEn: "Full delivery service active for restaurants, supermarkets & pharmacies.",
    },
    {
      id: "omdurman",
      nameAr: "أم درمان",
      nameEn: "Omdurman",
      status: "active",
      coordinates: { x: 52, y: 36 },
      detailsAr: "تغطية سريعة ومباشرة للمناطق السكنية والتجارية الرئيسية.",
      detailsEn: "Fast delivery coverage for key residential and commercial hubs.",
    },
    {
      id: "bahri",
      nameAr: "بحري",
      nameEn: "Bahri",
      status: "active",
      coordinates: { x: 62, y: 33 },
      detailsAr: "خدمة متكاملة للطلبات اليومية والتوصيل السريع.",
      detailsEn: "Integrated service for daily grocery and food orders.",
    },
    {
      id: "portsudan",
      nameAr: "بورتسودان",
      nameEn: "Port Sudan",
      status: "coming_soon",
      coordinates: { x: 82, y: 22 },
      detailsAr: "التجهيزات جارية لإطلاق التوصيل السريع قريباً جداً.",
      detailsEn: "Preparations underway to launch fast delivery very soon.",
    },
    {
      id: "wadmadani",
      nameAr: "ود مدني",
      nameEn: "Wad Madani",
      status: "coming_soon",
      coordinates: { x: 64, y: 48 },
      detailsAr: "خطوة التوسع القادمة لخدمة ولاية الجزيرة.",
      detailsEn: "Next expansion step to serve Al Jazirah state.",
    },
    {
      id: "atbara",
      nameAr: "عطبرة",
      nameEn: "Atbara",
      status: "next_expansion",
      coordinates: { x: 65, y: 24 },
      detailsAr: "ضمن خطة التوسع القادمة للمدن الرئيسية في السودان.",
      detailsEn: "Part of the upcoming expansion plan for Sudan's key cities.",
    },
  ];

  const getStatusBadge = (status: Region["status"]) => {
    switch (status) {
      case "active":
        return {
          label: isRTL ? "متاح الآن" : "Active Now",
          bg: "bg-emerald-50 text-emerald-700 border-emerald-200",
          dotBg: "bg-emerald-500",
        };
      case "coming_soon":
        return {
          label: isRTL ? "قريبًا" : "Coming Soon",
          bg: "bg-orange-50 text-[#FF5722] border-orange-200",
          dotBg: "bg-[#FF5722]",
        };
      case "next_expansion":
        return {
          label: isRTL ? "التوسع القادم" : "Next Expansion",
          bg: "bg-blue-50 text-blue-700 border-blue-200",
          dotBg: "bg-blue-500",
        };
    }
  };

  return (
    <section id="coverage" className="py-20 bg-[#FAF7F2] border-y border-[#F0EAE1] relative overflow-hidden">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        
        {/* Section Header */}
        <FadeUp>
          <div className="text-center max-w-2xl mx-auto mb-14">
            <span className="text-xs font-bold text-[#FF5722] bg-orange-100/80 px-3.5 py-1.5 rounded-full border border-orange-200/80 inline-block mb-3">
              <Navigation className="w-3.5 h-3.5 inline ml-1.5" />
              {isRTL ? "شبكة التوصيل" : "Delivery Network"}
            </span>
            <h2 className="text-2xl sm:text-4xl font-extrabold text-[#1A1D27] tracking-tight mb-3">
              {isRTL ? "مناطق التغطية" : "Coverage Areas"}
            </h2>
            <p className="text-base sm:text-lg text-gray-600 font-medium leading-relaxed">
              {isRTL
                ? "ننطلق من السودان ونتوسع خطوة بخطوة لنكون أقرب ليك."
                : "Starting from Sudan and expanding step by step to be closer to you."}
            </p>
          </div>
        </FadeUp>

        <div className="grid grid-cols-1 lg:grid-cols-12 gap-10 items-center">
          
          {/* Map Graphic Container (Col 7) */}
          <div className="lg:col-span-7 bg-white rounded-3xl p-6 sm:p-10 border border-[#F0EAE1] shadow-card relative">
            <div className="text-xs font-bold text-gray-400 mb-4 flex items-center justify-between">
              <span>{isRTL ? "خريطة التغطية في السودان" : "Sudan Coverage Map"}</span>
              <div className="flex items-center gap-3 text-[11px]">
                <span className="flex items-center gap-1"><span className="w-2 h-2 rounded-full bg-emerald-500" /> {isRTL ? "متاح" : "Active"}</span>
                <span className="flex items-center gap-1"><span className="w-2 h-2 rounded-full bg-[#FF5722]" /> {isRTL ? "قريبًا" : "Soon"}</span>
                <span className="flex items-center gap-1"><span className="w-2 h-2 rounded-full bg-blue-500" /> {isRTL ? "قادم" : "Next"}</span>
              </div>
            </div>

            {/* Sudan Map Silhouette SVG Canvas */}
            <div className="relative w-full aspect-[4/3] bg-[#FAF7F2]/60 rounded-2xl border border-gray-100 overflow-hidden flex items-center justify-center">
              
              {/* Sudan Map Silhouette Background SVG */}
              <svg
                viewBox="0 0 400 400"
                className="w-full h-full text-orange-500/10 fill-current"
                aria-label="Sudan Silhouette Map"
              >
                {/* Simplified Clean Sudan Map Silhouette Path */}
                <path d="M120 40 Q220 20 320 60 Q360 120 350 200 Q300 240 280 320 Q200 370 140 330 Q80 290 60 210 Q70 120 120 40 Z" />
              </svg>

              {/* Interactive Region Markers */}
              {regions.map((reg) => {
                const badgeInfo = getStatusBadge(reg.status);
                const isActive = activeRegion?.id === reg.id;

                return (
                  <div
                    key={reg.id}
                    style={{ left: `${reg.coordinates.x}%`, top: `${reg.coordinates.y}%` }}
                    className="absolute -translate-x-1/2 -translate-y-1/2 z-20"
                    onMouseEnter={() => setActiveRegion(reg)}
                    onMouseLeave={() => setActiveRegion(null)}
                  >
                    <button
                      type="button"
                      className="relative flex items-center justify-center p-2 group cursor-pointer focus:outline-none"
                    >
                      {/* Pulse Ring for Active Regions */}
                      {reg.status === "active" && (
                        <span className="absolute w-7 h-7 rounded-full bg-emerald-400/40 animate-ping" />
                      )}

                      {/* Pin Center Marker */}
                      <div className={`w-4 h-4 rounded-full ${badgeInfo.dotBg} border-2 border-white shadow-md transition-transform group-hover:scale-125`} />

                      {/* Region Label Tag */}
                      <span className="absolute bottom-full mb-1 text-[11px] font-bold text-gray-800 bg-white/90 backdrop-blur-sm px-2 py-0.5 rounded-md shadow-sm border border-gray-200 whitespace-nowrap pointer-events-none">
                        {isRTL ? reg.nameAr : reg.nameEn}
                      </span>
                    </button>

                    {/* Interactive Tooltip on Hover */}
                    <AnimatePresence>
                      {isActive && (
                        <motion.div
                          initial={{ opacity: 0, y: 10, scale: 0.95 }}
                          animate={{ opacity: 1, y: 0, scale: 1 }}
                          exit={{ opacity: 0, y: 5, scale: 0.95 }}
                          transition={{ duration: 0.2 }}
                          className="absolute bottom-full left-1/2 -translate-x-1/2 mb-8 w-52 bg-[#1A1D27] text-white p-3.5 rounded-xl shadow-xl z-30 pointer-events-none text-right"
                        >
                          <div className="flex items-center justify-between mb-1.5">
                            <span className="font-bold text-sm text-white">
                              {isRTL ? reg.nameAr : reg.nameEn}
                            </span>
                            <span className={`text-[10px] font-extrabold px-2 py-0.5 rounded-full border ${badgeInfo.bg}`}>
                              {badgeInfo.label}
                            </span>
                          </div>
                          <p className="text-xs text-gray-300 font-medium leading-relaxed">
                            {isRTL ? reg.detailsAr : reg.detailsEn}
                          </p>
                        </motion.div>
                      )}
                    </AnimatePresence>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Region Status Cards Grid (Col 5) */}
          <div className="lg:col-span-5 space-y-4">
            <StaggerContainer className="space-y-4">
              {regions.map((reg) => {
                const badgeInfo = getStatusBadge(reg.status);
                return (
                  <StaggerChild key={reg.id}>
                    <motion.div
                      whileHover={{ x: isRTL ? -4 : 4 }}
                      className="bg-white rounded-2xl p-4 sm:p-5 border border-[#F0EAE1] hover:border-orange-200 shadow-sm transition-all flex items-center justify-between text-right cursor-default"
                      onMouseEnter={() => setActiveRegion(reg)}
                      onMouseLeave={() => setActiveRegion(null)}
                    >
                      <div className="flex items-center gap-3">
                        <div className={`w-10 h-10 rounded-xl ${badgeInfo.bg} flex items-center justify-center border shrink-0`}>
                          <MapPin className="w-5 h-5" />
                        </div>
                        <div>
                          <h4 className="text-base font-bold text-[#1A1D27]">
                            {isRTL ? reg.nameAr : reg.nameEn}
                          </h4>
                          <p className="text-xs text-gray-500 font-medium">
                            {isRTL ? reg.detailsAr : reg.detailsEn}
                          </p>
                        </div>
                      </div>

                      <span className={`text-xs font-bold px-2.5 py-1 rounded-full border whitespace-nowrap ${badgeInfo.bg}`}>
                        {badgeInfo.label}
                      </span>
                    </motion.div>
                  </StaggerChild>
                );
              })}
            </StaggerContainer>
          </div>

        </div>

      </div>
    </section>
  );
}
