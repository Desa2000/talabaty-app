"use client";

import React from "react";
import Image from "next/image";
import { useLanguage } from "@/context/LanguageContext";
import { Sparkles } from "lucide-react";
import { FadeUp } from "@/components/motion/Animations";

export default function DownloadSection() {
  const { lang, t } = useLanguage();
  const isRTL = lang === "ar";

  return (
    <section className="py-20 lg:py-28 bg-[#FF5722] text-white relative overflow-hidden">
      
      {/* Brand Mark Watermark in Background (Opacity 4%) */}
      <div className="absolute inset-0 flex items-center justify-center opacity-[0.04] pointer-events-none select-none overflow-hidden">
        <Image
          src="/experience/brand/logo.webp"
          alt="Talabaty Brandmark"
          width={700}
          height={700}
          className="object-contain brightness-0 invert"
        />
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 text-center">
        <FadeUp>
          <div className="max-w-3xl mx-auto">
            
            {/* Top Badge */}
            <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-white/15 text-white border border-white/20 text-xs font-bold mb-6">
              <Sparkles className="w-4 h-4 text-amber-200" />
              <span>{isRTL ? "التطبيق قريبًا" : "App Coming Soon"}</span>
            </div>

            {/* Title */}
            <h2 className="text-3xl sm:text-5xl font-black tracking-tight mb-4 leading-tight">
              {t("downloadTitle")}
            </h2>

            {/* Subtitle */}
            <p className="text-base sm:text-lg text-orange-100 font-medium mb-8 leading-relaxed">
              {t("downloadSubtitle")}
            </p>

            {/* Coming Soon Pill CTA */}
            <div className="inline-flex items-center gap-2 px-8 py-4 rounded-2xl bg-white text-[#FF5722] text-base font-bold shadow-xl shadow-orange-950/20 select-none">
              <span>{t("comingSoon")}</span>
            </div>

          </div>
        </FadeUp>
      </div>
    </section>
  );
}
