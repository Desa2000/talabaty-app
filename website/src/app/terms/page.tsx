import React from "react";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { FileText } from "lucide-react";

export const metadata = {
  title: "الشروط والأحكام | طلباتي",
  description: "الشروط والأحكام المنظمة لاستخدام موقع وتطبيق طلباتي في السودان.",
};

export default function TermsPage() {
  return (
    <div className="flex flex-col min-h-screen bg-[#FAF7F2]">
      <Navbar />

      <main className="flex-grow py-12 lg:py-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          
          {/* Header */}
          <div className="text-center mb-12">
            <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-orange-100 text-[#FF5722] text-xs font-bold mb-4">
              <FileText className="w-4 h-4" />
              <span>اتفاقية الاستخدام</span>
            </div>
            <h1 className="text-3xl sm:text-4xl font-extrabold text-[#1A1D27] tracking-tight mb-3">
              الشروط والأحكام
            </h1>
            <p className="text-sm font-medium text-gray-500">
              تاريخ آخر تحديث: يوليو 2026
            </p>
          </div>

          {/* Terms Document Content Card */}
          <div className="bg-white rounded-3xl p-8 sm:p-12 border border-[#F0EAE1] shadow-card space-y-8 text-right font-medium leading-relaxed text-gray-700">
            
            <section className="space-y-3">
              <h2 className="text-xl font-bold text-[#1A1D27] border-r-4 border-[#FF5722] pr-3">
                1. القبول بالشروط
              </h2>
              <p className="text-sm leading-relaxed">
                باستخدامك لمنصة وتطبيق طلباتي، فإنك توافق على الالتزام الكامل بهذه الشروط والأحكام. إذا كنت لا توافق على هذه الشروط، فيرجى عدم استخدام خدماتنا.
              </p>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-bold text-[#1A1D27] border-r-4 border-[#FF5722] pr-3">
                2. طبيعة الخدمة
              </h2>
              <p className="text-sm leading-relaxed">
                منصة طلباتي هي وسيط تقني يربط بين العملاء والمتاجر (المطاعم، السوبرماركت، الصيدليات) والمناديب لتسهيل طلب وتوصيل المنتجات في السودان.
              </p>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-bold text-[#1A1D27] border-r-4 border-[#FF5722] pr-3">
                3. حساب المستخدم والمسؤولية
              </h2>
              <ul className="list-disc list-inside space-y-1.5 text-sm pr-2">
                <li>يتعهد المستخدم بتوفير معلومات صحيحة ودقيقة عند التسجيل.</li>
                <li>يتحمل المستخدم المسؤولية الكاملة عن الحفاظ على سرية حسابه ونشاطاته.</li>
                <li>يحظر استخدام المنصة لأي أغراض غير قانونية أو وهمية.</li>
              </ul>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-bold text-[#1A1D27] border-r-4 border-[#FF5722] pr-3">
                4. الأسعار والدفع والتوصيل
              </h2>
              <p className="text-sm leading-relaxed">
                يتم تحديد أسعار المنتجات ورسوم التوصيل بوضوح قبل تأكيد الطلب. يشمل الدفع خيار الدفع نقداً عند الاستلام أو الدفع الإلكتروني عبر بنكك (Bankak).
              </p>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-bold text-[#1A1D27] border-r-4 border-[#FF5722] pr-3">
                5. إلغاء الطلب والتعديل
              </h2>
              <p className="text-sm leading-relaxed">
                يمكن للعميل إلغاء الطلب فقط قبل بدء المتجر في تحضيره وتجهيزه. بعد بدء التحضير، قد يتم تطبيق رسوم إلغاء بحسب حالة الطلب.
              </p>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-bold text-[#1A1D27] border-r-4 border-[#FF5722] pr-3">
                6. شروط التجار والمناديب
              </h2>
              <p className="text-sm leading-relaxed">
                يلتزم التجار بجودة المنتجات وصحتها، بينما يلتزم المناديب بنقل المنتجات بأمان وسرعة والالتزام بالوسائط المعتمدة (دراجة نارية، كهربائية، هوائية).
              </p>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-bold text-[#1A1D27] border-r-4 border-[#FF5722] pr-3">
                7. القانون والتعديلات
              </h2>
              <p className="text-sm leading-relaxed">
                تخضع هذه الشروط والأحكام لقوانين جمهورية السودان. وتحتفظ طلباتي بحق تعديل هذه الاتفاقية في أي وقت مع تنبيه المستخدمين في المنصة.
              </p>
            </section>

          </div>

        </div>
      </main>

      <Footer />
    </div>
  );
}
