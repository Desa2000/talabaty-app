"use client";

import React, { useState } from "react";
import { useLanguage } from "@/context/LanguageContext";
import { ChevronDown, HelpCircle } from "lucide-react";

export default function FaqSection() {
  const { t } = useLanguage();
  const [openIndex, setOpenIndex] = useState<number | null>(0);

  const faqs = [
    {
      q: "ما هو تطبيق طلباتي؟",
      a: "طلباتي هو المنصة السودانية المتكاملة لتوصيل طلبات المطاعم، السوبرماركت، والصيدليات مباشرة إلى باب بيتك بسرعة وأمان بكوادر سودانية ومندوبين موثوقين.",
    },
    {
      q: "ما أنواع المتاجر الموجودة في طلباتي؟",
      a: "تضم طلباتي ثلاثة أقسام رئيسية: المطاعم (وجبات سودانية وعالمية طازجة)، السوبرماركت (مقاضي ومستلزمات المنزل)، والصيدليات (أدوية ومستلزمات العناية الشخصية).",
    },
    {
      q: "كيف أطلب؟",
      a: "حمل التطبيق، اختر مدينتك، تصفح المتاجر المجاورة لك، أضف المنتجات لسلة التسوق، اختر طريقة الدفع ثم أكد الطلب وسيتولى المندوب التوصيل فورا.",
    },
    {
      q: "كيف أدفع؟",
      a: "نوفر خيارات دفع مرنة وآمنة تشمل الدفع نقداً عند الاستلام (كاش) أو الدفع الإلكتروني المباشر عبر تطبيق بنكك (Bankak).",
    },
    {
      q: "كيف أتابع طلبي؟",
      a: "يمكنك متابعة حالة الطلب وموقع المندوب خطوة بخطوة عبر خريطة التتبع الحي والمباشر داخل تطبيق طلباتي منذ لحظة التجهيز وحتى الوصول.",
    },
    {
      q: "كيف أسجل متجري؟",
      a: "يمكنك زيارة صفحة 'للتجار' على الموقع أو التطبيق وملء استمارة التسجيل، وسيتقوم فريق طلباتي بالتواصل معك لتفعيل حسابك وتوفير لوحة التحكم.",
    },
    {
      q: "كيف أنضم كمندوب؟",
      a: "اضغط على خيار 'انضم كمندوب'، وقم بتعبئة بياناتك ونوع مركبك (دراجة نارية، كهربائية، أو هوائية)، وسيتواصل معك فريق التشغيل لإكمال التوثيق والبدء.",
    },
    {
      q: "هل طلباتي متوفر في كل السودان؟",
      a: "نحن نغطي حالياً المدن والمناطق الرئيسية ونعمل باستمرار على توسيع نطاق التغطية لتشمل كافة المدن والمناطق السودانية قريباً.",
    },
  ];

  const toggleFaq = (index: number) => {
    setOpenIndex(openIndex === index ? null : index);
  };

  return (
    <section id="faq" className="py-20 lg:py-28 bg-[#FAF7F2] relative">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Section Header */}
        <div className="text-center mb-16">
          <span className="inline-flex items-center gap-1.5 px-4 py-1.5 rounded-full bg-orange-100 text-[#FF5722] text-xs font-bold mb-4">
            <HelpCircle className="w-4 h-4" />
            <span>إجابات على تساؤلاتك</span>
          </span>
          <h2 className="text-3xl sm:text-4xl font-extrabold text-[#1A1D27] tracking-tight">
            {t("faq")}
          </h2>
        </div>

        {/* Accordion List */}
        <div className="space-y-4">
          {faqs.map((faq, idx) => {
            const isOpen = openIndex === idx;
            return (
              <div
                key={idx}
                className="bg-white rounded-2xl border border-[#F0EAE1] overflow-hidden shadow-card transition-all"
              >
                <button
                  onClick={() => toggleFaq(idx)}
                  className="w-full px-6 py-5 text-right flex items-center justify-between gap-4 font-bold text-base sm:text-lg text-[#1A1D27] hover:text-[#FF5722] transition-colors"
                >
                  <span>{faq.q}</span>
                  <div className={`w-8 h-8 rounded-xl bg-orange-50 text-[#FF5722] flex items-center justify-center transition-transform duration-300 ${isOpen ? "rotate-180 bg-[#FF5722] text-white" : ""}`}>
                    <ChevronDown className="w-5 h-5" />
                  </div>
                </button>

                {isOpen && (
                  <div className="px-6 pb-6 pt-2 text-sm font-medium text-gray-600 leading-relaxed border-t border-gray-100/80 animate-in fade-in duration-200">
                    {faq.a}
                  </div>
                )}
              </div>
            );
          })}
        </div>

      </div>
    </section>
  );
}
