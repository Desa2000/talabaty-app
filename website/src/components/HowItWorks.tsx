"use client";

import React from "react";
import { useLanguage } from "@/context/LanguageContext";
import { MapPin, ShoppingBag, CreditCard, Clock, Wallet, Banknote } from "lucide-react";
import { motion } from "framer-motion";
import {
  FadeUp,
  StaggerContainer,
  StaggerChild,
  SectionLabel,
  MOTION_TOKENS,
} from "@/components/motion/Animations";

export default function HowItWorks() {
  const { lang, t } = useLanguage();
  const isRTL = lang === "ar";

  const steps = [
    {
      num: "01",
      title: t("step1Title"),
      desc: t("step1Desc"),
      icon: MapPin,
      accentBg: "bg-orange-50 text-[#FF5722]",
    },
    {
      num: "02",
      title: t("step2Title"),
      desc: t("step2Desc"),
      icon: ShoppingBag,
      accentBg: "bg-emerald-50 text-emerald-600",
    },
    {
      num: "03",
      title: t("step3Title"),
      desc: t("step3Desc"),
      icon: CreditCard,
      accentBg: "bg-blue-50 text-blue-600",
    },
    {
      num: "04",
      title: t("step4Title"),
      desc: t("step4Desc"),
      icon: Clock,
      accentBg: "bg-amber-50 text-amber-600",
    },
  ];

  return (
    <section id="how-it-works" className="py-20 lg:py-28 bg-[#FAF7F2] relative overflow-hidden">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        
        {/* Chapter Header */}
        <FadeUp>
          <div className="text-center max-w-2xl mx-auto mb-16">
            <SectionLabel text={isRTL ? "خطوات تتبع الطلب" : "Ordering Steps"} />
            <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-[#1A1D27] tracking-tight mb-4">
              {t("howTitle")}
            </h2>
          </div>
        </FadeUp>

        {/* Steps Grid */}
        <StaggerContainer className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8 relative">
          {steps.map((step, idx) => {
            const IconComponent = step.icon;
            return (
              <StaggerChild key={idx}>
                <motion.div 
                  whileHover={{ y: -3 }}
                  transition={{ duration: MOTION_TOKENS.FAST }}
                  className="bg-white/70 backdrop-blur-xl rounded-3xl p-6 sm:p-8 border border-white/40 hover:border-orange-300 shadow-xl hover:shadow-2xl hover:bg-white/90 transition-all duration-300 relative h-full flex flex-col justify-between"
                >
                  <div>
                    <div className="flex items-center justify-between mb-6">
                      <div className={`w-12 h-12 rounded-2xl ${step.accentBg} flex items-center justify-center font-bold`}>
                        <IconComponent className="w-6 h-6" />
                      </div>
                      <span className="text-3xl font-black text-gray-200">
                        {step.num}
                      </span>
                    </div>

                    <h3 className="text-xl font-bold text-[#1A1D27] mb-2">
                      {step.title}
                    </h3>
                    <p className="text-sm font-medium text-gray-600 leading-relaxed">
                      {step.desc}
                    </p>
                  </div>
                </motion.div>
              </StaggerChild>
            );
          })}
        </StaggerContainer>

        {/* Supported Payment Methods */}
        <FadeUp delay={0.3}>
          <div className="mt-16 bg-white/70 backdrop-blur-xl rounded-3xl p-6 sm:p-8 border border-white/40 max-w-3xl mx-auto text-center shadow-xl">
            <h4 className="text-base font-bold text-[#1A1D27] mb-4">
              {isRTL ? "طرق دفع مناسبة ومضمونة" : "Convenient & Secure Payment Methods"}
            </h4>
            <div className="flex flex-wrap items-center justify-center gap-4 sm:gap-6">
              <div className="flex items-center gap-2.5 px-5 py-2.5 bg-white/60 backdrop-blur-lg rounded-2xl border border-white/50 shadow-md text-sm font-bold text-[#1A1D27]">
                <Wallet className="w-4 h-4 text-[#FF5722]" />
                <span>{isRTL ? "بنكك (Bankak)" : "Bankak"}</span>
              </div>
              <div className="flex items-center gap-2.5 px-5 py-2.5 bg-white/60 backdrop-blur-lg rounded-2xl border border-white/50 shadow-md text-sm font-bold text-[#1A1D27]">
                <Banknote className="w-4 h-4 text-emerald-600" />
                <span>{isRTL ? "الدفع عند الاستلام (كاش)" : "Cash on Delivery"}</span>
              </div>
            </div>
          </div>
        </FadeUp>

      </div>
    </section>
  );
}
