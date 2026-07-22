"use client";

import React from "react";
import Link from "next/link";
import Image from "next/image";
import { useLanguage } from "@/context/LanguageContext";
import { Phone, Mail, MapPin } from "lucide-react";

export default function Footer() {
  const { lang, t } = useLanguage();
  const isRTL = lang === "ar";

  return (
    <footer className="bg-[#1A1D27] text-white pt-16 pb-12 border-t border-gray-800">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-12 gap-10 pb-12 border-b border-gray-800">
          
          {/* Brand Info Column (Col 5) */}
          <div className="lg:col-span-5 flex flex-col items-start text-right">
            <Link href="/" className="mb-4">
              <Image
                src="/experience/brand/logo.webp"
                alt="Talabaty Logo"
                width={150}
                height={50}
                className="h-10 w-auto object-contain brightness-0 invert"
              />
            </Link>
            
            <p className="text-[#FF5722] font-bold text-base mb-3">
              {t("brandLine")}
            </p>

            <p className="text-gray-400 text-sm font-medium leading-relaxed max-w-sm">
              {t("footerDesc")}
            </p>
          </div>

          {/* Navigation Links Column (Col 4) */}
          <div className="lg:col-span-4 grid grid-cols-2 gap-6 text-right">
            <div>
              <h4 className="text-sm font-bold text-white mb-4">
                {isRTL ? "عن طلباتي" : "About Talabaty"}
              </h4>
              <ul className="space-y-2.5 text-sm text-gray-400 font-medium">
                <li><Link href="/" className="hover:text-white transition-colors">{t("home")}</Link></li>
                <li><Link href="/#services" className="hover:text-white transition-colors">{t("services")}</Link></li>
                <li><Link href="/#how-it-works" className="hover:text-white transition-colors">{t("howItWorks")}</Link></li>
                <li><Link href="/#coverage" className="hover:text-white transition-colors">{t("coverage")}</Link></li>
                <li><Link href="/#founders" className="hover:text-white transition-colors">{t("founders")}</Link></li>
              </ul>
            </div>

            <div>
              <h4 className="text-sm font-bold text-white mb-4">
                {isRTL ? "انضم إلينا" : "Join Us"}
              </h4>
              <ul className="space-y-2.5 text-sm text-gray-400 font-medium">
                <li><Link href="/#merchants" className="hover:text-white transition-colors">{t("merchants")}</Link></li>
                <li><Link href="/#couriers" className="hover:text-white transition-colors">{t("couriers")}</Link></li>
                <li><Link href="/#faq" className="hover:text-white transition-colors">{t("faq")}</Link></li>
                <li><Link href="/contact" className="hover:text-white transition-colors">{t("contact")}</Link></li>
              </ul>
            </div>
          </div>

          {/* Official Contact Info Column (Col 3) */}
          <div className="lg:col-span-3 text-right">
            <h4 className="text-sm font-bold text-white mb-4">
              {isRTL ? "تواصل معنا" : "Contact Us"}
            </h4>
            <ul className="space-y-3 text-sm text-gray-400 font-medium">
              <li className="flex items-center gap-3 justify-end lg:justify-start">
                <a href="tel:+249911421515" dir="ltr" className="hover:text-orange-400 transition-colors font-mono">
                  +249911421515
                </a>
                <Phone className="w-4 h-4 text-[#FF5722] shrink-0" />
              </li>
              <li className="flex items-center gap-3 justify-end lg:justify-start">
                <a href="mailto:support@mytalabaty.com" className="hover:text-orange-400 transition-colors">
                  support@mytalabaty.com
                </a>
                <Mail className="w-4 h-4 text-[#FF5722] shrink-0" />
              </li>
              <li className="flex items-center gap-3 justify-end lg:justify-start">
                <span>{isRTL ? "الخرطوم - الرياض، السودان" : "Khartoum - Al Riyadh, Sudan"}</span>
                <MapPin className="w-4 h-4 text-[#FF5722] shrink-0" />
              </li>
            </ul>
          </div>

        </div>

        {/* Bottom Bar: Copyright & Legal Links */}
        <div className="pt-8 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs text-gray-500 font-medium">
          <p>© 2026 طلباتي - Talabaty. {t("allRightsReserved")}</p>
          
          <div className="flex items-center gap-6">
            <Link href="/privacy" className="hover:text-gray-300 transition-colors">
              {t("privacyPolicy")}
            </Link>
            <Link href="/terms" className="hover:text-gray-300 transition-colors">
              {t("termsAndConditions")}
            </Link>
          </div>
        </div>

      </div>
    </footer>
  );
}
