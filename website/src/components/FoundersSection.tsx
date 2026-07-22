"use client";

import React from "react";
import Image from "next/image";
import { useLanguage } from "@/context/LanguageContext";
import { FadeUp, StaggerContainer, StaggerChild } from "@/components/motion/Animations";
import { motion } from "framer-motion";

export default function FoundersSection() {
  const { lang } = useLanguage();
  const isRTL = lang === "ar";

  const founders = [
    {
      name: isRTL ? "مازن حسن النعيم" : "Mazen Hassan Alnaeem",
      role: isRTL ? "مؤسس مشارك" : "Co-Founder",
      image: "/founders/mazen-hassan-alnaeem.jpg",
    },
    {
      name: isRTL ? "المدثر عامر الفاضل" : "Almodther Amer Alfadel",
      role: isRTL ? "مؤسس مشارك" : "Co-Founder",
      image: "/founders/almodther-amer-alfadel.png",
    },
  ];

  return (
    <section id="founders" className="py-20 bg-[#FAF7F2] relative overflow-hidden">
      {/* Brand Watermark Background */}
      <div className="absolute inset-0 flex items-center justify-center opacity-[0.03] pointer-events-none select-none overflow-hidden">
        <Image
          src="/logo.png"
          alt="Talabaty Watermark"
          width={600}
          height={600}
          className="object-contain filter grayscale"
        />
      </div>

      <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        {/* Section Header */}
        <FadeUp>
          <div className="text-center max-w-2xl mx-auto mb-14">
            <span className="text-xs font-bold text-[#FF5722] bg-orange-100/80 px-3.5 py-1.5 rounded-full border border-orange-200/80 inline-block mb-3">
              {isRTL ? "فريق العمل 🇸🇩" : "Leadership Team 🇸🇩"}
            </span>
            <h2 className="text-2xl sm:text-4xl font-extrabold text-[#1A1D27] tracking-tight mb-3">
              {isRTL ? "مؤسسو طلباتي" : "Talabaty Founders"}
            </h2>
            <p className="text-base sm:text-lg text-gray-600 font-medium leading-relaxed">
              {isRTL
                ? "الفريق الذي يعمل على بناء تجربة توصيل أسهل وأسرع في السودان."
                : "The team building a faster and easier delivery experience in Sudan."}
            </p>
          </div>
        </FadeUp>

        {/* Founders Cards Grid (Desktop: 2 side-by-side, Mobile: stacked) */}
        <StaggerContainer className="grid grid-cols-1 md:grid-cols-2 gap-8 max-w-3xl mx-auto">
          {founders.map((founder, idx) => (
            <StaggerChild key={idx}>
              <motion.div
                whileHover={{ y: -5, boxShadow: "0 20px 40px -15px rgba(255, 87, 34, 0.15)" }}
                className="bg-white rounded-3xl p-6 border border-[#F0EAE1] hover:border-[#FF5722]/40 shadow-sm transition-all duration-300 flex flex-col items-center text-center group"
              >
                {/* Photo Frame */}
                <div className="relative w-48 h-48 sm:w-56 sm:h-56 mb-6 rounded-2xl overflow-hidden border-2 border-orange-100 group-hover:border-[#FF5722] transition-colors duration-300 shadow-md">
                  <motion.div
                    initial={{ scale: 0.97 }}
                    whileInView={{ scale: 1 }}
                    viewport={{ once: true }}
                    transition={{ duration: 0.5 }}
                    className="w-full h-full"
                  >
                    <Image
                      src={founder.image}
                      alt={founder.name}
                      fill
                      sizes="(max-width: 768px) 192px, 224px"
                      className="object-cover object-center group-hover:scale-105 transition-transform duration-500"
                      priority={idx === 0}
                    />
                  </motion.div>
                </div>

                {/* Info */}
                <h3 className="text-xl sm:text-2xl font-bold text-[#1A1D27] mb-1.5">
                  {founder.name}
                </h3>
                <span className="inline-block px-3 py-1 rounded-full bg-orange-50 text-[#FF5722] text-xs font-bold border border-orange-100">
                  {founder.role}
                </span>
              </motion.div>
            </StaggerChild>
          ))}
        </StaggerContainer>
      </div>
    </section>
  );
}
