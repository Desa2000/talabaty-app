"use client";

import React, { useState, useEffect } from "react";
import Link from "next/link";
import Image from "next/image";
import { usePathname } from "next/navigation";
import { useLanguage } from "@/context/LanguageContext";
import { Menu, X, Globe, ArrowLeft, ArrowRight } from "lucide-react";

export default function Navbar() {
  const { lang, dir, toggleLanguage, t } = useLanguage();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);
  const pathname = usePathname();

  useEffect(() => {
    const handleScroll = () => {
      if (window.scrollY > 20) {
        setScrolled(true);
      } else {
        setScrolled(false);
      }
    };
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  const navItems = [
    { label: t("home"), href: "/" },
    { label: t("services"), href: "/#services" },
    { label: t("howItWorks"), href: "/#how-it-works" },
    { label: t("merchants"), href: "/merchant" },
    { label: t("couriers"), href: "/courier" },
    { label: t("faq"), href: "/#faq" },
    { label: t("contact"), href: "/contact" },
  ];

  const isLinkActive = (href: string) => {
    if (href === "/") return pathname === "/";
    if (href.startsWith("/#")) return pathname === "/" && typeof window !== "undefined" && window.location.hash === href.substring(1);
    return pathname === href;
  };

  return (
    <header
      className={`sticky top-0 z-50 transition-all duration-300 ${
        scrolled
          ? "bg-white/95 backdrop-blur-md shadow-sm border-b border-[#F0EAE1]"
          : "bg-white border-b border-[#F0EAE1]/60"
      }`}
    >
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-20">
          {/* Logo Section */}
          <div className="flex-shrink-0 flex items-center">
            <Link href="/" className="flex items-center gap-3 group">
              <div className="relative w-12 h-12 overflow-hidden rounded-xl bg-orange-50 p-1 transition-transform group-hover:scale-105">
                <Image
                  src="/logo.png"
                  alt="Talabaty Logo"
                  width={48}
                  height={48}
                  className="object-contain w-full h-full"
                  priority
                />
              </div>
              <div className="flex flex-col">
                <span className="font-extrabold text-2xl text-[#1A1D27] tracking-tight group-hover:text-[#FF5722] transition-colors">
                  طلباتي
                </span>
                <span className="text-[10px] font-medium text-gray-400 tracking-wider uppercase -mt-1">
                  Talabaty Sudan
                </span>
              </div>
            </Link>
          </div>

          {/* Desktop Navigation Links */}
          <nav className="hidden lg:flex items-center space-x-1 space-x-reverse xl:space-x-2 xl:space-x-reverse">
            {navItems.map((item) => {
              const active = isLinkActive(item.href);
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  className={`px-3 py-2 text-sm font-semibold transition-all relative ${
                    active
                      ? "text-[#FF5722]"
                      : "text-[#1A1D27] hover:text-[#FF5722]"
                  }`}
                >
                  {item.label}
                  {active && (
                    <span className="absolute bottom-0 left-3 right-3 h-0.5 bg-[#FF5722] rounded-full animate-pulse" />
                  )}
                </Link>
              );
            })}
          </nav>

          {/* Actions Left Section */}
          <div className="hidden lg:flex items-center gap-3">
            {/* Language Selector Toggle */}
            <button
              onClick={toggleLanguage}
              className="flex items-center gap-1.5 px-3 py-2 rounded-xl text-xs font-bold text-gray-700 hover:text-[#FF5722] hover:bg-orange-50/70 border border-gray-200 transition-all"
              title="Change Language"
            >
              <Globe className="w-4 h-4 text-[#FF5722]" />
              <span>{lang === "ar" ? "English" : "عربي"}</span>
            </button>

            {/* Primary Orange Download Button */}
            <Link
              href="/#download"
              className="inline-flex items-center justify-center px-5 py-2.5 rounded-xl font-bold text-sm text-white bg-[#FF5722] hover:bg-[#E64A19] shadow-md shadow-orange-500/20 hover:shadow-lg hover:shadow-orange-500/30 transition-all active:scale-95"
            >
              {t("downloadApp")}
            </Link>
          </div>

          {/* Mobile Menu Button */}
          <div className="flex items-center gap-2 lg:hidden">
            <button
              onClick={toggleLanguage}
              className="flex items-center gap-1 px-2.5 py-1.5 rounded-lg text-xs font-bold text-gray-700 bg-gray-100 border border-gray-200"
            >
              <Globe className="w-3.5 h-3.5 text-[#FF5722]" />
              <span>{lang === "ar" ? "EN" : "عربي"}</span>
            </button>

            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="p-2 rounded-xl text-gray-700 hover:text-[#FF5722] hover:bg-orange-50 transition-colors"
              aria-label="Toggle Navigation Menu"
            >
              {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
            </button>
          </div>
        </div>
      </div>

      {/* Mobile Drawer Menu */}
      {mobileMenuOpen && (
        <div className="lg:hidden bg-white border-b border-[#F0EAE1] shadow-xl px-4 pt-2 pb-6 space-y-3 animate-in slide-in-from-top duration-200">
          <div className="flex flex-col space-y-1">
            {navItems.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                onClick={() => setMobileMenuOpen(false)}
                className={`px-4 py-3 rounded-xl text-base font-bold transition-all ${
                  isLinkActive(item.href)
                    ? "bg-orange-50 text-[#FF5722]"
                    : "text-[#1A1D27] hover:bg-gray-50"
                }`}
              >
                {item.label}
              </Link>
            ))}
          </div>

          <div className="pt-2 border-t border-gray-100 flex flex-col gap-2">
            <Link
              href="/#download"
              onClick={() => setMobileMenuOpen(false)}
              className="w-full text-center py-3 rounded-xl font-bold text-white bg-[#FF5722] shadow-md shadow-orange-500/20"
            >
              {t("downloadApp")}
            </Link>
          </div>
        </div>
      )}
    </header>
  );
}
