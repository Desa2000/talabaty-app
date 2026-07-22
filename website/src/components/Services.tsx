"use client";

import React from "react";
import Image from "next/image";
import { useLanguage } from "@/context/LanguageContext";
import { ArrowLeft, ArrowRight, Utensils, ShoppingBag, Pill } from "lucide-react";
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
      image: "/experience/services/restaurants.webp",
      accentBg: "bg-orange-50",
      accentText: "text-[#FF5722]",
      borderColor: "border-orange-100/90 hover:border-[#FF5722]/40",
    },
    {
      id: "supermarkets",
      title: t("supermarkets"),
      desc: t("supermarketsDesc"),
      icon: ShoppingBag,
      image: "/experience/services/supermarket.webp",
      accentBg: "bg-emerald-50",
      accentText: "text-emerald-600",
      borderColor: "border-emerald-100/90 hover:border-emerald-500/40",
    },
    {
      id: "pharmacies",
      title: t("pharmacies"),
      desc: t("pharmaciesDesc"),
      icon: Pill,
      image: "/experience/services/pharmacy.webp",
      accentBg: "bg-blue-50",
      accentText: "text-blue-600",
      borderColor: "border-blue-100/90 hover:border-blue-500/40",
    },
  ];

  return (
    <section id="services" className="py-20 lg:py-28 bg-white relative overflow-hidden">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        
        {/* Chapter Header */}
        <FadeUp>
          <div className="text-center max-w-2xl mx-auto mb-16">
            <SectionLabel text={isRTL ? "خدمات طلباتي" : "Talabaty Services"} />
            <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-[#1A1D27] tracking-tight mb-4">
              {t("servicesTitle")}
            </h2>
            <p className="text-base sm:text-lg text-gray-600 font-medium leading-relaxed">
              {t("servicesSubtitle")}
            </p>
          </div>
        </FadeUp>

        {/* 3 Rich Visual Services Cards Grid */}
        <StaggerContainer className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {servicesList.map((service) => {
            const IconComponent = service.icon;
            return (
              <StaggerChild key={service.id}>
                <motion.div
                  whileHover={{ y: -4, boxShadow: "0 20px 40px -10px rgba(255, 87, 34, 0.08)" }}
                  transition={{ duration: MOTION_TOKENS.FAST }}
                  className={`bg-[#FAF7F2]/80 rounded-3xl overflow-hidden border ${service.borderColor} shadow-xs transition-all duration-300 flex flex-col justify-between h-full group`}
                >
                  <div>
                    {/* Top Commercial Photography Image */}
                    <div className="relative w-full aspect-[16/10] overflow-hidden bg-gray-100">
                      <Image
                        src={service.image}
                        alt={service.title}
                        fill
                        sizes="(max-width: 768px) 100vw, 380px"
                        className="object-cover object-center group-hover:scale-[1.025] transition-transform duration-300"
                        priority
                      />
                      <div className="absolute top-4 right-4 z-10">
                        <div className={`w-11 h-11 rounded-2xl ${service.accentBg} ${service.accentText} flex items-center justify-center shadow-md backdrop-blur-md`}>
                          <IconComponent className="w-5 h-5" />
                        </div>
                      </div>
                    </div>

                    {/* Card Content Body */}
                    <div className="p-7">
                      <h3 className="text-2xl font-bold text-[#1A1D27] mb-3 group-hover:text-[#FF5722] transition-colors duration-200">
                        {service.title}
                      </h3>
                      
                      <p className="text-gray-600 font-medium text-sm sm:text-base leading-relaxed">
                        {service.desc}
                      </p>
                    </div>
                  </div>

                  <div className="px-7 pb-7 pt-2">
                    <div className="pt-4 border-t border-gray-200/60 flex items-center justify-between">
                      <span className="inline-flex items-center gap-2 text-sm font-bold text-[#FF5722] group-hover:gap-3 transition-all duration-200">
                        <span>{t("exploreCategory")}</span>
                        <ArrowIcon className="w-4 h-4" />
                      </span>
                    </div>
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
