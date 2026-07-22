"use client";

import React from "react";
import Link from "next/link";
import Image from "next/image";
import { useLanguage } from "@/context/LanguageContext";
import { Store, CheckCircle, ArrowLeft, ArrowRight } from "lucide-react";
import { motion } from "framer-motion";
import {
  FadeUp,
  ImageReveal,
  SectionLabel,
  StaggerContainer,
  StaggerChild,
  MOTION_TOKENS,
} from "@/components/motion/Animations";

export default function MerchantSection() {
  const { lang, t } = useLanguage();
  const isRtl = lang === "ar";
  const ArrowIcon = isRtl ? ArrowLeft : ArrowRight;

  const features = [
    t("mFeat1"),
    t("mFeat2"),
    t("mFeat3"),
    t("mFeat4"),
    t("mFeat5"),
    t("mFeat6"),
  ];

  return (
    <section id="merchants" className="py-20 lg:py-28 bg-white relative overflow-hidden">
      
      {/* Background Tech Grid Lines (Linear 3% Opacity Grid) */}
      <div className="absolute inset-0 bg-[linear-gradient(to_right,#8080800a_1px,transparent_1px),linear-gradient(to_bottom,#8080800a_1px,transparent_1px)] bg-[size:24px_24px] pointer-events-none" />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="bg-[#FAF7F2]/80 rounded-[36px] p-8 sm:p-12 lg:p-16 border border-[#F0EAE1] shadow-xs relative overflow-hidden">
          
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
            
            {/* Text Column (Col 7) */}
            <div className="lg:col-span-7">
              <StaggerContainer className="flex flex-col items-start text-right">
                
                <StaggerChild>
                  <SectionLabel text={isRtl ? "للتاجر" : "For Merchants"} />
                </StaggerChild>

                <StaggerChild>
                  <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-[#1A1D27] tracking-tight mb-4 leading-tight">
                    {t("merchantTitle")}
                  </h2>
                </StaggerChild>

                <StaggerChild>
                  <p className="text-base sm:text-lg text-gray-600 font-medium mb-8 max-w-xl">
                    {t("merchantSubtitle")}
                  </p>
                </StaggerChild>

                {/* Features Grid */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-10 w-full">
                  {features.map((feat, idx) => (
                    <StaggerChild key={idx}>
                      <div className="flex items-center gap-3 bg-white p-3.5 rounded-2xl border border-gray-100 shadow-xs">
                        <CheckCircle className="w-5 h-5 text-[#FF5722] flex-shrink-0" />
                        <span className="text-sm font-bold text-[#1A1D27]">{feat}</span>
                      </div>
                    </StaggerChild>
                  ))}
                </div>

                {/* CTA Button with Linear Micro-interactions */}
                <StaggerChild>
                  <motion.div
                    whileHover={{ scale: 1.015 }}
                    whileTap={{ scale: 0.98 }}
                    transition={{ duration: MOTION_TOKENS.FAST }}
                  >
                    <Link
                      href="/merchant"
                      className="group inline-flex items-center justify-center gap-3 px-8 py-4 rounded-2xl text-base font-bold text-white bg-[#FF5722] hover:bg-[#E64A19] shadow-lg shadow-orange-500/25 transition-colors duration-200"
                    >
                      <span>{t("registerStoreNow")}</span>
                      <ArrowIcon className={`w-5 h-5 transition-transform duration-200 ${isRtl ? 'group-hover:-translate-x-1' : 'group-hover:translate-x-1'}`} />
                    </Link>
                  </motion.div>
                </StaggerChild>

              </StaggerContainer>
            </div>

            {/* Visual Column — Official Merchant Dashboard Visual with Apple Image Reveal & Soft Radial Glow */}
            <div className="lg:col-span-5 relative flex justify-center">
              <ImageReveal delay={0.2} className="w-full">
                {/* Soft Orange Glow Behind Image */}
                <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-72 h-72 bg-[#FF5722]/15 rounded-full blur-2xl pointer-events-none -z-10" />

                <div className="relative w-full bg-white rounded-3xl p-4 sm:p-6 border border-orange-100/90 shadow-xl shadow-orange-950/5 transition-all duration-300 overflow-hidden">
                  <Image
                    src="/experience/merchant/merchant-dashboard.webp"
                    alt="Talabaty Merchant Dashboard Visual"
                    width={1024}
                    height={576}
                    className="w-full h-auto rounded-2xl object-cover"
                    priority
                  />
                </div>
              </ImageReveal>
            </div>

          </div>
        </div>
      </div>
    </section>
  );
}
