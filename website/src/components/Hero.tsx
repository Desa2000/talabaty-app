"use client";

import React from "react";
import Link from "next/link";
import Image from "next/image";
import { useLanguage } from "@/context/LanguageContext";
import { ArrowLeft, ArrowRight, Store, CheckCircle2 } from "lucide-react";
import { motion } from "framer-motion";
import {
  FadeUp,
  ImageReveal,
  SectionLabel,
  TiltVisual,
  MOTION_TOKENS,
} from "@/components/motion/Animations";

export default function Hero() {
  const { lang, t } = useLanguage();
  const isRTL = lang === "ar";
  const ArrowIcon = isRTL ? ArrowLeft : ArrowRight;

  return (
    <section className="relative pt-28 pb-20 lg:pt-36 lg:pb-32 overflow-hidden bg-gradient-to-b from-[#FFFDF9] via-[#FAF7F2] to-white">
      
      {/* Soft Ambient Radial Orange Glow (Lusion Depth Layer) */}
      <div className="absolute top-1/3 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[550px] h-[550px] bg-[#FF5722]/10 rounded-full blur-3xl pointer-events-none -z-10" />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-8 items-center">
          
          {/* Text Content Column (Col 7) */}
          <div className="lg:col-span-7 flex flex-col items-start text-right">
            
            {/* 100ms: Eyebrow Section Label */}
            <FadeUp delay={0.1}>
              <SectionLabel text={isRTL ? "من منصتك السودانية الأولى للتوصيل" : "Sudan's #1 Delivery Platform"} />
            </FadeUp>

            {/* 200ms - 300ms: Main Headline Storytelling */}
            <FadeUp delay={0.2}>
              <h1 className="text-4xl sm:text-5xl lg:text-6xl font-black text-[#1A1D27] tracking-tight leading-[1.15] mb-4">
                <span>{t("heroTitlePrefix")}</span>{" "}
                <span className="text-[#FF5722] block sm:inline">{t("heroTitleMain")}</span>
              </h1>
            </FadeUp>

            {/* 450ms: Subtitle & Brand Phrase */}
            <FadeUp delay={0.35}>
              <p className="text-lg sm:text-xl text-gray-600 font-medium mb-2 max-w-2xl leading-relaxed">
                {t("heroDescription")}
              </p>
              <p className="text-base sm:text-lg font-bold text-[#FF5722] mb-7">
                {t("brandPhrase")}
              </p>
            </FadeUp>

            {/* Checklist */}
            <FadeUp delay={0.45}>
              <div className="flex flex-wrap items-center gap-4 sm:gap-6 mb-8 text-sm font-bold text-gray-700">
                <span className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-emerald-600" />
                  {isRTL ? "مطاعم طازجة" : "Fresh Restaurants"}
                </span>
                <span className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-emerald-600" />
                  {isRTL ? "سوبرماركت شامل" : "Full Supermarkets"}
                </span>
                <span className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-emerald-600" />
                  {isRTL ? "صيدليات مجاورة" : "Nearby Pharmacies"}
                </span>
              </div>
            </FadeUp>

            {/* 550ms: Buttons with Linear Micro-interactions */}
            <FadeUp delay={0.55} className="w-full sm:w-auto">
              <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-4 w-full sm:w-auto">
                
                {/* Primary CTA Button */}
                <motion.div
                  whileHover={{ scale: 1.015 }}
                  whileTap={{ scale: 0.98 }}
                  transition={{ duration: MOTION_TOKENS.FAST }}
                  className="relative inline-flex items-center justify-center px-8 py-4 rounded-2xl text-base font-bold text-white bg-[#FF5722] hover:bg-[#E64A19] shadow-lg shadow-orange-500/25 cursor-default select-none"
                >
                  <span>{t("downloadApp")}</span>
                </motion.div>

                {/* Merchant CTA Button */}
                <motion.div
                  whileHover={{ scale: 1.015 }}
                  whileTap={{ scale: 0.98 }}
                  transition={{ duration: MOTION_TOKENS.FAST }}
                >
                  <Link
                    href="/merchant"
                    className="inline-flex items-center justify-center gap-2 px-7 py-4 rounded-2xl text-base font-bold text-[#1A1D27] bg-white border border-gray-200 hover:border-orange-300 hover:bg-orange-50/50 shadow-sm transition-all"
                  >
                    <Store className="w-5 h-5 text-[#FF5722]" />
                    <span>{t("joinMerchant")}</span>
                    <ArrowIcon className="w-4 h-4" />
                  </Link>
                </motion.div>

              </div>
            </FadeUp>

          </div>

          {/* 650ms: Customer App Visual Column (Apple Scale Reveal + Lusion 3D Tilt) */}
          <div className="lg:col-span-5 relative flex justify-center items-center mt-8 lg:mt-0">
            <ImageReveal delay={0.65} className="w-full max-w-sm sm:max-w-md">
              <TiltVisual>
                <div className="relative bg-white rounded-[40px] p-3 sm:p-4 border border-orange-100/90 shadow-2xl shadow-orange-950/10 transition-all duration-300 overflow-hidden">
                  <div className="relative w-full aspect-[9/18] rounded-[32px] overflow-hidden bg-[#FAF7F2]">
                    <Image
                      src="/visuals/customer-app.png"
                      alt="Talabaty Customer App Official Visual"
                      fill
                      sizes="(max-width: 768px) 300px, 420px"
                      className="object-contain object-top"
                      priority
                    />
                  </div>
                </div>
              </TiltVisual>
            </ImageReveal>
          </div>

        </div>
      </div>
    </section>
  );
}
