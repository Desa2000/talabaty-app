"use client";

import React from "react";
import { useLanguage } from "@/context/LanguageContext";
import { NumberTicker } from "./ui/NumberTicker";
import { Marquee } from "./ui/Marquee";
import { FadeUp } from "./motion/Animations";
import { ShoppingBag, Truck, Store, Users, MapPin } from "lucide-react";

export default function StatsSection() {
  const { lang, t } = useLanguage();
  const isRTL = lang === "ar";

  const stats = [
    {
      icon: ShoppingBag,
      value: 50000,
      suffix: "+",
      label: isRTL ? "طلب ناجح تم توصيله" : "Successful Orders",
      color: "text-orange-500",
      bg: "bg-orange-50",
    },
    {
      icon: Store,
      value: 500,
      suffix: "+",
      label: isRTL ? "مطعم وسوبرماركت شريك" : "Partner Stores",
      color: "text-emerald-500",
      bg: "bg-emerald-50",
    },
    {
      icon: Truck,
      value: 1200,
      suffix: "+",
      label: isRTL ? "مندوب موثوق ومحترف" : "Active Couriers",
      color: "text-blue-500",
      bg: "bg-blue-50",
    },
    {
      icon: Users,
      value: 99,
      suffix: "%",
      label: isRTL ? "نسبة رضا العملاء" : "Customer Satisfaction",
      color: "text-amber-500",
      bg: "bg-amber-50",
    },
  ];

  const cities = isRTL
    ? ["الخرطوم ", "أم درمان ", "بحري ", "بورتسودان ", "ود مدني ", "عطبرة ", "كسلا ", "القضارف "]
    : ["Khartoum ", "Omdurman ", "Bahri ", "Port Sudan ", "Wad Madani ", "Atbara ", "Kassala ", "Gedaref "];

  return (
    <section className="py-16 bg-[#FAF7F2] border-y border-[#F0EAE1] overflow-hidden">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mb-12">
        <FadeUp>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
            {stats.map((stat, idx) => {
              const Icon = stat.icon;
              return (
                <div
                  key={idx}
                  className="bg-white rounded-2xl p-6 border border-[#F0EAE1] shadow-sm hover:shadow-md transition-shadow flex flex-col items-center text-center group"
                >
                  <div className={`w-14 h-14 rounded-2xl ${stat.bg} ${stat.color} flex items-center justify-center mb-4 transition-transform group-hover:scale-110`}>
                    <Icon className="w-7 h-7" />
                  </div>
                  <div className="text-3xl sm:text-4xl font-extrabold text-[#1A1D27] mb-1">
                    <NumberTicker value={stat.value} suffix={stat.suffix} />
                  </div>
                  <div className="text-xs sm:text-sm font-semibold text-gray-500">
                    {stat.label}
                  </div>
                </div>
              );
            })}
          </div>
        </FadeUp>
      </div>

      {/* Marquee for Cities */}
      <div className="py-4 bg-white border-y border-[#F0EAE1]/80 shadow-inner">
        <div className="max-w-7xl mx-auto px-4 flex items-center gap-4">
          <span className="text-xs font-bold text-[#FF5722] uppercase tracking-wider whitespace-nowrap flex items-center gap-1.5 shrink-0 bg-orange-50 px-3 py-1.5 rounded-full border border-orange-100">
            <MapPin className="w-3.5 h-3.5" />
            {isRTL ? "نغطي مدن السودان:" : "Covering Sudan Cities:"}
          </span>
          <Marquee
            speed={30}
            items={cities.map((city, index) => (
              <span
                key={index}
                className="text-sm font-bold text-gray-700 bg-gray-50 px-4 py-2 rounded-xl border border-gray-100 shadow-sm"
              >
                {city}
              </span>
            ))}
          />
        </div>
      </div>
    </section>
  );
}
