"use client";

import React from "react";
import Link from "next/link";
import { useLanguage } from "@/context/LanguageContext";
import { Utensils, ShoppingBag, Pill, ArrowLeft, ArrowRight } from "lucide-react";
import { motion, Variants } from "framer-motion";
import { FadeUp, StaggerContainer, StaggerChild } from "@/components/motion/Animations";

export default function Services() {
  const { lang, t } = useLanguage();
  const isRtl = lang === "ar";
  const ArrowIcon = isRtl ? ArrowLeft : ArrowRight;

  const servicesList = [
    {
      id: "restaurants",
      title: t("restaurants"),
      desc: t("restaurantsDesc"),
      icon: Utensils,
      badge: "وجبات طازجة 🍔",
      accentBg: "bg-orange-50",
      accentText: "text-[#FF5722]",
      borderColor: "border-orange-100",
      hoverBorder: "group-hover:border-orange-300",
      btnBg: "bg-[#FF5722] hover:bg-[#E64A19] text-white",
      imagePattern: "from-orange-500/10 to-amber-500/5",
    },
    {
      id: "supermarkets",
      title: t("supermarkets"),
      desc: t("supermarketsDesc"),
      icon: ShoppingBag,
      badge: "مقاضي البيت 🛒",
      accentBg: "bg-emerald-50",
      accentText: "text-emerald-600",
      borderColor: "border-emerald-100",
      hoverBorder: "group-hover:border-emerald-300",
      btnBg: "bg-emerald-600 hover:bg-emerald-700 text-white",
      imagePattern: "from-emerald-500/10 to-teal-500/5",
    },
    {
      id: "pharmacies",
      title: t("pharmacies"),
      desc: t("pharmaciesDesc"),
      icon: Pill,
      badge: "رعاية وصحة 💊",
      accentBg: "bg-blue-50",
      accentText: "text-blue-600",
      borderColor: "border-blue-100",
      hoverBorder: "group-hover:border-blue-300",
      btnBg: "bg-blue-600 hover:bg-blue-700 text-white",
      imagePattern: "from-blue-500/10 to-indigo-500/5",
    },
  ];

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const getIconVariants = (id: string): any => {
    if (id === "restaurants") {
      return {
        hidden: { y: 0 },
        visible: { y: 0 },
        hover: { y: [0, -4, 0], transition: { duration: 0.4, repeat: Infinity } }
      };
    }
    if (id === "supermarkets") {
      return {
        hidden: { x: 0 },
        visible: { x: 0 },
        hover: { x: [0, -3, 3, -3, 0], transition: { duration: 0.4, repeat: Infinity } }
      };
    }
    if (id === "pharmacies") {
      return {
        hidden: { scale: 1 },
        visible: { scale: 1 },
        hover: { scale: [1, 1.1, 1], transition: { duration: 0.6, repeat: Infinity } }
      };
    }
    return { hidden: { opacity: 1 }, visible: { opacity: 1 } };
  };

  return (
    <section id="services" className="py-20 lg:py-28 bg-white relative">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Section Header */}
        <FadeUp delay={0}>
          <div className="text-center max-w-3xl mx-auto mb-16">
            <span className="inline-block px-4 py-1.5 rounded-full bg-orange-100/70 text-[#FF5722] text-xs font-bold mb-4">
              خدماتنا الرئيسية
            </span>
            <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-[#1A1D27] tracking-tight mb-4">
              {t("servicesTitle")}
            </h2>
            <p className="text-base sm:text-lg text-gray-600 font-medium">
              {t("servicesSubtitle")}
            </p>
          </div>
        </FadeUp>

        {/* 3 Services Cards Grid */}
        <StaggerContainer className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {servicesList.map((item) => {
            const Icon = item.icon;
            return (
              <StaggerChild key={item.id} className="flex h-full">
                <motion.div
                  variants={{
                    hidden: { scale: 0.95, y: -4 },
                    visible: { scale: 1, y: -4, transition: { duration: 0.5 } },
                    hover: { y: -8, transition: { duration: 0.2, ease: "easeOut" } }
                  }}
                  whileHover="hover"
                  className={`group relative bg-white w-full rounded-3xl p-8 border ${item.borderColor} ${item.hoverBorder} shadow-card hover:shadow-card-hover transition-colors duration-300 flex flex-col justify-between overflow-hidden`}
                >
                  {/* Subtle Background Gradient Tint */}
                  <motion.div
                    variants={{
                      hidden: { opacity: 0.5 },
                      visible: { opacity: 0.5 },
                      hover: { opacity: 1 }
                    }}
                    className={`absolute top-0 inset-x-0 h-32 bg-gradient-to-b ${item.imagePattern} pointer-events-none`}
                  />

                  <div>
                    {/* Top Badge & Icon */}
                    <div className="flex items-center justify-between mb-8 relative z-10">
                      <div className={`w-16 h-16 rounded-2xl ${item.accentBg} ${item.accentText} flex items-center justify-center shadow-inner`}>
                        <motion.div variants={getIconVariants(item.id)}>
                          <Icon className="w-8 h-8" />
                        </motion.div>
                      </div>
                      <span className="text-xs font-bold text-gray-500 bg-gray-100/80 px-3 py-1 rounded-full border border-gray-200/60">
                        {item.badge}
                      </span>
                    </div>

                    {/* Title & Description */}
                    <h3 className="text-2xl font-extrabold text-[#1A1D27] mb-3 group-hover:text-[#FF5722] transition-colors relative z-10">
                      {item.title}
                    </h3>
                    <p className="text-gray-600 font-medium text-sm leading-relaxed mb-8 relative z-10">
                      {item.desc}
                    </p>
                  </div>

                  {/* Arrow Action Button */}
                  <div className="pt-4 border-t border-gray-100 flex items-center justify-between relative z-10">
                    <span className="text-xs font-bold text-gray-500 group-hover:text-[#FF5722] transition-colors">
                      {t("exploreCategory")}
                    </span>
                    <Link
                      href="#download"
                      className={`w-10 h-10 rounded-xl ${item.btnBg} flex items-center justify-center shadow-md transition-transform active:scale-95`}
                      aria-label={item.title}
                    >
                      <motion.div
                        variants={{
                          hidden: { x: 0 },
                          visible: { x: 0 },
                          hover: { x: isRtl ? -4 : 4, transition: { duration: 0.2 } }
                        }}
                      >
                        <ArrowIcon className="w-5 h-5" />
                      </motion.div>
                    </Link>
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
