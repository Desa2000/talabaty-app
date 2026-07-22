"use client";

import React, { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { usePathname } from "next/navigation";
import { useLanguage } from "@/context/LanguageContext";
import { Menu, X, Globe } from "lucide-react";
import { motion, AnimatePresence, useScroll, useMotionValueEvent } from "framer-motion";
import ScrollProgress from "@/components/motion/ScrollProgress";

export default function Navbar() {
  const { lang, toggleLanguage, t } = useLanguage();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);
  const pathname = usePathname();
  const { scrollY } = useScroll();

  useMotionValueEvent(scrollY, "change", (latest) => {
    if (latest > 20) {
      setScrolled(true);
    } else {
      setScrolled(false);
    }
  });

  const navItems = [
    { label: t("home"), href: "/" },
    { label: t("services"), href: "/#services" },
    { label: t("howItWorks"), href: "/#how-it-works" },
    { label: t("founders"), href: "/#founders" },
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
    <motion.header
      initial={{ y: -100 }}
      animate={{ y: 0 }}
      transition={{ type: "spring", stiffness: 100, damping: 20 }}
      className={`fixed top-0 left-0 right-0 z-50 transition-colors duration-300 ${
        scrolled
          ? "bg-white/95 backdrop-blur-md shadow-sm border-b border-[#F0EAE1]"
          : "bg-transparent border-b border-transparent"
      }`}
    >
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-20">
          {/* Logo Section */}
          <div className="flex-shrink-0 flex items-center">
            <Link href="/" className="flex items-center gap-3 group">
              <motion.div 
                whileHover={{ scale: 1.05 }}
                transition={{ type: "spring", stiffness: 400, damping: 10 }}
                className="relative w-12 h-12 overflow-hidden rounded-xl bg-orange-50 p-1"
              >
                <Image
                  src="/logo.png"
                  alt="Talabaty Logo"
                  width={48}
                  height={48}
                  className="object-contain w-full h-full"
                  priority
                />
              </motion.div>
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
                  className="relative px-3 py-2 text-sm font-semibold transition-colors"
                >
                  <motion.span
                    whileHover={{ scale: 1.05 }}
                    whileTap={{ scale: 0.95 }}
                    className={`block transition-colors ${
                      active
                        ? "text-[#FF5722]"
                        : "text-[#1A1D27] hover:text-[#FF5722]"
                    }`}
                  >
                    {item.label}
                  </motion.span>
                  {active && (
                    <motion.span
                      layoutId="activeNavIndicator"
                      className="absolute bottom-0 left-3 right-3 h-0.5 bg-[#FF5722] rounded-full"
                      initial={{ opacity: 0 }}
                      animate={{ opacity: 1 }}
                      transition={{ duration: 0.3 }}
                    />
                  )}
                </Link>
              );
            })}
          </nav>

          {/* Actions Left Section */}
          <div className="hidden lg:flex items-center gap-3">
            {/* Language Selector Toggle */}
            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              onClick={toggleLanguage}
              className="flex items-center gap-1.5 px-3 py-2 rounded-xl text-xs font-bold text-gray-700 hover:text-[#FF5722] hover:bg-orange-50/70 border border-gray-200 transition-colors"
              title="Change Language"
            >
              <Globe className="w-4 h-4 text-[#FF5722]" />
              <span>{lang === "ar" ? "English" : "عربي"}</span>
            </motion.button>

            {/* Primary Orange Download Button */}
            <motion.div whileHover={{ scale: 1.05 }} whileTap={{ scale: 0.95 }}>
              <Link
                href="/#download"
                className="inline-flex items-center justify-center px-5 py-2.5 rounded-xl font-bold text-sm text-white bg-[#FF5722] hover:bg-[#E64A19] shadow-md shadow-orange-500/20 hover:shadow-lg hover:shadow-orange-500/30 transition-shadow"
              >
                {t("downloadApp")}
              </Link>
            </motion.div>
          </div>

          {/* Mobile Menu Button */}
          <div className="flex items-center gap-2 lg:hidden">
            <motion.button
              whileTap={{ scale: 0.9 }}
              onClick={toggleLanguage}
              className="flex items-center gap-1 px-2.5 py-1.5 rounded-lg text-xs font-bold text-gray-700 bg-gray-100 border border-gray-200"
            >
              <Globe className="w-3.5 h-3.5 text-[#FF5722]" />
              <span>{lang === "ar" ? "EN" : "عربي"}</span>
            </motion.button>

            <motion.button
              whileTap={{ scale: 0.9 }}
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="p-2 rounded-xl text-gray-700 hover:text-[#FF5722] hover:bg-orange-50 transition-colors"
              aria-label="Toggle Navigation Menu"
            >
              {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
            </motion.button>
          </div>
        </div>
      </div>

      {/* Mobile Drawer Menu */}
      <AnimatePresence>
        {mobileMenuOpen && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: "auto" }}
            exit={{ opacity: 0, height: 0 }}
            transition={{ duration: 0.3, ease: "easeInOut" }}
            className="lg:hidden bg-white border-b border-[#F0EAE1] shadow-xl overflow-hidden"
          >
            <div className="px-4 pt-2 pb-6 space-y-3">
              <div className="flex flex-col space-y-1">
                {navItems.map((item) => (
                  <Link
                    key={item.href}
                    href={item.href}
                    onClick={() => setMobileMenuOpen(false)}
                    className={`px-4 py-3 rounded-xl text-base font-bold transition-colors ${
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
          </motion.div>
        )}
      </AnimatePresence>
      <ScrollProgress />
    </motion.header>
  );
}
