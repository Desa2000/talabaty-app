"use client";

import React from "react";
import Link from "next/link";
import Image from "next/image";
import { useLanguage } from "@/context/LanguageContext";
import { Bike, CheckCircle, ArrowLeft, ArrowRight } from "lucide-react";
import { motion } from "framer-motion";
import {
  ImageReveal,
  SectionLabel,
  StaggerContainer,
  StaggerChild,
  MOTION_TOKENS,
} from "@/components/motion/Animations";

export default function CourierSection() {
  const { lang, t } = useLanguage();
  const isRTL = lang === "ar";
  const ArrowIcon = isRTL ? ArrowLeft : ArrowRight;

  const features = [
    t("cFeat1"),
    t("cFeat2"),
    t("cFeat3"),
    t("cFeat4"),
    t("cFeat5"),
  ];

  return (
    <section id="couriers" className="py-20 lg:py-28 bg-white relative overflow-hidden">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Dark Cinematic Banner Container */}
        <div className="bg-[#1A1D27] rounded-[36px] p-8 sm:p-12 lg:p-16 text-white shadow-2xl relative overflow-hidden">
          
          {/* Subtle Ambient Radial Glow */}
          <div className="absolute top-0 right-0 w-96 h-96 bg-[#FF5722]/15 rounded-full blur-3xl pointer-events-none" />
          <div className="absolute bottom-0 left-0 w-96 h-96 bg-emerald-500/10 rounded-full blur-3xl pointer-events-none" />

          <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center relative z-10">
            
            {/* Visual Column — Official Dark Courier Dashboard Visual with ImageReveal */}
            <div className="lg:col-span-5 order-2 lg:order-1 flex justify-center">
              <ImageReveal delay={0.2} className="w-full max-w-md">
                <div className="relative rounded-3xl overflow-hidden border border-gray-800 shadow-2xl bg-gray-900">
                  <Image
                    src="/experience/courier/courier-dashboard.webp"
                    alt="Talabaty Courier Dashboard Visual"
                    width={1024}
                    height={576}
                    className="w-full h-auto object-cover"
                    priority
                  />
                </div>
              </ImageReveal>
            </div>

            {/* Text Column (Col 7) */}
            <div className="lg:col-span-7 order-1 lg:order-2">
              <StaggerContainer className="flex flex-col items-start text-right w-full">
                
                <StaggerChild>
                  <SectionLabel text={isRTL ? "للمناديب" : "For Couriers"} />
                </StaggerChild>

                <StaggerChild>
                  <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-white tracking-tight mb-4 leading-tight">
                    {t("courierTitle")}
                  </h2>
                </StaggerChild>

                <StaggerChild>
                  <p className="text-base sm:text-lg text-gray-300 font-medium mb-8 max-w-xl">
                    {t("courierSubtitle")}
                  </p>
                </StaggerChild>

                {/* Checklist */}
                <StaggerChild className="w-full">
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 mb-8 w-full">
                    {features.map((feat, idx) => (
                      <div
                        key={idx}
                        className="flex items-center gap-3 bg-gray-800/60 p-3.5 rounded-2xl border border-gray-700/60"
                      >
                        <CheckCircle className="w-5 h-5 text-emerald-400 flex-shrink-0" />
                        <span className="text-sm font-bold text-gray-200">{feat}</span>
                      </div>
                    ))}
                  </div>
                </StaggerChild>

                {/* Vehicles & CTA */}
                <StaggerChild className="w-full">
                  <div className="flex flex-col sm:flex-row items-center justify-between gap-6 pt-6 border-t border-gray-800 w-full">
                    <motion.div
                      whileHover={{ scale: 1.015 }}
                      whileTap={{ scale: 0.98 }}
                      transition={{ duration: MOTION_TOKENS.FAST }}
                      className="w-full sm:w-auto"
                    >
                      <Link
                        href="/courier"
                        className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-8 py-4 rounded-2xl text-base font-bold text-white bg-[#FF5722] hover:bg-[#E64A19] shadow-lg shadow-orange-500/25 transition-colors duration-200"
                      >
                        <span>{t("joinCourierNow")}</span>
                        <ArrowIcon className="w-5 h-5" />
                      </Link>
                    </motion.div>
                  </div>
                </StaggerChild>

              </StaggerContainer>
            </div>

          </div>

        </div>

      </div>
    </section>
  );
}
