"use client";

import React from "react";
import { useLanguage } from "@/context/LanguageContext";
import { UtensilsCrossed, ShoppingCart, ShieldCheck, Clock } from "lucide-react";
import { motion } from "framer-motion";
import { FadeUp, StaggerContainer, StaggerChild } from "@/components/motion/Animations";

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

  const cardVariants = {
    hidden: { scale: 0.95 },
    visible: { 
      scale: 1, 
      transition: { duration: 0.5, ease: [0.25, 0.46, 0.45, 0.94] as [number, number, number, number] } 
    }
  };

  return (
    <section className="py-16 bg-white border-y border-[#F0EAE1] overflow-hidden">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Title */}
        <FadeUp>
          <div className="text-center max-w-2xl mx-auto mb-12">
            <h2 className="text-2xl sm:text-3xl font-extrabold text-[#1A1D27] tracking-tight">
              {t("benefitsTitle")}
            </h2>
          </div>
        </FadeUp>

        {/* Benefits Grid */}
        <StaggerContainer className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {benefits.map((b, i) => {
            const Icon = b.icon;
            return (
              <StaggerChild key={i} className="h-full">
                <motion.div
                  variants={cardVariants}
                  className="group h-full bg-white/70 backdrop-blur-xl rounded-2xl p-6 border border-white/40 shadow-md hover:-translate-y-[3px] hover:border-orange-300 hover:bg-white/90 hover:shadow-xl transition-all duration-300 ease-out text-right flex flex-col items-start"
                >
                  <div className={`w-12 h-12 rounded-xl ${b.accentBg} ${b.iconColor} flex items-center justify-center mb-4 transition-colors duration-300`}>
                    <Icon className="w-6 h-6 transition-transform duration-300 group-hover:scale-110" />
                  </div>
                  <h3 className="text-lg font-bold text-[#1A1D27] mb-2">
                    {b.title}
                  </h3>
                  <p className="text-xs text-gray-500 font-medium leading-relaxed">
                    {b.desc}
                  </p>
                </motion.div>
              </StaggerChild>
            );
          })}
        </StaggerContainer>

      </div>
    </section>
  );
}
