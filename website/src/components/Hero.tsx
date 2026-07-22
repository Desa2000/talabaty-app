"use client";

import React from "react";
import Link from "next/link";
import Image from "next/image";
import dynamic from "next/dynamic";
import { useLanguage } from "@/context/LanguageContext";
import { ArrowLeft, ArrowRight, Store, Zap, ShieldCheck, Headphones, ChevronDown } from "lucide-react";
import { motion } from "framer-motion";
import {
  FadeUp,
  ImageReveal,
  SectionLabel,
  MOTION_TOKENS,
} from "@/components/motion/Animations";

// Dynamic import for WebGL Canvas (Client-side only, SSR safe, code-split)
const HeroCanvas = dynamic(() => import("@/components/experience/HeroCanvas"), {
  ssr: false,
});

export default function Hero() {
  const { lang, t } = useLanguage();
  const isRTL = lang === "ar";
  const ArrowIcon = isRTL ? ArrowLeft : ArrowRight;

  return (
    <section
      id="hero-section"
      className="relative pt-28 pb-16 lg:pt-36 lg:pb-28 overflow-hidden bg-gradient-to-b from-[#FFFDF9] via-[#FAF7F2] to-white"
    >
      
      {/* 3D WebGL Canvas Layer (Desktop Only, Dynamic Code-Split, Client Side Only) */}
      <HeroCanvas />

      {/* Background Urban Atmosphere Layer & Ambient Orange Radial Glow */}
      <div className="absolute top-1/3 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[650px] h-[650px] bg-[#FF5722]/10 rounded-full blur-3xl pointer-events-none z-0" />

      {/* Tech Grid Lines (Linear 3% opacity grid) */}
      <div className="absolute inset-0 bg-[linear-gradient(to_right,#8080800a_1px,transparent_1px),linear-gradient(to_bottom,#8080800a_1px,transparent_1px)] bg-[size:28px_28px] pointer-events-none z-0" />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
          
          {/* Text Content Column (RTL Right side - 40% width / 5 cols) */}
          <div className="lg:col-span-5 flex flex-col items-start text-right">
            
            {/* Eyebrow Label */}
            <FadeUp delay={0.1}>
              <SectionLabel text={isRTL ? "طلباتك..." : "Your Orders..."} />
            </FadeUp>

            {/* Main Headline */}
            <FadeUp delay={0.2}>
              <h1 className="text-3xl sm:text-4xl lg:text-5xl font-black text-[#1A1D27] tracking-tight leading-[1.18] mb-4">
                <span>{t("heroTitlePrefix")}</span>{" "}
                <span className="text-[#FF5722] block sm:inline">{t("heroTitleMain")}</span>
              </h1>
            </FadeUp>

            {/* Subtitle & Brand Phrase */}
            <FadeUp delay={0.35}>
              <p className="text-base sm:text-lg text-gray-600 font-medium mb-2 max-w-xl leading-relaxed">
                {t("heroDescription")}
              </p>
              <p className="text-sm sm:text-base font-bold text-[#FF5722] mb-6">
                {t("brandPhrase")}
              </p>
            </FadeUp>

            {/* 3 Small Benefits Icons Below Copy */}
            <FadeUp delay={0.45}>
              <div className="grid grid-cols-3 gap-2.5 sm:gap-4 mb-8 w-full">
                <div className="flex items-center gap-2 bg-white p-2.5 rounded-xl border border-orange-100/80 shadow-xs">
                  <div className="w-7 h-7 rounded-lg bg-orange-50 text-[#FF5722] flex items-center justify-center shrink-0">
                    <Zap className="w-3.5 h-3.5" />
                  </div>
                  <div>
                    <span className="block text-[11px] font-bold text-[#1A1D27]">توصيل سريع</span>
                    <span className="text-[10px] text-gray-500 font-medium">أقرب ليك</span>
                  </div>
                </div>

                <div className="flex items-center gap-2 bg-white p-2.5 rounded-xl border border-emerald-100/80 shadow-xs">
                  <div className="w-7 h-7 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center shrink-0">
                    <ShieldCheck className="w-3.5 h-3.5" />
                  </div>
                  <div>
                    <span className="block text-[11px] font-bold text-[#1A1D27]">دفع آمن</span>
                    <span className="text-[10px] text-gray-500 font-medium">وسهل</span>
                  </div>
                </div>

                <div className="flex items-center gap-2 bg-white p-2.5 rounded-xl border border-blue-100/80 shadow-xs">
                  <div className="w-7 h-7 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center shrink-0">
                    <Headphones className="w-3.5 h-3.5" />
                  </div>
                  <div>
                    <span className="block text-[11px] font-bold text-[#1A1D27]">دعم مباشر</span>
                    <span className="text-[10px] text-gray-500 font-medium">معاك</span>
                  </div>
                </div>
              </div>
            </FadeUp>

            {/* Call to Action Buttons */}
            <FadeUp delay={0.55} className="w-full sm:w-auto">
              <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-3 w-full sm:w-auto">
                
                {/* Primary CTA Button */}
                <motion.div
                  whileHover={{ scale: 1.015 }}
                  whileTap={{ scale: 0.98 }}
                  transition={{ duration: MOTION_TOKENS.FAST }}
                  className="relative inline-flex items-center justify-center px-7 py-3.5 rounded-xl text-sm font-bold text-white bg-[#FF5722] hover:bg-[#E64A19] shadow-lg shadow-orange-500/25 cursor-default select-none pointer-events-auto"
                >
                  <span>{t("downloadApp")}</span>
                </motion.div>

                {/* Secondary Merchant CTA */}
                <motion.div
                  whileHover={{ scale: 1.015 }}
                  whileTap={{ scale: 0.98 }}
                  transition={{ duration: MOTION_TOKENS.FAST }}
                  className="pointer-events-auto"
                >
                  <Link
                    href="/merchant"
                    className="inline-flex items-center justify-center gap-2 px-6 py-3.5 rounded-xl text-sm font-bold text-[#1A1D27] bg-white border border-gray-200 hover:border-orange-300 hover:bg-orange-50/50 shadow-sm transition-all"
                  >
                    <Store className="w-4 h-4 text-[#FF5722]" />
                    <span>{t("joinMerchant")}</span>
                    <ArrowIcon className="w-4 h-4" />
                  </Link>
                </motion.div>

              </div>
            </FadeUp>

          </div>

          {/* Main Hero Visual Column (Left side - 60% width / 7 cols) */}
          <div className="lg:col-span-7 relative flex justify-center items-center mt-6 lg:mt-0">
            <ImageReveal delay={0.3} className="w-full">
              <div className="relative w-full rounded-3xl overflow-hidden border border-orange-100/90 shadow-2xl shadow-orange-950/10 bg-white aspect-[16/7]">
                <Image
                  src="/experience/hero/talabaty-hero.webp"
                  alt="Talabaty Official Hero Visual Scene"
                  fill
                  sizes="(max-width: 1024px) 100vw, 750px"
                  className="object-cover object-center"
                  priority
                />
              </div>
            </ImageReveal>
          </div>

        </div>

        {/* Scroll to Explore Indicator */}
        <div className="mt-16 flex flex-col items-center justify-center text-center">
          <motion.a
            href="#services"
            animate={{ y: [0, 6, 0] }}
            transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
            className="inline-flex flex-col items-center gap-1.5 text-xs font-bold text-gray-500 hover:text-[#FF5722] transition-colors pointer-events-auto"
          >
            <span>{isRTL ? "اكتشف طلباتي" : "Scroll to Explore"}</span>
            <ChevronDown className="w-4 h-4 text-[#FF5722]" />
          </motion.a>
        </div>

      </div>
    </section>
  );
}
