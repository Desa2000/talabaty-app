"use client";

import React from "react";
import { useLanguage } from "@/context/LanguageContext";
import { Utensils, ShoppingBag, Pill, ArrowLeft, ArrowRight } from "lucide-react";
import { motion } from "framer-motion";
import {
  FadeUp,
  StaggerContainer,
  StaggerChild,
  SectionLabel,
  MOTION_TOKENS,
} from "@/components/motion/Animations";

export default function Services() {
  const { lang, t } = useLanguage();
  const isRTL = lang === "ar";
  const ArrowIcon = isRTL ? ArrowLeft : ArrowRight;

  const servicesList = [
    {
      id: "restaurants",
      title: t("restaurants"),
      desc: t("restaurantsDesc"),
      icon: Utensils,
      accentBg: "bg-orange-50",
      accentText: "text-[#FF5722]",
      borderColor: "border-orange-100/80 hover:border-[#FF5722]/50",
    },
    {
      id: "supermarkets",
      title: t("supermarkets"),
      desc: t("supermarketsDesc"),
      icon: ShoppingBag,
      accentBg: "bg-emerald-50",
      accentText: "text-emerald-600",
      borderColor: "border-emerald-100/80 hover:border-emerald-500/50",
    },
    {
      id: "pharmacies",
      title: t("pharmacies"),
      desc: t("pharmaciesDesc"),
      icon: Pill,
      accentBg: "bg-blue-50",
      accentText: "text-blue-600",
      borderColor: "border-blue-100/80 hover:border-blue-500/50",
    },
  ];

  return (
    <section id="services" className="py-20 lg:py-28 bg-white relative overflow-hidden">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        
        {/* Chapter Header (Apple / Shopify style statement) */}
        <FadeUp>
          <div className="text-center max-w-2xl mx-auto mb-16">
            <SectionLabel text={isRTL ? "للعملاء" : "For Customers"} />
            <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-[#1A1D27] tracking-tight mb-4">
              {t("servicesTitle")}
            </h2>
            <p className="text-base sm:text-lg text-gray-600 font-medium leading-relaxed">
              {t("servicesSubtitle")}
            </p>
          </div>
        </FadeUp>

        {/* 3 Services Cards Grid */}
        <StaggerContainer className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {servicesList.map((service) => {
            const IconComponent = service.icon;
            return (
              <StaggerChild key={service.id}>
                <motion.div
                  whileHover={{ y: -3, boxShadow: "0 15px 35px -10px rgba(255, 87, 34, 0.08)" }}
                  transition={{ duration: MOTION_TOKENS.FAST }}
                  className={`bg-[#FAF7F2]/60 rounded-3xl p-8 border ${service.borderColor} shadow-xs transition-all duration-200 flex flex-col justify-between h-full group`}
                >
                  <div>
                    {/* Icon Header */}
                    <div className="flex items-center justify-between mb-6">
                      <div className={`w-14 h-14 rounded-2xl ${service.accentBg} ${service.accentText} flex items-center justify-center transition-transform duration-200 group-hover:scale-105`}>
                        <IconComponent className="w-7 h-7" />
                      </div>
                    </div>

                    <h3 className="text-2xl font-bold text-[#1A1D27] mb-3 group-hover:text-[#FF5722] transition-colors duration-200">
                      {service.title}
                    </h3>
                    
                    <p className="text-gray-600 font-medium text-base leading-relaxed mb-8">
                      {service.desc}
                    </p>
                  </div>

                  <div className="pt-4 border-t border-gray-200/60">
                    <span className="inline-flex items-center gap-2 text-sm font-bold text-[#FF5722] group-hover:gap-3 transition-all duration-200">
                      <span>{t("exploreCategory")}</span>
                      <ArrowIcon className="w-4 h-4" />
                    </span>
                  </div>
                </motion.div>
              </StaggerChild>
            );
          })}
        </StaggerContainer>

      </div>
    </section>
  );
}
