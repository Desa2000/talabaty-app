"use client";

import React, { useState } from "react";
import { useLanguage } from "@/context/LanguageContext";
import { ChevronDown, HelpCircle } from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";
import { FadeUp } from "@/components/motion/Animations";

export default function FaqSection() {
  const { lang } = useLanguage();
  const isRTL = lang === "ar";
  const [openIdx, setOpenIdx] = useState<number | null>(0);

  const faqs = [
    {
      q: isRTL ? "طلباتي شنو؟" : "What is Talabaty?",
      a: isRTL
        ? "طلباتي منصة سودانية للتوصيل السريع، بتوصل ليك الأكل والوجبات من المطاعم، وحاجات البيت من السوبرماركت، والأدوية والمستلزمات الطبية من الصيدليات."
        : "Talabaty is a Sudanese fast delivery platform delivering food from restaurants, home groceries, and medicines from pharmacies.",
    },
    {
      q: isRTL ? "أقدر أطلب من وين؟" : "Where can I order from?",
      a: isRTL
        ? "تقدر تطلب من أفضل المطاعم والسوبرماركات والصيدليات المسجلة معانا في تطبيق طلباتي والقريبة من موقعك."
        : "You can order from top restaurants, supermarkets, and pharmacies registered on the Talabaty app near your location.",
    },
    {
      q: isRTL ? "الدفع بيكون كيف؟" : "How do I pay?",
      a: isRTL
        ? "نوفر لك طرق دفع سهلة ومريحة: عبر تطبيق بنكك (Bankak) أو كاش نقدًا عند استلام طلبك."
        : "We support convenient payment options: via Bankak or Cash on Delivery upon order receipt.",
    },
    {
      q: isRTL ? "أتابع طلبي كيف؟" : "How do I track my order?",
      a: isRTL
        ? "تقدر تتابع طلبك خطوة بخطوة من التطبيق لحظة تحضيره وتجهيزه لحدي التوصيل واستلامه من المندوب."
        : "You can track your order step-by-step in the app from preparation until delivery by the courier.",
    },
    {
      q: isRTL ? "عندي متجر، أسجّل كيف؟" : "I own a store, how do I register?",
      a: isRTL
        ? "تقدر تسجّل متجرك بسهولة عبر الضغط على 'سجّل متجرك' في الموقع، وتعبئة البيانات ليتواصل معك فريقنا للبدء."
        : "You can easily register your store by clicking 'Register Store' on the website and submitting your details.",
    },
    {
      q: isRTL ? "داير أشتغل مندوب، أبدأ كيف؟" : "I want to work as a courier, how do I start?",
      a: isRTL
        ? "إذا عندك عجلة أو دراجة كهربائية أو موتر، تقدر تنضم لمناديب طلباتي عبر الضغط على 'انضم كمندوب' وتعبئة طلبك."
        : "If you have a bicycle, electric bike, or motorcycle, click 'Join as Courier' to apply and start working.",
    },
    {
      q: isRTL ? "طلباتي متوفر وين؟" : "Where is Talabaty available?",
      a: isRTL
        ? "الخدمة مفعلة في الخرطوم، أم درمان، وبحري، وشغالين نتوسع خطوة بخطوة في باقي الولايات والمدن السودانية."
        : "Service is active in Khartoum, Omdurman, and Bahri, and expanding step by step to other Sudanese cities.",
    },
    {
      q: isRTL ? "لو حصلت مشكلة في الطلب أعمل شنو؟" : "What if I face an issue with my order?",
      a: isRTL
        ? "فريق الدعم الفني جاهز وموجود لمساعدتك دائمًا عبر التواصل معنا بالمباشر في الموقع أو الرقم 249911421515+."
        : "Our technical support team is always ready to assist you directly on the website or via phone +249911421515.",
    },
  ];

  return (
    <section id="faq" className="py-20 bg-[#FAF7F2] border-t border-[#F0EAE1] relative overflow-hidden scroll-mt-24">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        
        {/* Header */}
        <FadeUp>
          <div className="text-center max-w-2xl mx-auto mb-14">
            <span className="text-xs font-bold text-[#FF5722] bg-orange-100/80 px-4 py-1.5 rounded-full border border-orange-200/80 inline-block mb-3">
              <HelpCircle className="w-3.5 h-3.5 inline ml-1.5" />
              {isRTL ? "الأسئلة الشائعة" : "FAQ"}
            </span>
            <h2 className="text-3xl sm:text-4xl font-extrabold text-[#1A1D27] tracking-tight mb-3">
              {isRTL ? "عندك سؤال؟" : "Have Questions?"}
            </h2>
            <p className="text-base text-gray-600 font-medium">
              {isRTL
                ? "إليك إجابات لأبرز الأسئلة والاستفسارات حول خدمة وتطبيق طلباتي."
                : "Here are answers to the most common questions about Talabaty."}
            </p>
          </div>
        </FadeUp>

        {/* FAQ Accordion List */}
        <div className="space-y-4">
          {faqs.map((faq, idx) => {
            const isOpen = openIdx === idx;
            return (
              <motion.div
                key={idx}
                className="bg-white rounded-2xl border border-[#F0EAE1] overflow-hidden shadow-sm hover:border-orange-200 transition-colors"
              >
                <button
                  type="button"
                  onClick={() => setOpenIdx(isOpen ? null : idx)}
                  className="w-full p-5 sm:p-6 text-right flex items-center justify-between gap-4 font-bold text-[#1A1D27] text-base sm:text-lg focus:outline-none"
                >
                  <span>{faq.q}</span>
                  <div className={`w-8 h-8 rounded-full bg-orange-50 text-[#FF5722] flex items-center justify-center shrink-0 transition-transform duration-300 ${isOpen ? "rotate-180 bg-[#FF5722] text-white" : ""}`}>
                    <ChevronDown className="w-4 h-4" />
                  </div>
                </button>

                <AnimatePresence>
                  {isOpen && (
                    <motion.div
                      initial={{ height: 0, opacity: 0 }}
                      animate={{ height: "auto", opacity: 1 }}
                      exit={{ height: 0, opacity: 0 }}
                      transition={{ duration: 0.3 }}
                      className="overflow-hidden"
                    >
                      <div className="p-5 sm:p-6 pt-0 border-t border-gray-50 text-sm sm:text-base text-gray-600 font-medium leading-relaxed">
                        {faq.a}
                      </div>
                    </motion.div>
                  )}
                </AnimatePresence>
              </motion.div>
            );
          })}
        </div>

      </div>
    </section>
  );
}
