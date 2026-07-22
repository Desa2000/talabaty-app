"use client";

import React from "react";
import Link from "next/link";
import Image from "next/image";
import { useLanguage } from "@/context/LanguageContext";
import { Download, Store, Zap, ShieldCheck, Star, MapPin, Clock } from "lucide-react";

export default function Hero() {
  const { t } = useLanguage();

  return (
    <section className="relative overflow-hidden bg-gradient-to-b from-[#FFFDF9] via-[#FFF8F2] to-white pt-10 pb-20 lg:pt-16 lg:pb-28">
      {/* Background Subtle Orange Ambient Glow */}
      <div className="absolute top-0 right-1/4 w-96 h-96 bg-orange-400/10 rounded-full blur-3xl pointer-events-none" />
      <div className="absolute top-1/3 left-10 w-80 h-80 bg-amber-300/10 rounded-full blur-3xl pointer-events-none" />

      {/* Khartoum / Sudanese Silhouette Graphic Subtle Pattern (SVG overlay with low opacity) */}
      <div className="absolute inset-x-0 bottom-0 h-32 opacity-[0.04] pointer-events-none bg-[radial-gradient(#FF5722_1px,transparent_1px)] [background-size:16px_16px]" />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-8 items-center">
          
          {/* Text Content Column (Col 7) */}
          <div className="lg:col-span-7 text-center lg:text-right flex flex-col items-center lg:items-start">
            
            {/* Top Badge */}
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-orange-100/70 border border-orange-200/80 text-[#FF5722] text-xs sm:text-sm font-bold mb-6 shadow-sm">
              <Zap className="w-4 h-4 fill-[#FF5722]" />
              <span>المنصة السودانية الأولى للتوصيل السريع 🇸🇩</span>
            </div>

            {/* Main Headline */}
            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold text-[#1A1D27] tracking-tight leading-[1.15] mb-6">
              <span>{t("heroTitlePrefix")}</span>{" "}
              <span className="block mt-2 text-[#FF5722] drop-shadow-sm">
                {t("heroTitleMain")}
              </span>
            </h1>

            {/* Subtitle Paragraph */}
            <p className="text-lg sm:text-xl text-gray-600 font-medium max-w-2xl leading-relaxed mb-8">
              {t("heroDescription")}
            </p>

            {/* Action Buttons */}
            <div className="flex flex-col sm:flex-row items-center gap-4 w-full sm:w-auto mb-10">
              <Link
                href="#download"
                className="w-full sm:w-auto inline-flex items-center justify-center gap-2.5 px-8 py-4 rounded-2xl text-base font-bold text-white bg-[#FF5722] hover:bg-[#E64A19] shadow-lg shadow-orange-500/25 hover:shadow-xl hover:shadow-orange-500/35 transition-all active:scale-95"
              >
                <Download className="w-5 h-5" />
                <span>{t("downloadApp")}</span>
              </Link>

              <Link
                href="/merchant"
                className="w-full sm:w-auto inline-flex items-center justify-center gap-2.5 px-8 py-4 rounded-2xl text-base font-bold text-[#FF5722] bg-white border-2 border-[#FF5722] hover:bg-orange-50 shadow-sm transition-all active:scale-95"
              >
                <Store className="w-5 h-5" />
                <span>{t("joinMerchant")}</span>
              </Link>
            </div>

            {/* Highlights / Badges Row */}
            <div className="grid grid-cols-2 sm:grid-cols-3 gap-4 pt-4 border-t border-orange-100/80 w-full">
              <div className="flex items-center gap-3 bg-white/80 backdrop-blur-sm p-3 rounded-xl border border-orange-100">
                <div className="w-10 h-10 rounded-lg bg-orange-50 flex items-center justify-center text-[#FF5722] font-bold">
                  ⚡
                </div>
                <div className="text-right">
                  <span className="block text-xs text-gray-400 font-medium">سرعة التوصيل</span>
                  <span className="text-sm font-bold text-[#1A1D27]">خلال دقائق</span>
                </div>
              </div>

              <div className="flex items-center gap-3 bg-white/80 backdrop-blur-sm p-3 rounded-xl border border-orange-100">
                <div className="w-10 h-10 rounded-lg bg-emerald-50 flex items-center justify-center text-emerald-600 font-bold">
                  🛡️
                </div>
                <div className="text-right">
                  <span className="block text-xs text-gray-400 font-medium">أمان وسهولة</span>
                  <span className="text-sm font-bold text-[#1A1D27]">دفع بالبنك والكاش</span>
                </div>
              </div>

              <div className="col-span-2 sm:col-span-1 flex items-center gap-3 bg-white/80 backdrop-blur-sm p-3 rounded-xl border border-orange-100">
                <div className="w-10 h-10 rounded-lg bg-blue-50 flex items-center justify-center text-blue-600 font-bold">
                  📍
                </div>
                <div className="text-right">
                  <span className="block text-xs text-gray-400 font-medium">تغطية واسعة</span>
                  <span className="text-sm font-bold text-[#1A1D27]">أقرب محلاتك</span>
                </div>
              </div>
            </div>

          </div>

          {/* Phone Visual Column (Col 5) */}
          <div className="lg:col-span-5 relative flex justify-center items-center">
            
            {/* Ambient Background Glow Behind Phone */}
            <div className="absolute w-72 h-72 sm:w-80 sm:h-80 bg-gradient-to-tr from-[#FF5722]/30 to-amber-300/30 rounded-full blur-2xl -z-10" />

            {/* Main Phone Container Frame */}
            <div className="relative w-[280px] sm:w-[320px] h-[570px] sm:h-[620px] bg-[#1A1D27] rounded-[48px] p-3 shadow-2xl shadow-orange-950/20 border-4 border-gray-800">
              
              {/* Phone Speaker Notch */}
              <div className="absolute top-5 left-1/2 -translate-x-1/2 w-32 h-5 bg-black rounded-full z-20 flex items-center justify-center">
                <div className="w-3 h-3 bg-gray-900 rounded-full ml-4" />
              </div>

              {/* Screen Content Wrapper */}
              <div className="relative w-full h-full bg-white rounded-[38px] overflow-hidden flex flex-col pt-7">
                
                {/* Embedded Real App Screen Image if available, with UI fallback */}
                <div className="relative w-full h-full">
                  <Image
                    src="/app-screens/screen1.png"
                    alt="Talabaty App Mobile Screen"
                    fill
                    className="object-cover object-top"
                    priority
                    onError={(e) => {
                      // Fallback if image fails
                      (e.target as HTMLElement).style.display = "none";
                    }}
                  />

                  {/* App Screen Header Simulation Over Overlay */}
                  <div className="absolute top-0 inset-x-0 bg-gradient-to-b from-black/60 via-black/20 to-transparent p-4 pt-6 text-white text-right">
                    <div className="flex items-center justify-between text-xs font-bold">
                      <span className="bg-[#FF5722] px-2 py-0.5 rounded-full text-[10px]">مباشر 🟢</span>
                      <span className="text-gray-200">الخرطوم، السودان 📍</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Floating Info Card 1 - Top Left */}
            <div className="absolute top-12 -left-4 sm:-left-8 bg-white/95 backdrop-blur-md p-3.5 rounded-2xl border border-orange-100 shadow-xl flex items-center gap-3 animate-bounce [animation-duration:3s]">
              <div className="w-10 h-10 rounded-xl bg-orange-500 text-white flex items-center justify-center text-lg font-bold shadow-md shadow-orange-500/30">
                🍔
              </div>
              <div className="text-right">
                <span className="block text-xs font-bold text-[#1A1D27]">أشهى الوجبات</span>
                <span className="text-[11px] text-gray-500">من أفضل المطاعم</span>
              </div>
            </div>

            {/* Floating Info Card 2 - Bottom Right */}
            <div className="absolute bottom-16 -right-4 sm:-right-8 bg-white/95 backdrop-blur-md p-3.5 rounded-2xl border border-emerald-100 shadow-xl flex items-center gap-3 animate-pulse">
              <div className="w-10 h-10 rounded-xl bg-emerald-500 text-white flex items-center justify-center text-lg font-bold shadow-md shadow-emerald-500/30">
                🛵
              </div>
              <div className="text-right">
                <span className="block text-xs font-bold text-[#1A1D27]">تتبع حي مباشر</span>
                <span className="text-[11px] text-emerald-600 font-semibold">المندوب في الطريق</span>
              </div>
            </div>

          </div>

        </div>
      </div>
    </section>
  );
}
