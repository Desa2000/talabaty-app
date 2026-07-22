"use client";

import React from "react";
import { useLanguage } from "@/context/LanguageContext";
import { Store, ShoppingCart, CheckCircle2, Navigation } from "lucide-react";

export default function HowItWorks() {
  const { t } = useLanguage();

  const steps = [
    {
      number: "1",
      icon: Store,
      title: t("step1Title"),
      desc: t("step1Desc"),
    },
    {
      number: "2",
      icon: ShoppingCart,
      title: t("step2Title"),
      desc: t("step2Desc"),
    },
    {
      number: "3",
      icon: CheckCircle2,
      title: t("step3Title"),
      desc: t("step3Desc"),
    },
    {
      number: "4",
      icon: Navigation,
      title: t("step4Title"),
      desc: t("step4Desc"),
    },
  ];

  return (
    <section id="how-it-works" className="py-20 lg:py-28 bg-[#FAF7F2] relative overflow-hidden">
      
      {/* Background Decorative Circles */}
      <div className="absolute top-1/2 left-0 -translate-y-1/2 w-96 h-96 bg-orange-200/20 rounded-full blur-3xl pointer-events-none" />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        
        {/* Section Header */}
        <div className="text-center max-w-2xl mx-auto mb-16 lg:mb-24">
          <span className="inline-block px-4 py-1.5 rounded-full bg-orange-100 text-[#FF5722] text-xs font-bold mb-4">
            خطوات بسيطة وسريعة
          </span>
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-[#1A1D27] tracking-tight">
            {t("howTitle")}
          </h2>
        </div>

        {/* 4 Steps Layout Container */}
        <div className="relative">
          
          {/* Desktop Connecting Dotted Line */}
          <div className="hidden lg:block absolute top-1/2 left-12 right-12 -translate-y-1/2 h-0.5 border-t-2 border-dashed border-orange-300 z-0 pointer-events-none" />

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8 relative z-10">
            {steps.map((step, idx) => {
              const StepIcon = step.icon;
              return (
                <div
                  key={idx}
                  className="bg-white rounded-3xl p-8 border border-[#F0EAE1] shadow-card hover:shadow-card-hover transition-all duration-300 hover:-translate-y-1 text-center flex flex-col items-center group relative"
                >
                  {/* Number Badge Circle */}
                  <div className="relative mb-6">
                    <div className="w-16 h-16 rounded-full bg-[#FF5722] text-white flex items-center justify-center text-2xl font-black shadow-lg shadow-orange-500/30 group-hover:scale-110 transition-transform">
                      {step.number}
                    </div>

                    {/* Step Icon Badge */}
                    <div className="absolute -bottom-1 -right-1 w-8 h-8 rounded-full bg-orange-50 border-2 border-white flex items-center justify-center text-[#FF5722] shadow-sm">
                      <StepIcon className="w-4 h-4" />
                    </div>
                  </div>

                  {/* Title & Desc */}
                  <h3 className="text-xl font-bold text-[#1A1D27] mb-2 group-hover:text-[#FF5722] transition-colors">
                    {step.title}
                  </h3>
                  <p className="text-sm font-medium text-gray-500 leading-relaxed">
                    {step.desc}
                  </p>
                </div>
              );
            })}
          </div>
        </div>

      </div>
    </section>
  );
}
