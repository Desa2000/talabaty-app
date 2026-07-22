"use client";

import React from "react";
import Link from "next/link";
import Image from "next/image";
import { useLanguage } from "@/context/LanguageContext";
import { CheckCircle, Store, ArrowLeft, ArrowRight } from "lucide-react";
import { motion } from "framer-motion";
import {
  FadeUp,
  SlideIn,
  StaggerContainer,
  StaggerChild,
  Float,
  ScaleIn,
} from "@/components/motion/Animations";

const MotionLink = motion(Link);

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
    <section className="py-20 lg:py-28 bg-white overflow-hidden">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Large Rounded Card Wrapper */}
        <SlideIn direction="right" className="relative w-full">
          <div className="bg-gradient-to-br from-[#FFF8F3] via-[#FAF4ED] to-white rounded-[40px] p-8 sm:p-12 lg:p-16 border border-orange-100 shadow-card relative overflow-hidden">
            
            {/* Subtle Background Glow */}
            <div className="absolute top-0 right-0 pointer-events-none">
              <Float range={20} duration={6}>
                <div className="w-80 h-80 bg-orange-400/10 rounded-full blur-3xl" />
              </Float>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center relative z-10">
              
              {/* Text Column (Col 7) */}
              <div className="lg:col-span-7 flex flex-col items-start text-right">
                <StaggerContainer>
                  
                  <StaggerChild>
                    <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-orange-100 text-[#FF5722] text-xs font-bold mb-6">
                      <Store className="w-4 h-4" />
                      <span>فرصتك للتوسع والنمو 📈</span>
                    </div>
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

                  {/* Checklist Grid */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-10 w-full">
                    {features.map((feat, idx) => (
                      <StaggerChild key={idx}>
                        <div className="flex items-center gap-3 bg-white/90 backdrop-blur-sm p-3.5 rounded-2xl border border-orange-100 shadow-sm hover:shadow-md transition-shadow">
                          <CheckCircle className="w-5 h-5 text-[#FF5722] flex-shrink-0" />
                          <span className="text-sm font-bold text-[#1A1D27]">{feat}</span>
                        </div>
                      </StaggerChild>
                    ))}
                  </div>

                  {/* CTA Button */}
                  <StaggerChild>
                    <MotionLink
                      href="/merchant"
                      whileHover={{ scale: 1.02 }}
                      whileTap={{ scale: 0.98 }}
                      className="group inline-flex items-center justify-center gap-3 px-8 py-4 rounded-2xl text-base font-bold text-white bg-[#FF5722] hover:bg-[#E64A19] shadow-lg shadow-orange-500/25 hover:shadow-2xl hover:shadow-orange-500/40 transition-all"
                    >
                      <span>{t("registerStoreNow")}</span>
                      <ArrowIcon className={`w-5 h-5 transition-transform duration-300 ${isRtl ? 'group-hover:-translate-x-1' : 'group-hover:translate-x-1'}`} />
                    </MotionLink>
                  </StaggerChild>

                </StaggerContainer>
              </div>

              {/* Visual Column (Col 5) */}
              <div className="lg:col-span-5 relative flex justify-center">
                <SlideIn direction="left" delay={0.2} className="w-full">
                  
                  {/* Outer Card Mockup Shell */}
                  <div className="relative w-full max-w-sm mx-auto bg-white rounded-3xl p-6 border border-orange-200/80 shadow-xl shadow-orange-900/5">
                    
                    {/* Store Header Mock */}
                    <FadeUp delay={0.4}>
                      <div className="flex items-center justify-between border-b border-gray-100 pb-4 mb-4">
                        <div className="flex items-center gap-3">
                          <div className="w-12 h-12 rounded-2xl bg-orange-500 text-white flex items-center justify-center font-bold text-xl shadow-md shadow-orange-500/30">
                            🏪
                          </div>
                          <div className="text-right">
                            <span className="block text-sm font-bold text-[#1A1D27]">متجرك المتميز</span>
                            <span className="text-xs text-emerald-600 font-semibold">مفتوح ويستقبل الطلبات 🟢</span>
                          </div>
                        </div>
                        <span className="bg-orange-50 text-[#FF5722] text-xs font-bold px-2.5 py-1 rounded-full border border-orange-100">
                          لوحة التجار
                        </span>
                      </div>
                    </FadeUp>

                    {/* Dashboard Stats Preview Mock */}
                    <StaggerContainer className="grid grid-cols-2 gap-3 mb-4">
                      <StaggerChild>
                        <div className="bg-orange-50/50 p-3 rounded-xl border border-orange-100/60 text-right h-full">
                          <span className="block text-[11px] text-gray-500 font-medium">مبيعات اليوم</span>
                          <span className="text-base font-black text-[#FF5722]">48,500 ج.س</span>
                        </div>
                      </StaggerChild>
                      <StaggerChild>
                        <div className="bg-emerald-50/50 p-3 rounded-xl border border-emerald-100/60 text-right h-full">
                          <span className="block text-[11px] text-gray-500 font-medium">الطلبات المكتملة</span>
                          <span className="text-base font-black text-emerald-700">24 طلب</span>
                        </div>
                      </StaggerChild>
                    </StaggerContainer>

                    {/* Embedded Screenshot Image */}
                    <ScaleIn delay={0.7}>
                      <div className="relative h-56 w-full rounded-2xl overflow-hidden border border-gray-100 shadow-inner">
                        <Image
                          src="/app-screens/screen2.png"
                          alt="Talabaty Merchant Dashboard Preview"
                          fill
                          className="object-cover object-top"
                        />
                      </div>
                    </ScaleIn>

                  </div>
                </SlideIn>
              </div>

            </div>
          </div>
        </SlideIn>

      </div>
    </section>
  );
}
