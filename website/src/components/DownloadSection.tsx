"use client";

import React from "react";
import Image from "next/image";
import { useLanguage } from "@/context/LanguageContext";
import { QrCode, Sparkles } from "lucide-react";
import { motion } from "framer-motion";
import {
  FadeUp,
  SlideIn,
  Float,
  StaggerContainer,
  StaggerChild,
} from "@/components/motion/Animations";

export default function DownloadSection() {
  const { t } = useLanguage();

  return (
    <section id="download" className="py-20 lg:py-28 bg-gradient-to-b from-[#FFF8F2] to-white relative overflow-hidden">
      
      {/* Ambient Decorative Blurs */}
      <div className="absolute top-1/3 right-10 w-96 h-96 bg-orange-300/10 rounded-full blur-3xl pointer-events-none" />
      <div className="absolute bottom-0 left-10 w-96 h-96 bg-amber-300/10 rounded-full blur-3xl pointer-events-none" />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        
        {/* Large Rounded Banner Container */}
        <motion.div 
          initial={{ opacity: 0, scale: 0.96 }}
          whileInView={{ opacity: 1, scale: 1 }}
          viewport={{ once: true, margin: "-100px" }}
          transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
          className="bg-gradient-to-r from-[#FF5722] via-[#F4511E] to-[#E64A19] rounded-[40px] p-8 sm:p-12 lg:p-16 text-white shadow-2xl shadow-orange-500/20 relative overflow-hidden"
        >
          
          {/* Background Decorative Pattern */}
          <div className="absolute inset-0 opacity-10 bg-[radial-gradient(#FFF_1px,transparent_1px)] [background-size:20px_20px] pointer-events-none" />

          <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center relative z-10">
            
            {/* Text & Store Buttons Column */}
            <div className="lg:col-span-7 flex flex-col items-start text-right">
              
              <StaggerContainer className="w-full flex flex-col items-start text-right">
                
                <StaggerChild>
                  <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-white/20 backdrop-blur-md text-white text-xs font-bold mb-6">
                    <Sparkles className="w-4 h-4" />
                    <span>تطبيق الجوال للتوصيل السريع 📱</span>
                  </div>
                </StaggerChild>

                <StaggerChild>
                  <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight mb-4 leading-tight">
                    {t("downloadTitle")}
                  </h2>
                </StaggerChild>

                <StaggerChild>
                  <p className="text-base sm:text-lg text-orange-100 font-medium mb-10 max-w-xl">
                    {t("downloadSubtitle")}
                  </p>
                </StaggerChild>

              </StaggerContainer>

              {/* App Store Buttons Group */}
              <div className="flex flex-col sm:flex-row items-center gap-4 w-full sm:w-auto mb-8">
                
                {/* Google Play Button */}
                <SlideIn direction="up" delay={0.2} className="w-full sm:w-auto">
                  <div className="relative w-full sm:w-auto bg-black/80 hover:bg-black text-white px-6 py-3.5 rounded-2xl border border-white/20 flex items-center gap-3 transition-all cursor-default group">
                    <span className="text-3xl">🤖</span>
                    <div className="text-right">
                      <span className="block text-[10px] text-gray-400 font-medium uppercase tracking-wider">
                        احصل عليه على
                      </span>
                      <span className="text-base font-bold">Google Play</span>
                    </div>
                    <span className="absolute -top-2.5 -right-2 bg-amber-400 text-black text-[10px] font-black px-2 py-0.5 rounded-full shadow-md">
                      {t("comingSoon")}
                    </span>
                  </div>
                </SlideIn>

                {/* App Store Button */}
                <SlideIn direction="up" delay={0.3} className="w-full sm:w-auto">
                  <div className="relative w-full sm:w-auto bg-black/80 hover:bg-black text-white px-6 py-3.5 rounded-2xl border border-white/20 flex items-center gap-3 transition-all cursor-default group">
                    <span className="text-3xl">🍎</span>
                    <div className="text-right">
                      <span className="block text-[10px] text-gray-400 font-medium uppercase tracking-wider">
                        تنزيل من
                      </span>
                      <span className="text-base font-bold">App Store</span>
                    </div>
                    <span className="absolute -top-2.5 -right-2 bg-amber-400 text-black text-[10px] font-black px-2 py-0.5 rounded-full shadow-md">
                      {t("comingSoon")}
                    </span>
                  </div>
                </SlideIn>

              </div>

              {/* QR Code Container */}
              <FadeUp delay={0.4} className="w-full sm:w-auto">
                <div className="flex items-center gap-4 bg-white/10 backdrop-blur-md p-4 rounded-2xl border border-white/20">
                  <div className="w-16 h-16 bg-white p-2 rounded-xl flex items-center justify-center relative">
                    <QrCode className="w-12 h-12 text-[#1A1D27]" />
                  </div>
                  <div className="text-right">
                    <span className="block text-sm font-bold text-white">
                      {t("qrScanTitle")}
                    </span>
                    <span className="text-xs text-orange-200">
                      استمتع بتجربة أسرع وأسهل للطلب
                    </span>
                  </div>
                </div>
              </FadeUp>

            </div>

            {/* Screenshots Visual Column */}
            <div className="lg:col-span-5 relative flex justify-center items-center mt-10 lg:mt-0">
              <motion.div
                initial={{ y: 150, opacity: 0, rotate: -10 }}
                whileInView={{ y: 0, opacity: 1, rotate: 0 }}
                viewport={{ once: true, margin: "-50px" }}
                transition={{ 
                  type: "spring",
                  damping: 20,
                  stiffness: 100,
                  mass: 1,
                  delay: 0.2
                }}
              >
                <Float>
                  <div className="relative w-[260px] h-[500px] bg-black/90 rounded-[40px] p-3 border-4 border-white/30 shadow-2xl">
                    <div className="relative w-full h-full bg-white rounded-[30px] overflow-hidden">
                      <Image
                        src="/app-screens/screen1.png"
                        alt="Talabaty Mobile App Screenshots"
                        fill
                        className="object-cover object-top"
                      />
                    </div>
                  </div>
                </Float>
              </motion.div>
            </div>

          </div>

        </motion.div>

      </div>
    </section>
  );
}
