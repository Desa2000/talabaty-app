"use client";

import React from "react";
import Link from "next/link";
import Image from "next/image";
import { useLanguage } from "@/context/LanguageContext";
import { Bike, CheckCircle, ArrowLeft, ArrowRight } from "lucide-react";
import { FadeUp, SlideIn, StaggerContainer, StaggerChild } from "@/components/motion/Animations";
import { motion } from "framer-motion";

export default function CourierSection() {
  const { lang, t } = useLanguage();
  const isRtl = lang === "ar";
  const ArrowIcon = isRtl ? ArrowLeft : ArrowRight;

  const features = [
    t("cFeat1"),
    t("cFeat2"),
    t("cFeat3"),
    t("cFeat4"),
    t("cFeat5"),
  ];

  const supportedVehicles = [
    { name: t("motorcycle"), icon: "🏍️", badge: "أسرع خيار" },
    { name: t("electricBike"), icon: "⚡", badge: "اقتصادي" },
    { name: t("bicycle"), icon: "🚲", badge: "صديق للبيئة" },
  ];

  return (
    <section className="py-20 lg:py-28 bg-[#FAF7F2]">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        <FadeUp>
          {/* Large Rounded Card Wrapper */}
          <div className="bg-white rounded-[40px] p-8 sm:p-12 lg:p-16 border border-[#F0EAE1] shadow-card relative overflow-hidden">
            
            {/* Subtle Background Glow */}
            <div className="absolute bottom-0 left-0 w-80 h-80 bg-emerald-400/10 rounded-full blur-3xl pointer-events-none" />

            <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center relative z-10">
              
              {/* Visual Column (Col 5) */}
              <div className="lg:col-span-5 order-2 lg:order-1 relative flex justify-center">
                <SlideIn direction="right" delay={0.2} className="w-full flex justify-center">
                  {/* Outer Card Mockup Shell */}
                  <div className="relative w-full max-w-sm bg-gradient-to-b from-gray-900 to-[#1A1D27] text-white rounded-3xl p-6 shadow-2xl border border-gray-800 overflow-hidden">
                    
                    {/* Courier Status Bar Mock */}
                    <motion.div 
                      initial={{ opacity: 0, y: 10 }}
                      whileInView={{ opacity: 1, y: 0 }}
                      viewport={{ once: true }}
                      transition={{ delay: 0.4 }}
                      className="flex items-center justify-between border-b border-gray-800 pb-4 mb-4"
                    >
                      <div className="flex items-center gap-3">
                        <div className="w-12 h-12 rounded-2xl bg-emerald-500 text-white flex items-center justify-center font-bold text-xl shadow-md shadow-emerald-500/30">
                          🛵
                        </div>
                        <div className="text-right">
                          <span className="block text-sm font-bold">محمد أحمد (مندوب)</span>
                          <span className="text-xs text-emerald-400 font-semibold">متصل ومتاح للطلبات 🟢</span>
                        </div>
                      </div>
                      <span className="bg-emerald-500/20 text-emerald-300 text-xs font-bold px-2.5 py-1 rounded-full border border-emerald-500/30">
                        4.9 ⭐
                      </span>
                    </motion.div>

                    {/* Delivery Route Animation */}
                    <motion.div 
                      initial={{ opacity: 0 }}
                      whileInView={{ opacity: 1 }}
                      viewport={{ once: true }}
                      transition={{ delay: 0.5 }}
                      className="relative w-full h-12 bg-gray-800/80 rounded-xl border border-gray-700/60 mb-4 px-4 flex items-center justify-between overflow-hidden"
                    >
                      <div className="absolute left-6 right-6 top-1/2 -translate-y-1/2 h-[2px] border-t-2 border-dashed border-gray-600" />
                      
                      {/* Pickup Dot */}
                      <div className="relative z-10 w-3 h-3 rounded-full bg-blue-400 border-2 border-gray-900" />
                      
                      {/* Moving Courier Dot */}
                      <div className="absolute left-6 right-6 top-1/2 -translate-y-1/2 h-0">
                        <motion.div 
                          className="absolute top-1/2 -translate-y-1/2 w-4 h-4 -ml-2 rounded-full bg-[#FF5722] shadow-[0_0_10px_#FF5722] border-2 border-gray-900 z-20"
                          animate={{ 
                            left: ["0%", "100%", "0%"],
                            scale: [1, 1.2, 1]
                          }}
                          transition={{ 
                            duration: 3, 
                            repeat: Infinity, 
                            ease: "easeInOut" 
                          }}
                        />
                      </div>

                      {/* Delivery Dot */}
                      <div className="relative z-10 w-3 h-3 rounded-full bg-emerald-400 border-2 border-gray-900" />
                    </motion.div>

                    {/* Earnings & Delivery Count Box */}
                    <div className="grid grid-cols-2 gap-3 mb-4">
                      <motion.div 
                        initial={{ opacity: 0, y: 20 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        viewport={{ once: true }}
                        transition={{ delay: 0.6 }}
                        className="bg-gray-800/80 p-3 rounded-xl border border-gray-700/60 text-right"
                      >
                        <span className="block text-[11px] text-gray-400 font-medium">أرباح اليوم</span>
                        <span className="text-base font-black text-emerald-400">18,000 ج.س</span>
                      </motion.div>
                      <motion.div 
                        initial={{ opacity: 0, y: 20 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        viewport={{ once: true }}
                        transition={{ delay: 0.7 }}
                        className="bg-gray-800/80 p-3 rounded-xl border border-gray-700/60 text-right"
                      >
                        <span className="block text-[11px] text-gray-400 font-medium">توصيلات اليوم</span>
                        <span className="text-base font-black text-orange-400">12 توصيلة</span>
                      </motion.div>
                    </div>

                    {/* Embedded Screen Image */}
                    <motion.div 
                      initial={{ opacity: 0, scale: 0.95 }}
                      whileInView={{ opacity: 1, scale: 1 }}
                      viewport={{ once: true }}
                      transition={{ delay: 0.8, duration: 0.5 }}
                      className="relative h-56 w-full rounded-2xl overflow-hidden border border-gray-800"
                    >
                      <Image
                        src="/app-screens/screen3.png"
                        alt="Talabaty Courier App Preview"
                        fill
                        className="object-cover object-center"
                      />
                    </motion.div>

                  </div>
                </SlideIn>
              </div>

              {/* Text Column (Col 7) */}
              <div className="lg:col-span-7 order-1 lg:order-2">
                <StaggerContainer className="flex flex-col items-start text-right w-full">
                  
                  <StaggerChild>
                    <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-emerald-100 text-emerald-700 text-xs font-bold mb-6">
                      <Bike className="w-4 h-4" />
                      <span>فرص عمل ودخل ممتاز 💰</span>
                    </div>
                  </StaggerChild>

                  <StaggerChild>
                    <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-[#1A1D27] tracking-tight mb-4 leading-tight">
                      {t("courierTitle")}
                    </h2>
                  </StaggerChild>

                  <StaggerChild>
                    <p className="text-base sm:text-lg text-gray-600 font-medium mb-8 max-w-xl">
                      {t("courierSubtitle")}
                    </p>
                  </StaggerChild>

                  {/* Checklist */}
                  <StaggerChild className="w-full">
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 mb-8 w-full">
                      {features.map((feat, idx) => (
                        <motion.div 
                          key={idx}
                          initial={{ opacity: 0, x: 20 }}
                          whileInView={{ opacity: 1, x: 0 }}
                          viewport={{ once: true }}
                          transition={{ delay: 0.1 * idx }}
                          className="flex items-center gap-3 bg-[#FAF7F2] p-3.5 rounded-2xl border border-[#F0EAE1]"
                        >
                          <CheckCircle className="w-5 h-5 text-emerald-600 flex-shrink-0" />
                          <span className="text-sm font-bold text-[#1A1D27]">{feat}</span>
                        </motion.div>
                      ))}
                    </div>
                  </StaggerChild>

                  {/* Supported Vehicles Box */}
                  <StaggerChild className="w-full">
                    <div className="w-full bg-orange-50/70 rounded-2xl p-4 border border-orange-100 mb-8">
                      <span className="block text-xs font-bold text-[#FF5722] mb-3">
                        {t("supportedVehiclesTitle")}
                      </span>
                      <div className="flex flex-wrap gap-3">
                        {supportedVehicles.map((v, i) => (
                          <motion.div 
                            key={i} 
                            whileHover={{ scale: 1.05, y: -2 }}
                            transition={{ type: "spring", stiffness: 400, damping: 10 }}
                            className="flex items-center gap-2 bg-white px-3.5 py-2 rounded-xl border border-orange-200/60 shadow-sm cursor-pointer"
                          >
                            <span className="text-lg">{v.icon}</span>
                            <span className="text-xs font-bold text-[#1A1D27]">{v.name}</span>
                            <span className="text-[10px] font-semibold text-[#FF5722] bg-orange-100 px-1.5 py-0.5 rounded">
                              {v.badge}
                            </span>
                          </motion.div>
                        ))}
                      </div>
                    </div>
                  </StaggerChild>

                  {/* CTA Button */}
                  <StaggerChild>
                    <motion.div whileHover={{ scale: 1.02, boxShadow: "0px 10px 20px rgba(255, 87, 34, 0.3)" }} className="inline-block rounded-2xl">
                      <Link
                        href="/courier"
                        className="inline-flex items-center justify-center gap-3 px-8 py-4 rounded-2xl text-base font-bold text-white bg-[#FF5722] hover:bg-[#E64A19] shadow-lg shadow-orange-500/25 transition-colors active:scale-95"
                      >
                        <span>{t("joinCourierNow")}</span>
                        <ArrowIcon className="w-5 h-5" />
                      </Link>
                    </motion.div>
                  </StaggerChild>

                </StaggerContainer>
              </div>

            </div>
          </div>
        </FadeUp>

      </div>
    </section>
  );
}
