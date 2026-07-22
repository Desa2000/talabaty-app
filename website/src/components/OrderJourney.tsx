"use client";

import React, { useRef } from "react";
import Image from "next/image";
import { useLanguage } from "@/context/LanguageContext";
import { Store, CheckCircle, Bike, MapPin } from "lucide-react";
import { motion, useScroll, useSpring, useTransform } from "framer-motion";
import { FadeUp, SectionLabel, ImageReveal } from "@/components/motion/Animations";

export default function OrderJourney() {
  const { lang } = useLanguage();
  const isRTL = lang === "ar";
  const containerRef = useRef<HTMLDivElement>(null);

  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start end", "end start"],
  });

  const scaleY = useSpring(scrollYProgress, { damping: 25, stiffness: 180 });
  const opacityProgress = useTransform(scrollYProgress, [0.1, 0.4], [0.3, 1]);

  const stages = [
    {
      num: "01",
      title: isRTL ? "المحل" : "The Store",
      desc: isRTL
        ? "اختار مطعمك، سوبرماركتك أو صيدليتك البتحبها"
        : "Choose your favorite restaurant, supermarket or pharmacy",
      icon: Store,
      color: "bg-orange-50 text-[#FF5722]",
    },
    {
      num: "02",
      title: isRTL ? "تأكيد الطلب" : "Order Confirmation",
      desc: isRTL
        ? "المتجر يبدأ في تجهيز طلبك فوراً وبكل جودة"
        : "Store prepares your order carefully right away",
      icon: CheckCircle,
      color: "bg-emerald-50 text-emerald-600",
    },
    {
      num: "03",
      title: isRTL ? "المندوب وفي الطريق" : "Courier En Route",
      desc: isRTL
        ? "مندوب طلباتي يستلم الطلب وينطلق أسرع مسار"
        : "Talabaty courier picks up & delivers via fastest route",
      icon: Bike,
      color: "bg-blue-50 text-blue-600",
    },
    {
      num: "04",
      title: isRTL ? "الوصول لحدي عندك" : "Arrived To You",
      desc: isRTL
        ? "تسليم الطلب لحدي باب بيتك أو مكانك"
        : "Order delivered straight to your doorstep",
      icon: MapPin,
      color: "bg-amber-50 text-amber-600",
    },
  ];

  return (
    <section id="how-it-works" ref={containerRef} className="py-20 lg:py-28 bg-[#FAF7F2] border-y border-[#F0EAE1] relative overflow-hidden scroll-mt-24">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        
        {/* Chapter Header */}
        <FadeUp>
          <div className="text-center max-w-2xl mx-auto mb-16">
            <SectionLabel text={isRTL ? "رحلة الطلب" : "Order Journey"} />
            <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-[#1A1D27] tracking-tight mb-4">
              {isRTL ? "من عندهم.. لحدي عندك" : "From Them... Straight To You"}
            </h2>
            <p className="text-base sm:text-lg text-gray-600 font-medium leading-relaxed">
              {isRTL
                ? "تتبع رحلة طلبك خطوة بخطوة من أول ما تأكد الطلب لحدي يصلك."
                : "Track your order journey step by step from confirmation to delivery."}
            </p>
          </div>
        </FadeUp>

        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
          
          {/* Left Column: Visual Storytelling Illustration */}
          <div className="lg:col-span-6">
            <ImageReveal delay={0.2}>
              <div className="bg-white rounded-3xl p-6 sm:p-8 border border-orange-100/90 shadow-xl shadow-orange-950/5 relative overflow-hidden">
                <div className="relative w-full aspect-[4/3] rounded-2xl overflow-hidden bg-[#FAF7F2]">
                  <Image
                    src="/experience/journey/order-journey.webp"
                    alt="Talabaty Order Journey Visual"
                    fill
                    sizes="(max-width: 1024px) 100vw, 550px"
                    className="object-contain object-center"
                    priority
                  />
                </div>
              </div>
            </ImageReveal>
          </div>

          {/* Right Column: Scroll-Linked Timeline Steps */}
          <div className="lg:col-span-6 relative">
            
            {/* Background Timeline Line */}
            <div className="absolute top-4 bottom-4 right-6 w-1 bg-gray-200 rounded-full" />
            
            {/* Scroll Progress Active Line */}
            <motion.div
              style={{ scaleY, opacity: opacityProgress }}
              className="absolute top-4 bottom-4 right-6 w-1 bg-[#FF5722] rounded-full origin-top"
            />

            <div className="space-y-8 pr-14 relative z-10">
              {stages.map((st, idx) => {
                const IconComp = st.icon;
                return (
                  <motion.div
                    key={idx}
                    initial={{ opacity: 0, x: isRTL ? 25 : -25 }}
                    whileInView={{ opacity: 1, x: 0 }}
                    viewport={{ once: true, margin: "-40px" }}
                    transition={{ duration: 0.5, delay: idx * 0.1 }}
                    className="bg-white rounded-2xl p-5 border border-gray-100 shadow-xs flex items-start gap-4 relative group hover:border-orange-200 transition-colors"
                  >
                    {/* Stage Icon Circle */}
                    <div className={`w-11 h-11 rounded-xl ${st.color} flex items-center justify-center shrink-0 font-bold shadow-xs`}>
                      <IconComp className="w-5 h-5" />
                    </div>

                    <div>
                      <div className="flex items-center gap-2 mb-1">
                        <span className="text-xs font-bold text-[#FF5722]">{st.num}</span>
                        <h3 className="text-lg font-bold text-[#1A1D27]">{st.title}</h3>
                      </div>
                      <p className="text-sm text-gray-600 font-medium leading-relaxed">
                        {st.desc}
                      </p>
                    </div>
                  </motion.div>
                );
              })}
            </div>

          </div>

        </div>

      </div>
    </section>
  );
}
