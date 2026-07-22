"use client";

import React from "react";
import Link from "next/link";
import Image from "next/image";
import { useLanguage } from "@/context/LanguageContext";
import { motion } from "framer-motion";
import { FadeUp, StaggerContainer, StaggerChild } from "@/components/motion/Animations";

export default function Footer() {
  const { t } = useLanguage();

  return (
    <footer className="bg-white border-t border-[#F0EAE1] pt-16 pb-8 text-right">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        <StaggerContainer className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-10 pb-12 border-b border-gray-100">
          
          {/* Brand Info Column (Col 2) */}
          <StaggerChild className="lg:col-span-2 flex flex-col items-start">
            <Link href="/" className="flex items-center gap-3 mb-4 group">
              <motion.div
                whileHover={{ scale: 1.05 }}
                transition={{ type: "spring", stiffness: 400, damping: 15 }}
                className="w-10 h-10 rounded-xl bg-orange-50 p-1"
              >
                <Image
                  src="/logo.png"
                  alt="Talabaty Logo"
                  width={40}
                  height={40}
                  className="object-contain w-full h-full"
                />
              </motion.div>
              <span className="font-extrabold text-2xl text-[#1A1D27] group-hover:text-[#FF5722] transition-colors">
                طلباتي
              </span>
            </Link>

            <p className="text-sm font-medium text-gray-500 max-w-sm leading-relaxed mb-6">
              {t("footerDesc")}
            </p>

            {/* Social Icons */}
            <div className="flex items-center gap-2">
              {["facebook", "instagram", "twitter", "whatsapp"].map((icon, i) => (
                <motion.div
                  key={i}
                  whileHover={{ scale: 1.1, y: -2 }}
                  whileTap={{ scale: 0.95 }}
                  transition={{ type: "spring", stiffness: 400, damping: 15 }}
                  className="w-9 h-9 rounded-xl bg-orange-50 text-[#FF5722] flex items-center justify-center text-sm font-bold border border-orange-100/60 cursor-pointer hover:bg-orange-100 transition-colors"
                >
                  {icon === "facebook" && "f"}
                  {icon === "instagram" && "📷"}
                  {icon === "twitter" && "𝕏"}
                  {icon === "whatsapp" && "💬"}
                </motion.div>
              ))}
            </div>
          </StaggerChild>

          {/* Column 1: طلباتي */}
          <StaggerChild>
            <h3 className="font-bold text-[#1A1D27] text-base mb-4">طلباتي</h3>
            <ul className="space-y-2.5 text-sm font-semibold text-gray-600">
              {[
                { href: "/", label: t("home") },
                { href: "/#how-it-works", label: t("howItWorks") },
                { href: "/#services", label: t("services") },
                { href: "/#faq", label: t("faq") },
              ].map((item) => (
                <li key={item.href}>
                  <Link
                    href={item.href}
                    className="hover:text-[#FF5722] transition-colors inline-block hover:translate-x-[-2px]"
                    style={{ transition: "color 0.2s, transform 0.2s" }}
                  >
                    {item.label}
                  </Link>
                </li>
              ))}
            </ul>
          </StaggerChild>

          {/* Column 2: للعملاء */}
          <StaggerChild>
            <h3 className="font-bold text-[#1A1D27] text-base mb-4">{t("forCustomers")}</h3>
            <ul className="space-y-2.5 text-sm font-semibold text-gray-600">
              {[
                { href: "/#how-it-works", label: t("orderingMethod") },
                { href: "/#download", label: t("trackOrder") },
                { href: "/contact", label: t("techSupport") },
              ].map((item) => (
                <li key={item.href}>
                  <Link
                    href={item.href}
                    className="hover:text-[#FF5722] transition-colors inline-block hover:translate-x-[-2px]"
                    style={{ transition: "color 0.2s, transform 0.2s" }}
                  >
                    {item.label}
                  </Link>
                </li>
              ))}
            </ul>
          </StaggerChild>

          {/* Column 3: للتجار والمناديب */}
          <StaggerChild>
            <h3 className="font-bold text-[#1A1D27] text-base mb-4">{t("forMerchants")} والمناديب</h3>
            <ul className="space-y-2.5 text-sm font-semibold text-gray-600">
              {[
                { href: "/merchant", label: t("joinMerchant") },
                { href: "/courier", label: t("joinCourier") },
                { href: "/terms", label: t("merchantTerms") },
                { href: "/terms", label: t("courierTerms") },
              ].map((item, idx) => (
                <li key={idx}>
                  <Link
                    href={item.href}
                    className="hover:text-[#FF5722] transition-colors inline-block hover:translate-x-[-2px]"
                    style={{ transition: "color 0.2s, transform 0.2s" }}
                  >
                    {item.label}
                  </Link>
                </li>
              ))}
            </ul>
          </StaggerChild>

        </StaggerContainer>

        {/* Bottom Bar */}
        <FadeUp delay={0.2}>
          <div className="pt-8 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs font-semibold text-gray-500">
            <div>
              © 2026 Talabaty - طلباتي. {t("allRightsReserved")}
            </div>

            <div className="flex items-center gap-6">
              <Link href="/privacy" className="hover:text-[#FF5722] transition-colors">
                {t("privacyPolicy")}
              </Link>
              <Link href="/terms" className="hover:text-[#FF5722] transition-colors">
                {t("termsAndConditions")}
              </Link>
            </div>
          </div>
        </FadeUp>

      </div>
    </footer>
  );
}
