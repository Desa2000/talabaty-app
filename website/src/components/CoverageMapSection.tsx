"use client";

import React from "react";
import Image from "next/image";
import { useLanguage } from "@/context/LanguageContext";
import { FadeUp, ImageReveal, SectionLabel } from "./motion/Animations";

export default function CoverageMapSection() {
  const { lang } = useLanguage();
  const isRTL = lang === "ar";

  return (
    <section id="coverage" className="py-20 lg:py-28 bg-[#FAF7F2] border-y border-[#F0EAE1] relative overflow-hidden scroll-mt-24">
      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        
        {/* Apple Moment Section Header */}
        <FadeUp>
          <div className="text-center max-w-2xl mx-auto mb-12">
            <SectionLabel text={isRTL ? "من السودان" : "From Sudan"} />
            <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-[#1A1D27] tracking-tight mb-3">
              {isRTL ? "طلباتي جاييك" : "Talabaty Sudan Coverage Map"}
            </h2>
            <p className="text-base sm:text-lg text-gray-600 font-medium leading-relaxed">
              {isRTL
                ? "بنبدأ خطوة خطوة، وكل يوم بنقرب ليك أكتر."
                : "Expanding step by step to be closer to you in more cities."}
            </p>
          </div>
        </FadeUp>

        {/* Official Sudan Coverage Map Image Display with Apple Image Reveal */}
        <ImageReveal delay={0.2} className="max-w-5xl mx-auto">
          <div className="bg-white rounded-3xl p-4 sm:p-8 border border-orange-100/90 shadow-xl shadow-orange-950/5 transition-all duration-300 overflow-hidden">
            <div className="relative w-full aspect-[16/9] rounded-2xl overflow-hidden bg-[#FAF7F2]">
              <Image
                src="/experience/coverage/sudan-map-official.webp"
                alt="Talabaty Sudan Coverage Map Visual"
                fill
                sizes="(max-width: 1200px) 100vw, 1100px"
                className="object-contain object-center"
                priority
              />
            </div>
          </div>
        </ImageReveal>

      </div>
    </section>
  );
}
