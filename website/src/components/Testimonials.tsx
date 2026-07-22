"use client";

import React from "react";
import { useLanguage } from "@/context/LanguageContext";
import { FadeUp, StaggerContainer, StaggerChild } from "./motion/Animations";
import { Star, Quote, UtensilsCrossed, ShoppingBag, ShieldCheck } from "lucide-react";
import { motion } from "framer-motion";

export default function Testimonials() {
  const { lang } = useLanguage();
  const isRTL = lang === "ar";

  const reviews = [
    {
      name: isRTL ? "أحمد مصطفى" : "Ahmed Mustafa",
      role: isRTL ? "عميل في الخرطوم" : "Customer in Khartoum",
      comment: isRTL
        ? "التوصيل كان سريع جدًا والوجبة وصلت ساخنة وبحالة ممتازة. تطبيق طلباتي غير مفهوم التوصيل في السودان!"
        : "Delivery was extremely fast and the food arrived hot and fresh. Talabaty changed the delivery experience in Sudan!",
      rating: 5,
      tag: isRTL ? "طلب مطاعم 🍔" : "Food Order 🍔",
      bg: "bg-orange-50/50",
      borderColor: "border-orange-100",
    },
    {
      name: isRTL ? "د. سارة عثمان" : "Dr. Sara Osman",
      role: isRTL ? "عميل في أم درمان" : "Customer in Omdurman",
      comment: isRTL
        ? "أطلب مقاضي البيت والأدوية الصيدلانية بضغطة زر وتوصل في وقت قياسي. خدمة موثوقة ومريحة للغاية."
        : "I order groceries and pharmacy items in one click and they arrive in record time. Highly reliable and convenient.",
      rating: 5,
      tag: isRTL ? "مقاضي وصيدلية 🛒" : "Grocery & Pharmacy 🛒",
      bg: "bg-emerald-50/50",
      borderColor: "border-emerald-100",
    },
    {
      name: isRTL ? "مطعم المدينة السوداني" : "Al Madina Restaurant",
      role: isRTL ? "شريك تجاري في بحري" : "Merchant Partner in Bahri",
      comment: isRTL
        ? "الانضمام لطلباتي زاد من مبيعاتنا بشكل ملحوظ ووفر لنا لوحة تحكم ممتازة لإدارة الطلبات مع المناديب."
        : "Joining Talabaty significantly increased our sales and provided us an excellent dashboard for order tracking.",
      rating: 5,
      tag: isRTL ? "متجر شريك 🏪" : "Merchant Partner 🏪",
      bg: "bg-blue-50/50",
      borderColor: "border-blue-100",
    },
  ];

  return (
    <section className="py-20 bg-white relative overflow-hidden">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <FadeUp>
          <div className="text-center max-w-2xl mx-auto mb-14">
            <span className="text-xs font-bold text-[#FF5722] bg-orange-50 px-3.5 py-1.5 rounded-full border border-orange-100 inline-block mb-3">
              {isRTL ? "آراء عملائنا وشركائنا ⭐" : "Customer & Partner Reviews ⭐"}
            </span>
            <h2 className="text-2xl sm:text-4xl font-extrabold text-[#1A1D27] tracking-tight">
              {isRTL ? "ماذا يقول مستخدمو طلباتي؟" : "What Our Users Say About Talabaty"}
            </h2>
            <p className="text-sm font-medium text-gray-500 mt-3">
              {isRTL
                ? "ثقة وآراء مئات الآلاف من العملاء والتجار والمناديب في مختلف مدن السودان"
                : "Trusted by thousands of customers, merchants, and couriers across Sudan"}
            </p>
          </div>
        </FadeUp>

        <StaggerContainer className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {reviews.map((rev, idx) => (
            <StaggerChild key={idx} className="h-full">
              <motion.div
                whileHover={{ y: -6, boxShadow: "0 20px 40px -15px rgba(255, 87, 34, 0.12)" }}
                className={`h-full bg-white rounded-2xl p-7 border ${rev.borderColor} shadow-sm transition-all duration-300 flex flex-col justify-between relative group`}
              >
                <div>
                  <div className="flex items-center justify-between mb-4">
                    <div className="flex items-center gap-1 text-amber-400">
                      {[...Array(rev.rating)].map((_, i) => (
                        <Star key={i} className="w-4 h-4 fill-amber-400" />
                      ))}
                    </div>
                    <span className="text-xs font-bold text-gray-600 bg-gray-100 px-2.5 py-1 rounded-full">
                      {rev.tag}
                    </span>
                  </div>

                  <Quote className="w-8 h-8 text-orange-200 mb-3 rotate-180" />

                  <p className="text-sm font-medium text-gray-700 leading-relaxed mb-6">
                    "{rev.comment}"
                  </p>
                </div>

                <div className="pt-4 border-t border-gray-100 flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-gradient-to-tr from-[#FF5722] to-amber-500 text-white font-bold flex items-center justify-center text-sm shadow-sm">
                    {rev.name.charAt(0)}
                  </div>
                  <div>
                    <h4 className="text-sm font-bold text-[#1A1D27]">{rev.name}</h4>
                    <p className="text-xs text-gray-400 font-medium">{rev.role}</p>
                  </div>
                </div>
              </motion.div>
            </StaggerChild>
          ))}
        </StaggerContainer>
      </div>
    </section>
  );
}
