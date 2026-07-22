"use client";

import React from "react";
import { useLanguage } from "@/context/LanguageContext";
import { UtensilsCrossed, ShoppingCart, ShieldCheck, Clock, Sparkles } from "lucide-react";

export default function BenefitsSection() {
  const { t } = useLanguage();

  const benefits = [
    {
      icon: UtensilsCrossed,
      title: t("b1Title"),
      desc: t("b1Desc"),
      accentBg: "bg-orange-50",
      iconColor: "text-[#FF5722]",
    },
    {
      icon: ShoppingCart,
      title: t("b2Title"),
      desc: t("b2Desc"),
      accentBg: "bg-emerald-50",
      iconColor: "text-emerald-600",
    },
    {
      icon: ShieldCheck,
      title: t("b3Title"),
      desc: t("b3Desc"),
      accentBg: "bg-blue-50",
      iconColor: "text-blue-600",
    },
    {
      icon: Clock,
      title: t("b4Title"),
      desc: t("b4Desc"),
      accentBg: "bg-amber-50",
      iconColor: "text-amber-600",
    },
  ];

  return (
    <section className="py-16 bg-white border-y border-[#F0EAE1]">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Title */}
        <div className="text-center max-w-2xl mx-auto mb-12">
          <h2 className="text-2xl sm:text-3xl font-extrabold text-[#1A1D27] tracking-tight">
            {t("benefitsTitle")}
          </h2>
        </div>

        {/* Benefits Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {benefits.map((b, i) => {
            const Icon = b.icon;
            return (
              <div
                key={i}
                className="bg-[#FAF7F2] rounded-2xl p-6 border border-[#F0EAE1] hover:border-orange-200 transition-all hover:bg-white hover:shadow-card text-right flex flex-col items-start"
              >
                <div className={`w-12 h-12 rounded-xl ${b.accentBg} ${b.iconColor} flex items-center justify-center mb-4`}>
                  <Icon className="w-6 h-6" />
                </div>
                <h3 className="text-lg font-bold text-[#1A1D27] mb-2">
                  {b.title}
                </h3>
                <p className="text-xs text-gray-500 font-medium leading-relaxed">
                  {b.desc}
                </p>
              </div>
            );
          })}
        </div>

      </div>
    </section>
  );
}
