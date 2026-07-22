"use client";

import React, { useRef } from "react";
import { useLanguage } from "@/context/LanguageContext";
import { Store, ShoppingCart, CheckCircle2, Navigation } from "lucide-react";
import { motion, useInView, useScroll, useTransform } from "framer-motion";
import { FadeUp, StaggerContainer, StaggerChild } from "@/components/motion/Animations";

function StepCard({ step, idx }: { step: any; idx: number }) {
  const cardRef = useRef(null);
  const isInView = useInView(cardRef, { once: true, margin: "-10%" });
  const StepIcon = step.icon;

  return (
    <StaggerChild>
      <motion.div
        ref={cardRef}
        whileHover={{ y: -4 }}
        className="bg-white rounded-3xl p-8 border border-[#F0EAE1] shadow-card hover:shadow-card-hover transition-shadow duration-300 text-center flex flex-col items-center group relative h-full"
      >
        {/* Number Badge Circle */}
        <div className="relative mb-6">
          <motion.div
            initial={{ backgroundColor: "#F3F4F6", color: "#9CA3AF" }}
            animate={
              isInView
                ? { backgroundColor: "#FF5722", color: "#FFFFFF" }
                : { backgroundColor: "#F3F4F6", color: "#9CA3AF" }
            }
            transition={{ duration: 0.5, delay: idx * 0.15 }}
            className="w-16 h-16 rounded-full flex items-center justify-center text-2xl font-black shadow-lg group-hover:shadow-orange-500/30 transition-shadow"
          >
            {step.number}
          </motion.div>

          {/* Step Icon Badge */}
          <motion.div
            initial={{ scale: 0, opacity: 0 }}
            animate={isInView ? { scale: 1, opacity: 1 } : { scale: 0, opacity: 0 }}
            transition={{
              type: "spring",
              stiffness: 260,
              damping: 20,
              delay: idx * 0.15 + 0.2
            }}
            className="absolute -bottom-1 -right-1 w-8 h-8 rounded-full bg-orange-50 border-2 border-white flex items-center justify-center text-[#FF5722] shadow-sm"
          >
            <StepIcon className="w-4 h-4" />
          </motion.div>
        </div>

        {/* Title & Desc */}
        <h3 className="text-xl font-bold text-[#1A1D27] mb-2 group-hover:text-[#FF5722] transition-colors">
          {step.title}
        </h3>
        <p className="text-sm font-medium text-gray-500 leading-relaxed">
          {step.desc}
        </p>
      </motion.div>
    </StaggerChild>
  );
}

export default function HowItWorks() {
  const { t, lang } = useLanguage();
  const isRTL = lang === "ar";
  
  const sectionRef = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: sectionRef,
    offset: ["start 75%", "end center"],
  });

  const lineWidth = useTransform(scrollYProgress, [0, 1], ["0%", "100%"]);

  const steps = [
    {
      number: "1",
      icon: Store,
      title: t("step1Title"),
      desc: t("step1Desc"),
    },
    {
      number: "2",
      icon: ShoppingCart,
      title: t("step2Title"),
      desc: t("step2Desc"),
    },
    {
      number: "3",
      icon: CheckCircle2,
      title: t("step3Title"),
      desc: t("step3Desc"),
    },
    {
      number: "4",
      icon: Navigation,
      title: t("step4Title"),
      desc: t("step4Desc"),
    },
  ];

  return (
    <section id="how-it-works" className="py-20 lg:py-28 bg-[#FAF7F2] relative overflow-hidden" ref={sectionRef}>
      
      {/* Background Decorative Circles */}
      <div className="absolute top-1/2 left-0 -translate-y-1/2 w-96 h-96 bg-orange-200/20 rounded-full blur-3xl pointer-events-none" />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        
        {/* Section Header */}
        <FadeUp>
          <div className="text-center max-w-2xl mx-auto mb-16 lg:mb-24">
            <span className="inline-block px-4 py-1.5 rounded-full bg-orange-100 text-[#FF5722] text-xs font-bold mb-4">
              خطوات بسيطة وسريعة
            </span>
            <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-[#1A1D27] tracking-tight">
              {t("howTitle")}
            </h2>
          </div>
        </FadeUp>

        {/* 4 Steps Layout Container */}
        <div className="relative">
          
          {/* Desktop Connecting Dotted Line */}
          <div className="hidden lg:block absolute top-1/2 left-12 right-12 -translate-y-1/2 h-0.5 z-0 pointer-events-none">
            {/* Dashed background line */}
            <div className="absolute inset-0 border-t-2 border-dashed border-[#F0EAE1]" />
            
            {/* Progress line */}
            <motion.div 
              className="absolute top-0 bottom-0 bg-[#FF5722]"
              style={{ 
                width: lineWidth, 
                left: isRTL ? "auto" : 0, 
                right: isRTL ? 0 : "auto" 
              }} 
            />
            
            {/* Delivery Tracking Micro-Animation (Moving Dot) */}
            <motion.div
              className="absolute top-1/2 -translate-y-1/2 w-3 h-3 bg-[#FF5722] rounded-full shadow-[0_0_8px_rgba(255,87,34,0.8)]"
              animate={{
                [isRTL ? "right" : "left"]: ["0%", "100%"]
              }}
              transition={{
                duration: 4,
                repeat: Infinity,
                ease: "linear",
              }}
              style={{
                [isRTL ? "right" : "left"]: 0,
              }}
            />
          </div>

          <StaggerContainer>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8 relative z-10">
              {steps.map((step, idx) => (
                <StepCard key={idx} step={step} idx={idx} />
              ))}
            </div>
          </StaggerContainer>
        </div>

      </div>
    </section>
  );
}
