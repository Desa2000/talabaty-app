"use client";

import React from "react";
import Link from "next/link";
import Image from "next/image";
import { useLanguage } from "@/context/LanguageContext";
import { Heart } from "lucide-react";

export default function Footer() {
  const { t } = useLanguage();

  return (
    <footer className="bg-white border-t border-[#F0EAE1] pt-16 pb-8 text-right">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-10 pb-12 border-b border-gray-100">
          
          {/* Brand Info Column (Col 2) */}
          <div className="lg:col-span-2 flex flex-col items-start">
            <Link href="/" className="flex items-center gap-3 mb-4">
              <div className="w-10 h-10 rounded-xl bg-orange-50 p-1">
                <Image
                  src="/logo.png"
                  alt="Talabaty Logo"
                  width={40}
                  height={40}
                  className="object-contain w-full h-full"
                />
              </div>
              <span className="font-extrabold text-2xl text-[#1A1D27]">
                طلباتي
              </span>
            </Link>

            <p className="text-sm font-medium text-gray-500 max-w-sm leading-relaxed mb-6">
              {t("footerDesc")}
            </p>

            {/* Social Icons Placeholder Badges (Clean UI without fake URLs) */}
            <div className="flex items-center gap-2">
              {["facebook", "instagram", "twitter", "whatsapp"].map((icon, i) => (
                <div
                  key={i}
                  className="w-9 h-9 rounded-xl bg-orange-50 text-[#FF5722] flex items-center justify-center text-sm font-bold border border-orange-100/60"
                >
                  {icon === "facebook" && "f"}
                  {icon === "instagram" && "📷"}
                  {icon === "twitter" && "𝕏"}
                  {icon === "whatsapp" && "💬"}
                </div>
              ))}
            </div>
          </div>

          {/* Column 1: طلباتي */}
          <div>
            <h3 className="font-bold text-[#1A1D27] text-base mb-4">طلباتي</h3>
            <ul className="space-y-2.5 text-sm font-semibold text-gray-600">
              <li>
                <Link href="/" className="hover:text-[#FF5722] transition-colors">
                  {t("home")}
                </Link>
              </li>
              <li>
                <Link href="/#how-it-works" className="hover:text-[#FF5722] transition-colors">
                  {t("howItWorks")}
                </Link>
              </li>
              <li>
                <Link href="/#services" className="hover:text-[#FF5722] transition-colors">
                  {t("services")}
                </Link>
              </li>
              <li>
                <Link href="/#faq" className="hover:text-[#FF5722] transition-colors">
                  {t("faq")}
                </Link>
              </li>
            </ul>
          </div>

          {/* Column 2: للعملاء */}
          <div>
            <h3 className="font-bold text-[#1A1D27] text-base mb-4">{t("forCustomers")}</h3>
            <ul className="space-y-2.5 text-sm font-semibold text-gray-600">
              <li>
                <Link href="/#how-it-works" className="hover:text-[#FF5722] transition-colors">
                  {t("orderingMethod")}
                </Link>
              </li>
              <li>
                <Link href="/#download" className="hover:text-[#FF5722] transition-colors">
                  {t("trackOrder")}
                </Link>
              </li>
              <li>
                <Link href="/contact" className="hover:text-[#FF5722] transition-colors">
                  {t("techSupport")}
                </Link>
              </li>
            </ul>
          </div>

          {/* Column 3: للتجار والمناديب */}
          <div>
            <h3 className="font-bold text-[#1A1D27] text-base mb-4">{t("forMerchants")} والمناديب</h3>
            <ul className="space-y-2.5 text-sm font-semibold text-gray-600">
              <li>
                <Link href="/merchant" className="hover:text-[#FF5722] transition-colors">
                  {t("joinMerchant")}
                </Link>
              </li>
              <li>
                <Link href="/courier" className="hover:text-[#FF5722] transition-colors">
                  {t("joinCourier")}
                </Link>
              </li>
              <li>
                <Link href="/terms" className="hover:text-[#FF5722] transition-colors">
                  {t("merchantTerms")}
                </Link>
              </li>
              <li>
                <Link href="/terms" className="hover:text-[#FF5722] transition-colors">
                  {t("courierTerms")}
                </Link>
              </li>
            </ul>
          </div>

        </div>

        {/* Bottom Bar */}
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

      </div>
    </footer>
  );
}
