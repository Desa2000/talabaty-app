"use client";

import React, { useState, useEffect } from "react";
import Link from "next/link";
import Image from "next/image";
import { useLanguage } from "@/context/LanguageContext";
import { Globe, Menu, X } from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";
import { MOTION_TOKENS } from "@/components/motion/Animations";

export default function Navbar() {
  const { lang, toggleLanguage, t } = useLanguage();
  const [scrolled, setScrolled] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 15);
    };
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  const navLinks = [
    { name: t("home"), href: "/" },
    { name: t("services"), href: "/#services" },
    { name: t("howItWorks"), href: "/#how-it-works" },
    { name: t("merchants"), href: "/#merchants" },
    { name: t("couriers"), href: "/#couriers" },
    { name: t("coverage"), href: "/#coverage" },
    { name: t("founders"), href: "/#founders" },
    { name: t("faq"), href: "/#faq" },
    { name: t("contact"), href: "/contact" },
  ];

  return (
    <header
      className={`fixed top-0 inset-x-0 z-50 transition-all duration-300 ${
        scrolled
          ? "bg-white/85 backdrop-blur-md border-b border-[#F0EAE1]/80 shadow-xs py-3"
          : "bg-transparent py-5"
      }`}
    >
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between">
          
          {/* Logo */}
          <Link href="/" className="flex items-center gap-2 group">
            <Image
              src="/experience/brand/logo.webp"
              alt="Talabaty Logo"
              width={140}
              height={45}
              className="h-10 w-auto object-contain transition-transform group-hover:scale-102 duration-200"
              priority
            />
          </Link>

          {/* Desktop Navigation Links */}
          <nav className="hidden lg:flex items-center gap-6 xl:gap-8">
            {navLinks.map((link, idx) => (
              <Link
                key={idx}
                href={link.href}
                className="text-sm font-bold text-gray-700 hover:text-[#FF5722] transition-colors duration-200"
              >
                {link.name}
              </Link>
            ))}
          </nav>

          {/* Actions Column (Lang Switcher + CTA Button) */}
          <div className="hidden lg:flex items-center gap-4">
            <motion.button
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              transition={{ duration: MOTION_TOKENS.FAST }}
              type="button"
              onClick={toggleLanguage}
              className="flex items-center gap-1.5 px-3 py-2 rounded-xl text-xs font-bold text-gray-700 bg-gray-100/80 hover:bg-gray-200/80 transition-colors"
              aria-label="Toggle language"
            >
              <Globe className="w-4 h-4 text-[#FF5722]" />
              <span>{lang === "ar" ? "English" : "عربي"}</span>
            </motion.button>

            <motion.span
              whileHover={{ scale: 1.015 }}
              whileTap={{ scale: 0.98 }}
              transition={{ duration: MOTION_TOKENS.FAST }}
              className="px-5 py-2.5 rounded-xl text-sm font-bold text-white bg-[#FF5722] shadow-sm shadow-orange-500/20 cursor-default select-none inline-block"
            >
              {t("downloadApp")}
            </motion.span>
          </div>

          {/* Mobile Menu Button */}
          <div className="flex items-center gap-3 lg:hidden">
            <button
              type="button"
              onClick={toggleLanguage}
              className="p-2 rounded-xl text-xs font-bold text-gray-700 bg-gray-100/80"
              aria-label="Toggle language"
            >
              <Globe className="w-4 h-4 text-[#FF5722]" />
            </button>

            <button
              type="button"
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="p-2.5 rounded-xl bg-gray-100/80 text-gray-800 focus:outline-none"
              aria-label="Open mobile menu"
            >
              {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
            </button>
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
            transition={{ duration: 0.25, ease: MOTION_TOKENS.EASE_PREMIUM }}
            className="lg:hidden bg-white/95 backdrop-blur-md border-b border-[#F0EAE1] shadow-lg overflow-hidden"
          >
            <div className="px-4 pt-4 pb-6 space-y-3 text-right">
              {navLinks.map((link, idx) => (
                <Link
                  key={idx}
                  href={link.href}
                  onClick={() => setMobileMenuOpen(false)}
                  className="block py-2.5 px-4 rounded-xl text-base font-bold text-[#1A1D27] hover:bg-orange-50 hover:text-[#FF5722] transition-colors"
                >
                  {link.name}
                </Link>
              ))}

              <div className="pt-4 border-t border-gray-100">
                <span className="block w-full text-center py-3 rounded-xl text-base font-bold text-white bg-[#FF5722] shadow-sm shadow-orange-500/20">
                  {t("downloadApp")}
                </span>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </header>
  );
}
