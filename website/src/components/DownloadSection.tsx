"use client";

import React from "react";
import Image from "next/image";
import { useLanguage } from "@/context/LanguageContext";
import { Clock, ShieldCheck, ArrowLeft, ArrowRight } from "lucide-react";
import { motion } from "framer-motion";
import {
  FadeUp,
  Float,
  StaggerContainer,
  StaggerChild,
} from "@/components/motion/Animations";

export default function DownloadSection() {
  const { lang } = useLanguage();
  const isRTL = lang === "ar";

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
            
            {/* Text & Pure Talabaty CTA Column */}
            <div className="lg:col-span-7 flex flex-col items-start text-right">
              
              <StaggerContainer className="w-full flex flex-col items-start text-right">
                
                <StaggerChild>
                  <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-white/20 backdrop-blur-md text-white text-xs font-bold mb-6">
                    <Clock className="w-4 h-4 text-white" />
                    <span>{isRTL ? "الإطلاق القادم" : "Upcoming Launch"}</span>
                  </div>
                </StaggerChild>

                <StaggerChild>
                  <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight mb-4 leading-tight">
                    {isRTL ? "تطبيق طلباتي قريبًا" : "Talabaty App Coming Soon"}
                  </h2>
                </StaggerChild>

                <StaggerChild>
                  <p className="text-base sm:text-lg text-orange-100 font-medium mb-8 max-w-xl leading-relaxed">
                    {isRTL
                      ? "نعمل على تجهيز تجربة طلب سهلة وسريعة لتكون متاحة قريبًا لجميع عملائنا في السودان."
                      : "We are preparing a fast and seamless ordering experience, coming very soon for all our users in Sudan."}
                  </p>
                </StaggerChild>

              </StaggerContainer>

              {/* Clean Talabaty Badge CTA (No external store logos or fake buttons) */}
              <FadeUp delay={0.3} className="w-full sm:w-auto">
                <div className="inline-flex items-center gap-3 bg-white text-[#1A1D27] px-8 py-4 rounded-2xl font-extrabold text-base shadow-xl hover:bg-orange-50 transition-all">
                  <ShieldCheck className="w-5 h-5 text-[#FF5722]" />
                  <span>{isRTL ? "قريبًا على جميع المنصات" : "Coming Soon on All Platforms"}</span>
                </div>
              </FadeUp>

            </div>

            {/* Visual Column — Single Clean Phone Screenshot */}
            <div className="lg:col-span-5 flex justify-center items-center">
              <Float range={10} duration={5} className="relative w-full max-w-[280px]">
                <div className="relative rounded-[36px] overflow-hidden border-[6px] border-white/30 shadow-2xl bg-white aspect-[9/18]">
                  <Image
                    src="/app-screens/screen1.png"
                    alt="Talabaty Clean Screen Preview"
                    fill
                    sizes="280px"
                    className="object-cover object-top"
                    priority
                  />
                </div>
              </Float>
            </div>

          </div>
        </motion.div>

      </div>
    </section>
  );
}
