"use client";

import React, { useState } from "react";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { Mail, Phone, MapPin, Send, Loader2, CheckCircle2, MessageSquare } from "lucide-react";

export default function ContactPage() {
  const [form, setForm] = useState({
    name: "",
    phone: "",
    email: "",
    subject: "",
    message: "",
  });

  const [loading, setLoading] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setTimeout(() => {
      setLoading(false);
      setSubmitted(true);
    }, 1000);
  };

  return (
    <div className="flex flex-col min-h-screen bg-[#FAF7F2]">
      <Navbar />

      <main className="flex-grow py-28 lg:py-36">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          
          {/* Header */}
          <div className="text-center max-w-3xl mx-auto mb-16">
            <span className="inline-flex items-center gap-1.5 px-4 py-1.5 rounded-full bg-orange-100 text-[#FF5722] text-xs font-bold mb-4 border border-orange-200">
              <MessageSquare className="w-4 h-4" />
              <span>فريق الدعم في خدمتك</span>
            </span>
            <h1 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-[#1A1D27] tracking-tight mb-4">
              نحن معاك
            </h1>
            <p className="text-base sm:text-lg text-gray-600 font-medium">
              عندك سؤال، اقتراح أو مشكلة؟ اتواصل معانا.
            </p>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-start">
            
            {/* Contact Info Column (Col 5) */}
            <div className="lg:col-span-5 space-y-6">
              
              <div className="bg-white rounded-3xl p-8 border border-[#F0EAE1] shadow-card space-y-6">
                <h3 className="text-xl font-bold text-[#1A1D27] mb-6">
                  معلومات التواصل
                </h3>

                <div className="flex items-start gap-4">
                  <div className="w-12 h-12 rounded-2xl bg-orange-50 text-[#FF5722] flex items-center justify-center flex-shrink-0">
                    <MapPin className="w-6 h-6" />
                  </div>
                  <div>
                    <span className="block text-xs font-bold text-gray-400">العنوان</span>
                    <span className="text-base font-bold text-[#1A1D27]">الخرطوم - الرياض، السودان</span>
                  </div>
                </div>

                <div className="flex items-start gap-4">
                  <div className="w-12 h-12 rounded-2xl bg-emerald-50 text-emerald-600 flex items-center justify-center flex-shrink-0">
                    <Phone className="w-6 h-6" />
                  </div>
                  <div>
                    <span className="block text-xs font-bold text-gray-400">الهاتف للدعم والتواصل</span>
                    <a
                      href="tel:+249911421515"
                      className="text-base font-bold text-[#1A1D27] hover:text-[#FF5722] transition-colors inline-block"
                      dir="ltr"
                    >
                      +249911421515
                    </a>
                  </div>
                </div>

                <div className="flex items-start gap-4">
                  <div className="w-12 h-12 rounded-2xl bg-blue-50 text-blue-600 flex items-center justify-center flex-shrink-0">
                    <Mail className="w-6 h-6" />
                  </div>
                  <div>
                    <span className="block text-xs font-bold text-gray-400">البريد الإلكتروني الرسمي</span>
                    <a
                      href="mailto:support@mytalabaty.com"
                      className="text-base font-bold text-[#1A1D27] hover:text-[#FF5722] transition-colors inline-block"
                      dir="ltr"
                    >
                      support@mytalabaty.com
                    </a>
                  </div>
                </div>
              </div>

              <div className="bg-[#1A1D27] text-white rounded-3xl p-8 shadow-xl">
                <h4 className="text-lg font-bold mb-2">ساعات عمل الدعم الفني</h4>
                <p className="text-xs text-gray-300 font-medium leading-relaxed">
                  يتواجد فريق خدمة العملاء والدعم الفني للتجار والمناديب طوال أيام الأسبوع لضمان سير طلباتكم بسلاسة وسرعة.
                </p>
              </div>

            </div>

            {/* Message Form Column (Col 7) */}
            <div className="lg:col-span-7">
              <div className="bg-white rounded-3xl p-8 sm:p-10 border border-[#F0EAE1] shadow-card">
                <h2 className="text-2xl font-extrabold text-[#1A1D27] mb-2">
                  أرسل لنا رسالة
                </h2>
                <p className="text-sm text-gray-500 font-medium mb-8">
                  يسعدنا الاستماع لملاحظاتك واستفساراتك، يسعدنا تواصلك معنا!
                </p>

                {submitted ? (
                  <div className="bg-emerald-50 border border-emerald-200 rounded-2xl p-8 text-center space-y-4 animate-in fade-in duration-300">
                    <CheckCircle2 className="w-16 h-16 text-emerald-500 mx-auto" />
                    <h3 className="text-2xl font-bold text-emerald-900">
                      تم إرسال رسالتك بنجاح!
                    </h3>
                    <p className="text-sm text-emerald-700 font-medium max-w-md mx-auto">
                      شكراً لتواصلك مع طلباتي. سيرد عليك أحد ممثلي الدعم الفني في أقرب وقت.
                    </p>
                    <button
                      onClick={() => setSubmitted(false)}
                      className="mt-4 px-6 py-2.5 rounded-xl font-bold text-sm bg-emerald-600 text-white hover:bg-emerald-700 transition-all"
                    >
                      إرسال رسالة أخرى
                    </button>
                  </div>
                ) : (
                  <form onSubmit={handleSubmit} className="space-y-6">
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
                      <div>
                        <label className="block text-xs font-bold text-gray-700 mb-2">
                          الاسم الكامل *
                        </label>
                        <input
                          type="text"
                          required
                          value={form.name}
                          onChange={(e) => setForm({ ...form, name: e.target.value })}
                          placeholder="أدخل اسمك"
                          className="w-full px-4 py-3.5 rounded-xl border border-gray-200 focus:border-[#FF5722] focus:ring-2 focus:ring-orange-100 text-sm font-semibold outline-none transition-all"
                        />
                      </div>

                      <div>
                        <label className="block text-xs font-bold text-gray-700 mb-2">
                          رقم الهاتف *
                        </label>
                        <input
                          type="tel"
                          required
                          value={form.phone}
                          onChange={(e) => setForm({ ...form, phone: e.target.value })}
                          placeholder="09XXXXXXXX"
                          className="w-full px-4 py-3.5 rounded-xl border border-gray-200 focus:border-[#FF5722] focus:ring-2 focus:ring-orange-100 text-sm font-semibold outline-none transition-all dir-ltr text-right"
                        />
                      </div>
                    </div>

                    <div>
                      <label className="block text-xs font-bold text-gray-700 mb-2">
                        البريد الإلكتروني
                      </label>
                      <input
                        type="email"
                        value={form.email}
                        onChange={(e) => setForm({ ...form, email: e.target.value })}
                        placeholder="example@domain.com"
                        className="w-full px-4 py-3.5 rounded-xl border border-gray-200 focus:border-[#FF5722] focus:ring-2 focus:ring-orange-100 text-sm font-semibold outline-none transition-all dir-ltr text-right"
                      />
                    </div>

                    <div>
                      <label className="block text-xs font-bold text-gray-700 mb-2">
                        نوع الاستفسار *
                      </label>
                      <input
                        type="text"
                        required
                        value={form.subject}
                        onChange={(e) => setForm({ ...form, subject: e.target.value })}
                        placeholder="موضوع الرسالة أو الاستفسار"
                        className="w-full px-4 py-3.5 rounded-xl border border-gray-200 focus:border-[#FF5722] focus:ring-2 focus:ring-orange-100 text-sm font-semibold outline-none transition-all"
                      />
                    </div>

                    <div>
                      <label className="block text-xs font-bold text-gray-700 mb-2">
                        الرسالة *
                      </label>
                      <textarea
                        required
                        rows={5}
                        value={form.message}
                        onChange={(e) => setForm({ ...form, message: e.target.value })}
                        placeholder="اكتب تفاصيل استفسارك هنا..."
                        className="w-full px-4 py-3.5 rounded-xl border border-gray-200 focus:border-[#FF5722] focus:ring-2 focus:ring-orange-100 text-sm font-semibold outline-none transition-all"
                      />
                    </div>

                    <button
                      type="submit"
                      disabled={loading}
                      className="w-full py-4 rounded-2xl font-bold text-base text-white bg-[#FF5722] hover:bg-[#E64A19] shadow-lg shadow-orange-500/25 transition-all flex items-center justify-center gap-2 disabled:opacity-75"
                    >
                      {loading ? (
                        <>
                          <Loader2 className="w-5 h-5 animate-spin" />
                          <span>جاري الإرسال...</span>
                        </>
                      ) : (
                        <>
                          <Send className="w-5 h-5" />
                          <span>إرسال الرسالة</span>
                        </>
                      )}
                    </button>
                  </form>
                )}

              </div>
            </div>

          </div>

        </div>
      </main>

      <Footer />
    </div>
  );
}
