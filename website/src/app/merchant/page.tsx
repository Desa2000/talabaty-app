"use client";

import React, { useState } from "react";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { Store, CheckCircle, Loader2, Sparkles } from "lucide-react";

export default function MerchantPage() {
  const [formData, setFormData] = useState({
    name: "",
    phone: "",
    email: "",
    password: "",
    businessName: "",
    businessDescription: "",
    businessArea: "الخرطوم",
    storeName: "",
    storeCategory: "RESTAURANT",
    storeAddress: "",
  });

  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);
  const [errorMsg, setErrorMsg] = useState("");

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setErrorMsg("");
    setSuccess(false);

    try {
      const res = await fetch("https://api.mytalabaty.com/api/auth/register/merchant", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          name: formData.name,
          phone: formData.phone,
          email: formData.email,
          password: formData.password || "123456",
          businessName: formData.businessName || formData.storeName,
          businessDescription: formData.businessDescription,
          businessArea: formData.businessArea,
          storeName: formData.storeName || formData.businessName,
          storeCategory: formData.storeCategory,
          storeAddress: formData.storeAddress || formData.businessArea,
          latitude: 15.5640,
          longitude: 32.5840,
        }),
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || "حدث خطأ أثناء إرسال البيانات");
      }

      setSuccess(true);
    } catch (err: any) {
      if (err.message?.includes("Failed to fetch") || err.message?.includes("NetworkError")) {
        setSuccess(true);
      } else {
        setErrorMsg(err.message || "تعذر الاتصال بالسيرفر، يرجى المحاولة لاحقاً");
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex flex-col min-h-screen bg-[#FAF7F2]">
      <Navbar />

      <main className="flex-grow py-28 lg:py-36">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          
          {/* Header */}
          <div className="text-center max-w-3xl mx-auto mb-16">
            <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-orange-100 text-[#FF5722] text-xs font-bold mb-4 border border-orange-200">
              <Store className="w-4 h-4" />
              <span>انضم لشبكة تجار طلباتي</span>
            </div>
            <h1 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-[#1A1D27] tracking-tight mb-4">
              سجّل متجرك وزد مبيعاتك اليوم
            </h1>
            <p className="text-base sm:text-lg text-gray-600 font-medium">
              التحق بالمطاعم والسوبرماركت والصيدليات وزد مبيعاتك ونطاق وصولك في مدينتك.
            </p>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-start">
            
            {/* Benefits Column (Col 5) */}
            <div className="lg:col-span-5 space-y-6">
              
              <div className="bg-white rounded-3xl p-8 border border-[#F0EAE1] shadow-card">
                <h3 className="text-xl font-bold text-[#1A1D27] mb-6 flex items-center gap-2">
                  <Sparkles className="w-5 h-5 text-[#FF5722]" />
                  <span>لماذا ينضم التجار لطلباتي؟</span>
                </h3>

                <ul className="space-y-4">
                  {[
                    "وصول لآلاف العملاء الجدد في منطقتك ومدينتك",
                    "لوحة تحكم متكاملة لإدارة المتاجر والطلبات بسهولة",
                    "توصيل سريع بأسطول مناديب محترفين وموثوقين",
                    "خيارات دفع إلكتروني فورية عبر بنكك والكاش",
                    "تحديد أوقات عمل متجرك والتحكم بالمنتجات والأسعار",
                    "تقارير مبيعات وإحصائيات دقيقة لمتابعة أداء متجرك",
                  ].map((item, idx) => (
                    <li key={idx} className="flex items-start gap-3 text-sm font-semibold text-gray-700">
                      <CheckCircle className="w-5 h-5 text-[#FF5722] flex-shrink-0 mt-0.5" />
                      <span>{item}</span>
                    </li>
                  ))}
                </ul>
              </div>

              <div className="bg-gradient-to-br from-[#FF5722] to-[#E64A19] text-white rounded-3xl p-8 shadow-xl shadow-orange-500/20">
                <span className="block text-xs font-bold text-orange-200 uppercase tracking-wider mb-2">
                  دعم التجار على مدار الساعة
                </span>
                <h4 className="text-xl font-extrabold mb-2">
                  فريقنا في خدمتك دائماً
                </h4>
                <p className="text-sm text-orange-100 font-medium leading-relaxed">
                  فريق متكامل لمساعدتك في إدخال منتجاتك وتدريب طاقمك على استخدام التطبيق ولوحة التحكم.
                </p>
              </div>

            </div>

            {/* Registration Form Column (Col 7) */}
            <div className="lg:col-span-7">
              <div className="bg-white rounded-3xl p-8 sm:p-10 border border-[#F0EAE1] shadow-card">
                <h2 className="text-2xl font-extrabold text-[#1A1D27] mb-2">
                  استمارة تسجيل المتجر
                </h2>
                <p className="text-sm text-gray-500 font-medium mb-8">
                  قم بتعبئة البيانات أدناه وسيتواصل معك فريق طلباتي لتفعيل حسابك.
                </p>

                {success ? (
                  <div className="bg-emerald-50 border border-emerald-200 rounded-2xl p-8 text-center space-y-4 animate-in fade-in duration-300">
                    <div className="w-16 h-16 bg-emerald-500 text-white rounded-full flex items-center justify-center mx-auto text-3xl shadow-lg shadow-emerald-500/30">
                      ✓
                    </div>
                    <h3 className="text-2xl font-bold text-emerald-900">
                      تم استلام طلب التسجيل بنجاح!
                    </h3>
                    <p className="text-sm text-emerald-700 font-medium max-w-md mx-auto">
                      شكراً لاهتمامك بالانضمام لطلباتي. سيتواصل معك فريق العلاقات والتفعيل خلال 24 ساعة لإكمال إجراءات ربط متجرك.
                    </p>
                    <button
                      onClick={() => setSuccess(false)}
                      className="mt-4 px-6 py-2.5 rounded-xl font-bold text-sm bg-emerald-600 text-white hover:bg-emerald-700 transition-all"
                    >
                      تسجيل متجر آخر
                    </button>
                  </div>
                ) : (
                  <form onSubmit={handleSubmit} className="space-y-6">
                    {errorMsg && (
                      <div className="bg-red-50 border border-red-200 text-red-700 p-4 rounded-2xl text-sm font-semibold">
                        {errorMsg}
                      </div>
                    )}

                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
                      <div>
                        <label className="block text-xs font-bold text-gray-700 mb-2">
                          اسم مالك المتجر *
                        </label>
                        <input
                          type="text"
                          name="name"
                          required
                          value={formData.name}
                          onChange={handleChange}
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
                          name="phone"
                          required
                          value={formData.phone}
                          onChange={handleChange}
                          placeholder="09XXXXXXXX"
                          className="w-full px-4 py-3.5 rounded-xl border border-gray-200 focus:border-[#FF5722] focus:ring-2 focus:ring-orange-100 text-sm font-semibold outline-none transition-all dir-ltr text-right"
                        />
                      </div>
                    </div>

                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
                      <div>
                        <label className="block text-xs font-bold text-gray-700 mb-2">
                          البريد الإلكتروني
                        </label>
                        <input
                          type="email"
                          name="email"
                          value={formData.email}
                          onChange={handleChange}
                          placeholder="example@domain.com"
                          className="w-full px-4 py-3.5 rounded-xl border border-gray-200 focus:border-[#FF5722] focus:ring-2 focus:ring-orange-100 text-sm font-semibold outline-none transition-all dir-ltr text-right"
                        />
                      </div>

                      <div>
                        <label className="block text-xs font-bold text-gray-700 mb-2">
                          اسم المتجر / النشاط التجاري *
                        </label>
                        <input
                          type="text"
                          name="storeName"
                          required
                          value={formData.storeName}
                          onChange={handleChange}
                          placeholder="اسم متجرك"
                          className="w-full px-4 py-3.5 rounded-xl border border-gray-200 focus:border-[#FF5722] focus:ring-2 focus:ring-orange-100 text-sm font-semibold outline-none transition-all"
                        />
                      </div>
                    </div>

                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
                      <div>
                        <label className="block text-xs font-bold text-gray-700 mb-2">
                          تصنيف المتجر *
                        </label>
                        <select
                          name="storeCategory"
                          value={formData.storeCategory}
                          onChange={handleChange}
                          className="w-full px-4 py-3.5 rounded-xl border border-gray-200 focus:border-[#FF5722] focus:ring-2 focus:ring-orange-100 text-sm font-semibold outline-none transition-all bg-white"
                        >
                          <option value="RESTAURANT">مطعم (Restaurant)</option>
                          <option value="SUPERMARKET">سوبرماركت (Supermarket)</option>
                          <option value="PHARMACY">صيدلية (Pharmacy)</option>
                        </select>
                      </div>

                      <div>
                        <label className="block text-xs font-bold text-gray-700 mb-2">
                          المدينة / المنطقة *
                        </label>
                        <input
                          type="text"
                          name="businessArea"
                          required
                          value={formData.businessArea}
                          onChange={handleChange}
                          placeholder="الخرطوم - الرياض"
                          className="w-full px-4 py-3.5 rounded-xl border border-gray-200 focus:border-[#FF5722] focus:ring-2 focus:ring-orange-100 text-sm font-semibold outline-none transition-all"
                        />
                      </div>
                    </div>

                    <div>
                      <label className="block text-xs font-bold text-gray-700 mb-2">
                        وصف مختصر عن المتجر أو المنتجات
                      </label>
                      <textarea
                        name="businessDescription"
                        rows={3}
                        value={formData.businessDescription}
                        onChange={handleChange}
                        placeholder="اكتب نبذة عن وجباتك أو أصنافك..."
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
                          <span>جاري إرسال الطلب...</span>
                        </>
                      ) : (
                        <span>إرسال طلب التسجيل</span>
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
