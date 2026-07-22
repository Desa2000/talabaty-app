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

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-10 items-center">
          
          {/* Text Column (Right side in RTL) */}
          <div className="lg:col-span-6 flex flex-col items-start text-right">
            <FadeUp>
              {/* Top Badge */}
              <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-white/15 text-white border border-white/20 text-xs font-bold mb-6">
                <Sparkles className="w-4 h-4 text-amber-200" />
                <span>{isRTL ? "التطبيق قريبًا" : "App Coming Soon"}</span>
              </div>

              {/* Title */}
              <h2 className="text-3xl sm:text-5xl font-black tracking-tight mb-4 leading-tight">
                {isRTL ? "طلباتي قريب في تلفونك" : "Talabaty Coming Soon to Your Phone"}
              </h2>

              {/* Subtitle */}
              <p className="text-base sm:text-lg text-orange-100 font-medium mb-8 leading-relaxed max-w-xl">
                {isRTL
                  ? "شغالين نجهز ليك تجربة طلب سريعة وسهلة من أول ضغطة لحدي عندك."
                  : "We are building a fast and seamless ordering experience straight to your doorstep."}
              </p>

              {/* Coming Soon Pill CTA */}
              <div className="inline-flex items-center gap-2 px-8 py-4 rounded-2xl bg-white text-[#FF5722] text-base font-bold shadow-xl shadow-orange-950/20 select-none">
                <span>{isRTL ? "قريبًا" : "Coming Soon"}</span>
              </div>
            </FadeUp>
          </div>

          {/* Dedicated Visual Column — Orange App Phone Visual */}
          <div className="lg:col-span-6 flex justify-center">
            <FadeUp delay={0.2} className="w-full max-w-lg">
              <div className="relative w-full rounded-3xl overflow-hidden border border-white/20 shadow-2xl bg-orange-600 aspect-[16/10]">
                <Image
                  src="/experience/app/app-coming-soon.webp"
                  alt="Talabaty App Coming Soon Visual"
                  fill
                  sizes="(max-width: 1024px) 100vw, 600px"
                  className="object-cover object-center"
                />
              </div>
            </FadeUp>
          </div>

        </div>
      </div>
    </section>
  );
}
