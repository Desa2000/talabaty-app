"use client";

import React from "react";
import Link from "next/link";
import Image from "next/image";
import { useLanguage } from "@/context/LanguageContext";
import { Bike, Navigation, CheckCircle, ArrowLeft, ArrowRight, Shield, DollarSign } from "lucide-react";

export default function CourierSection() {
  const { lang, t } = useLanguage();
  const isRtl = lang === "ar";
  const ArrowIcon = isRtl ? ArrowLeft : ArrowRight;

  const features = [
    t("cFeat1"),
    t("cFeat2"),
    t("cFeat3"),
    t("cFeat4"),
    t("cFeat5"),
  ];

  const supportedVehicles = [
    { name: t("motorcycle"), icon: "🏍️", badge: "أسرع خيار" },
    { name: t("electricBike"), icon: "⚡", badge: "اقتصادي" },
    { name: t("bicycle"), icon: "🚲", badge: "صديق للبيئة" },
  ];

  return (
    <section className="py-20 lg:py-28 bg-[#FAF7F2]">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Large Rounded Card Wrapper */}
        <div className="bg-white rounded-[40px] p-8 sm:p-12 lg:p-16 border border-[#F0EAE1] shadow-card relative overflow-hidden">
          
          {/* Subtle Background Glow */}
          <div className="absolute bottom-0 left-0 w-80 h-80 bg-emerald-400/10 rounded-full blur-3xl pointer-events-none" />

          <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center relative z-10">
            
            {/* Visual Column (Col 5) */}
            <div className="lg:col-span-5 order-2 lg:order-1 relative flex justify-center">
              
              {/* Outer Card Mockup Shell */}
              <div className="relative w-full max-w-sm bg-gradient-to-b from-gray-900 to-[#1A1D27] text-white rounded-3xl p-6 shadow-2xl border border-gray-800">
                
                {/* Courier Status Bar Mock */}
                <div className="flex items-center justify-between border-b border-gray-800 pb-4 mb-4">
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 rounded-2xl bg-emerald-500 text-white flex items-center justify-center font-bold text-xl shadow-md shadow-emerald-500/30">
                      🛵
                    </div>
                    <div className="text-right">
                      <span className="block text-sm font-bold">محمد أحمد (مندوب)</span>
                      <span className="text-xs text-emerald-400 font-semibold">متصل ومتاح للطلبات 🟢</span>
                    </div>
                  </div>
                  <span className="bg-emerald-500/20 text-emerald-300 text-xs font-bold px-2.5 py-1 rounded-full border border-emerald-500/30">
                    4.9 ⭐
                  </span>
                </div>

                {/* Earnings & Delivery Count Box */}
                <div className="grid grid-cols-2 gap-3 mb-4">
                  <div className="bg-gray-800/80 p-3 rounded-xl border border-gray-700/60 text-right">
                    <span className="block text-[11px] text-gray-400 font-medium">أرباح اليوم</span>
                    <span className="text-base font-black text-emerald-400">18,000 ج.س</span>
                  </div>
                  <div className="bg-gray-800/80 p-3 rounded-xl border border-gray-700/60 text-right">
                    <span className="block text-[11px] text-gray-400 font-medium">توصيلات اليوم</span>
                    <span className="text-base font-black text-orange-400">12 توصيلة</span>
                  </div>
                </div>

                {/* Embedded Screen Image */}
                <div className="relative h-56 w-full rounded-2xl overflow-hidden border border-gray-800">
                  <Image
                    src="/app-screens/screen3.png"
                    alt="Talabaty Courier App Preview"
                    fill
                    className="object-cover object-center"
                  />
                </div>

              </div>

            </div>

            {/* Text Column (Col 7) */}
            <div className="lg:col-span-7 order-1 lg:order-2 flex flex-col items-start text-right">
              
              <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-emerald-100 text-emerald-700 text-xs font-bold mb-6">
                <Bike className="w-4 h-4" />
                <span>فرص عمل ودخل ممتاز 💰</span>
              </div>

              <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-[#1A1D27] tracking-tight mb-4 leading-tight">
                {t("courierTitle")}
              </h2>

              <p className="text-base sm:text-lg text-gray-600 font-medium mb-8 max-w-xl">
                {t("courierSubtitle")}
              </p>

              {/* Checklist */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 mb-8 w-full">
                {features.map((feat, idx) => (
                  <div key={idx} className="flex items-center gap-3 bg-[#FAF7F2] p-3.5 rounded-2xl border border-[#F0EAE1]">
                    <CheckCircle className="w-5 h-5 text-emerald-600 flex-shrink-0" />
                    <span className="text-sm font-bold text-[#1A1D27]">{feat}</span>
                  </div>
                ))}
              </div>

              {/* Supported Vehicles Box */}
              <div className="w-full bg-orange-50/70 rounded-2xl p-4 border border-orange-100 mb-8">
                <span className="block text-xs font-bold text-[#FF5722] mb-3">
                  {t("supportedVehiclesTitle")}
                </span>
                <div className="flex flex-wrap gap-3">
                  {supportedVehicles.map((v, i) => (
                    <div key={i} className="flex items-center gap-2 bg-white px-3.5 py-2 rounded-xl border border-orange-200/60 shadow-sm">
                      <span className="text-lg">{v.icon}</span>
                      <span className="text-xs font-bold text-[#1A1D27]">{v.name}</span>
                      <span className="text-[10px] font-semibold text-[#FF5722] bg-orange-100 px-1.5 py-0.5 rounded">
                        {v.badge}
                      </span>
                    </div>
                  ))}
                </div>
              </div>

              {/* CTA Button */}
              <Link
                href="/courier"
                className="inline-flex items-center justify-center gap-3 px-8 py-4 rounded-2xl text-base font-bold text-white bg-[#FF5722] hover:bg-[#E64A19] shadow-lg shadow-orange-500/25 hover:shadow-xl hover:shadow-orange-500/35 transition-all active:scale-95"
              >
                <span>{t("joinCourierNow")}</span>
                <ArrowIcon className="w-5 h-5" />
              </Link>

            </div>

          </div>

        </div>

      </div>
    </section>
  );
}
