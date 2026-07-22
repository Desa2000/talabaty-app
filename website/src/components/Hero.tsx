"use client";

import React, { useState, useEffect } from "react";
import Link from "next/link";
import Image from "next/image";
import { useLanguage } from "@/context/LanguageContext";
import { Download, Store, Zap, ShieldCheck, Star, MapPin, Clock } from "lucide-react";
import { motion, AnimatePresence, useScroll, useTransform } from "framer-motion";
import { FadeUp, Float, SlideIn } from "@/components/motion/Animations";
import { ShimmerButton } from "./ui/ShimmerButton";
import { FlipWords } from "./ui/FlipWords";

export default function Hero() {
  const { t } = useLanguage();
  const [currentScreen, setCurrentScreen] = useState(0);
  const [isHovered, setIsHovered] = useState(false);
  const screens = ["/app-screens/screen1.png", "/app-screens/screen2.png", "/app-screens/screen3.png"];

  useEffect(() => {
    if (isHovered) return;
    const timer = setInterval(() => {
      setCurrentScreen((prev) => (prev + 1) % screens.length);
    }, 4000);
    return () => clearInterval(timer);
  }, [isHovered, screens.length]);

  const { scrollYProgress } = useScroll();
  const parallaxY1 = useTransform(scrollYProgress, [0, 1], ["0%", "50%"]);
  const parallaxY2 = useTransform(scrollYProgress, [0, 1], ["0%", "-30%"]);
  const parallaxY3 = useTransform(scrollYProgress, [0, 1], ["0%", "20%"]);

  // Fallback if translation is not available yet
  const heroTitleMainWords = t("heroTitleMain")?.split(" ") || ["أسرع..", "أسهل..", "أقرب"];

  return (
    <section className="relative overflow-hidden bg-gradient-to-b from-[#FFFDF9] via-[#FFF8F2] to-white pt-10 pb-20 lg:pt-16 lg:pb-28">
      {/* Background Ambient Elements with very slow parallax */}
      <motion.div style={{ y: parallaxY1 }} className="absolute top-0 right-1/4 w-96 h-96 bg-orange-400/10 rounded-full blur-3xl pointer-events-none" />
      <motion.div style={{ y: parallaxY2 }} className="absolute top-1/3 left-10 w-80 h-80 bg-amber-300/10 rounded-full blur-3xl pointer-events-none" />
      
      {/* Sudanese Silhouette Graphic Subtle Pattern */}
      <motion.div style={{ y: parallaxY3 }} className="absolute inset-x-0 bottom-0 h-32 opacity-[0.04] pointer-events-none bg-[radial-gradient(#FF5722_1px,transparent_1px)] [background-size:16px_16px]" />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-8 items-center">
          
          {/* Text Content Column */}
          <div className="lg:col-span-7 text-center lg:text-right flex flex-col items-center lg:items-start">
            
            {/* Top Badge slides down */}
            <motion.div
              initial={{ opacity: 0, y: -20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.1, duration: 0.5, type: "spring", stiffness: 120 }}
              className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-orange-100/70 border border-orange-200/80 text-[#FF5722] text-xs sm:text-sm font-bold mb-6 shadow-sm"
            >
              <Zap className="w-4 h-4 fill-[#FF5722]" />
              <span>المنصة السودانية الأولى للتوصيل السريع 🇸🇩</span>
            </motion.div>

            {/* Main Headline with staggered word-by-word reveal */}
            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold text-[#1A1D27] tracking-tight leading-[1.15] mb-6 flex flex-col items-center lg:items-start">
              <motion.span
                initial={{ opacity: 0, y: 15 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.5, delay: 0.2 }}
              >
                {t("heroTitlePrefix")}
              </motion.span>
              <div className="mt-2 text-[#FF5722] drop-shadow-sm flex items-center gap-2">
                <FlipWords words={heroTitleMainWords} duration={2500} />
              </div>
            </h1>

            {/* Subtitle Paragraph fades up after headlines */}
            <FadeUp delay={1.1}>
              <p className="text-lg sm:text-xl text-gray-600 font-medium max-w-2xl leading-relaxed mb-8">
                {t("heroDescription")}
              </p>
            </FadeUp>


            {/* Action Buttons appear after text */}
            <FadeUp delay={1.3}>
              <div className="flex flex-col sm:flex-row items-center gap-4 w-full sm:w-auto mb-10">
                <Link href="#download" className="w-full sm:w-auto">
                  <ShimmerButton className="w-full sm:w-auto text-base px-8 py-4 rounded-2xl">
                    <Download className="w-5 h-5" />
                    <span>{t("downloadApp")}</span>
                  </ShimmerButton>
                </Link>

                <Link
                  href="/merchant"
                  className="w-full sm:w-auto inline-flex items-center justify-center gap-2.5 px-8 py-4 rounded-2xl text-base font-bold text-[#FF5722] bg-white border-2 border-[#FF5722] hover:bg-orange-50 shadow-sm transition-all active:scale-95"
                >
                  <Store className="w-5 h-5" />
                  <span>{t("joinMerchant")}</span>
                </Link>
              </div>
            </FadeUp>

            {/* Highlight Badges stagger in */}
            <div className="grid grid-cols-2 sm:grid-cols-3 gap-4 pt-4 border-t border-orange-100/80 w-full overflow-hidden p-1">
              {[
                { icon: "⚡", title: "سرعة التوصيل", subtitle: "خلال دقائق", bg: "bg-orange-50", text: "text-[#FF5722]", border: "border-orange-100" },
                { icon: "🛡️", title: "أمان وسهولة", subtitle: "دفع بالبنك والكاش", bg: "bg-emerald-50", text: "text-emerald-600", border: "border-orange-100" },
                { icon: "📍", title: "تغطية واسعة", subtitle: "أقرب محلاتك", bg: "bg-blue-50", text: "text-blue-600", border: "border-orange-100", colSpan: "col-span-2 sm:col-span-1" }
              ].map((badge, i) => (
                <motion.div
                  key={i}
                  custom={i}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 1.5 + i * 0.15, type: "spring", stiffness: 100 }}
                  className={`flex items-center gap-3 bg-white/80 backdrop-blur-sm p-3 rounded-xl border ${badge.border} ${badge.colSpan || ''}`}
                >
                  <div className={`w-10 h-10 rounded-lg ${badge.bg} flex items-center justify-center ${badge.text} font-bold`}>
                    {badge.icon}
                  </div>
                  <div className="text-right">
                    <span className="block text-xs text-gray-400 font-medium">{badge.title}</span>
                    <span className="text-sm font-bold text-[#1A1D27]">{badge.subtitle}</span>
                  </div>
                </motion.div>
              ))}
            </div>

          </div>

          {/* Phone Visual Column */}
          <div className="lg:col-span-5 relative flex justify-center items-center mt-10 lg:mt-0">
            
            {/* Ambient Background Glow Behind Phone */}
            <div className="absolute w-72 h-72 sm:w-80 sm:h-80 bg-gradient-to-tr from-[#FF5722]/30 to-amber-300/30 rounded-full blur-2xl -z-10" />

            <SlideIn direction="up" delay={0.4}>
              <motion.div 
                animate={{ y: [-6, 6, -6] }}
                transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }}
              >
                {/* Main Phone Container Frame */}
                <div 
                  className="relative w-[280px] sm:w-[320px] h-[570px] sm:h-[620px] bg-[#1A1D27] rounded-[48px] p-3 shadow-2xl shadow-orange-950/20 border-4 border-gray-800"
                  onMouseEnter={() => setIsHovered(true)}
                  onMouseLeave={() => setIsHovered(false)}
                >
                  {/* Phone Speaker Notch */}
                  <div className="absolute top-5 left-1/2 -translate-x-1/2 w-32 h-5 bg-black rounded-full z-20 flex items-center justify-center">
                    <div className="w-3 h-3 bg-gray-900 rounded-full ml-4" />
                  </div>

                  {/* Screen Content Wrapper */}
                  <div className="relative w-full h-full bg-white rounded-[38px] overflow-hidden flex flex-col pt-7">
                    
                    {/* Embedded Real App Screen Image with crossfade carousel */}
                    <div className="relative w-full h-full bg-gray-100">
                      <AnimatePresence mode="wait">
                        <motion.div
                          key={currentScreen}
                          initial={{ opacity: 0 }}
                          animate={{ opacity: 1 }}
                          exit={{ opacity: 0 }}
                          transition={{ duration: 0.6 }}
                          className="absolute inset-0"
                        >
                          <Image
                            src={screens[currentScreen]}
                            alt={`Talabaty App Mobile Screen ${currentScreen + 1}`}
                            fill
                            className="object-cover object-top"
                            priority={currentScreen === 0}
                            onError={(e) => {
                              (e.target as HTMLElement).style.display = "none";
                            }}
                          />
                        </motion.div>
                      </AnimatePresence>

                      {/* App Screen Header Simulation Over Overlay */}
                      <div className="absolute top-0 inset-x-0 bg-gradient-to-b from-black/60 via-black/20 to-transparent p-4 pt-6 text-white text-right z-10 pointer-events-none">
                        <div className="flex items-center justify-between text-xs font-bold">
                          <span className="bg-[#FF5722] px-2 py-0.5 rounded-full text-[10px]">مباشر 🟢</span>
                          <span className="text-gray-200">الخرطوم، السودان 📍</span>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </motion.div>
            </SlideIn>

            {/* Floating Info Card 1 - Top Left */}
            <motion.div 
              initial={{ opacity: 0, scale: 0.8, x: -20 }}
              animate={{ opacity: 1, scale: 1, x: 0, y: [0, -8, 0] }}
              transition={{ 
                opacity: { delay: 1.2, duration: 0.5 },
                scale: { delay: 1.2, duration: 0.5, type: "spring" },
                x: { delay: 1.2, duration: 0.5, type: "spring" },
                y: { delay: 1.2, duration: 3, repeat: Infinity, ease: "easeInOut" }
              }}
              className="absolute top-12 -left-4 sm:-left-8 bg-white/95 backdrop-blur-md p-3.5 rounded-2xl border border-orange-100 shadow-xl flex items-center gap-3 z-20"
            >
              <div className="w-10 h-10 rounded-xl bg-orange-500 text-white flex items-center justify-center text-lg font-bold shadow-md shadow-orange-500/30">
                🍔
              </div>
              <div className="text-right">
                <span className="block text-xs font-bold text-[#1A1D27]">أشهى الوجبات</span>
                <span className="text-[11px] text-gray-500">من أفضل المطاعم</span>
              </div>
            </motion.div>

            {/* Floating Info Card 2 - Bottom Right */}
            <motion.div 
              initial={{ opacity: 0, scale: 0.8, x: 20 }}
              animate={{ opacity: 1, scale: 1, x: 0, y: [0, 8, 0] }}
              transition={{ 
                opacity: { delay: 1.5, duration: 0.5 },
                scale: { delay: 1.5, duration: 0.5, type: "spring" },
                x: { delay: 1.5, duration: 0.5, type: "spring" },
                y: { delay: 1.5, duration: 3.5, repeat: Infinity, ease: "easeInOut" }
              }}
              className="absolute bottom-16 -right-4 sm:-right-8 bg-white/95 backdrop-blur-md p-3.5 rounded-2xl border border-emerald-100 shadow-xl flex items-center gap-3 z-20"
            >
              <div className="w-10 h-10 rounded-xl bg-emerald-500 text-white flex items-center justify-center text-lg font-bold shadow-md shadow-emerald-500/30">
                🛵
              </div>
              <div className="text-right">
                <span className="block text-xs font-bold text-[#1A1D27]">تتبع حي مباشر</span>
                <span className="text-[11px] text-emerald-600 font-semibold">المندوب في الطريق</span>
              </div>
            </motion.div>

          </div>

        </div>
      </div>
    </section>
  );
}
