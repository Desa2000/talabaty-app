"use client";

import React from "react";
import Image from "next/image";
import { useLanguage } from "@/context/LanguageContext";
import { FadeUp, StaggerContainer, StaggerChild, SectionLabel } from "@/components/motion/Animations";
import { motion } from "framer-motion";

export default function FoundersSection() {
  const { lang } = useLanguage();
  const isRTL = lang === "ar";

  const founders = [
    {
      name: isRTL ? "مازن محمد حسن النعيم" : "Mazen Mohamed Hassan Alnaeem",
      role: isRTL ? "مؤسس مشارك" : "Co-Founder",
      image: "/founders/mazen-mohamed-hassan-alnaeem.jpg",
      objectPos: "object-center",
    },
    {
      name: isRTL ? "المدثر عامر الفاضل" : "Almodther Amer Alfadel",
      role: isRTL ? "مؤسس مشارك" : "Co-Founder",
      image: "/founders/almodther-amer-alfadel.jpg",
      objectPos: "object-center",
    },
  ];

  return (
    <section id="founders" className="py-20 lg:py-28 bg-white relative overflow-hidden">
      
      {/* Subtle Brand Watermark in Background */}
      <div className="absolute inset-0 flex items-center justify-center opacity-[0.03] pointer-events-none select-none overflow-hidden">
        <Image
          src="/logo.png"
          alt="Talabaty Watermark"
          width={550}
          height={550}
          className="object-contain filter grayscale"
        />
      </div>

      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        {/* Section Header */}
        <FadeUp>
          <div className="text-center max-w-2xl mx-auto mb-14">
            <SectionLabel text={isRTL ? "فريق القيادة" : "Leadership Team"} />
            <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-[#1A1D27] tracking-tight mb-3">
              {isRTL ? "مؤسسو طلباتي" : "Talabaty Founders"}
            </h2>
            <p className="text-base sm:text-lg text-gray-600 font-medium leading-relaxed">
              {isRTL
                ? "فريق سوداني شغال عشان يخلي الطلب والتوصيل أسهل وأسرع."
                : "A Sudanese team building a faster and easier delivery experience."}
            </p>
          </div>
        </FadeUp>

        {/* Founders Cards Grid (Desktop: 2 side-by-side, Mobile: stacked) */}
        <StaggerContainer className="grid grid-cols-1 md:grid-cols-2 gap-8 max-w-4xl mx-auto">
          {founders.map((founder, idx) => (
            <StaggerChild key={idx}>
              <div className="bg-[#FAF7F2]/70 rounded-3xl p-6 sm:p-8 border border-orange-100/80 shadow-xs flex flex-col items-center text-center group">
                
                {/* Photo Container - Max scale 1.02 on hover */}
                <div className="relative w-full aspect-[4/4.5] max-w-[280px] mb-6 rounded-2xl overflow-hidden border border-orange-100 shadow-sm">
                  <Image
                    src={founder.image}
                    alt={founder.name}
                    fill
                    sizes="(max-width: 768px) 280px, 320px"
                    className={`object-cover ${founder.objectPos} group-hover:scale-[1.02] transition-transform duration-300`}
                    priority={idx === 0}
                  />
                </div>

                {/* Name & Role */}
                <h3 className="text-xl sm:text-2xl font-bold text-[#1A1D27] mb-2">
                  {founder.name}
                </h3>
                <span className="inline-block px-3.5 py-1 rounded-full bg-white text-[#FF5722] text-xs font-bold border border-orange-100">
                  {founder.role}
                </span>
              </div>
            </StaggerChild>
          ))}
        </StaggerContainer>
      </div>
    </section>
  );
}
