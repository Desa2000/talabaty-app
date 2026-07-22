import React from "react";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { ShieldCheck } from "lucide-react";

export const metadata = {
  title: "سياسة الخصوصية | طلباتي",
  description: "سياسة الخصوصية وحماية بيانات المستخدمين في تطبيق وموقع طلباتي السودان.",
};

export default function PrivacyPage() {
  return (
    <div className="flex flex-col min-h-screen bg-[#FAF7F2]">
      <Navbar />

      <main className="flex-grow py-12 lg:py-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          
          {/* Header */}
          <div className="text-center mb-12">
            <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-orange-100 text-[#FF5722] text-xs font-bold mb-4">
              <ShieldCheck className="w-4 h-4" />
              <span>حماية وتأمين بياناتك</span>
            </div>
            <h1 className="text-3xl sm:text-4xl font-extrabold text-[#1A1D27] tracking-tight mb-3">
              سياسة الخصوصية
            </h1>
            <p className="text-sm font-medium text-gray-500">
              تاريخ آخر تحديث: يوليو 2026
            </p>
          </div>

          {/* Policy Document Content Card */}
          <div className="bg-white rounded-3xl p-8 sm:p-12 border border-[#F0EAE1] shadow-card space-y-8 text-right font-medium leading-relaxed text-gray-700">
            
            <section className="space-y-3">
              <h2 className="text-xl font-bold text-[#1A1D27] border-r-4 border-[#FF5722] pr-3">
                1. مقدمة
              </h2>
              <p className="text-sm leading-relaxed">
                نرحب بكم في منصة وتطبيق طلباتي (&quot;نحن&quot;، &quot;التطبيق&quot;). نحن نولي أهمية قصوى لخصوصيتك وحماية بياناتك الشخصية. توضح سياسة الخصوصية هذه كيفية جمع واستخدام وتأمين معلوماتك عند استخدام موقعنا الإلكتروني أو تطبيق الهاتف الخاص بنا في السودان.
              </p>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-bold text-[#1A1D27] border-r-4 border-[#FF5722] pr-3">
                2. البيانات التي نجمعها
              </h2>
              <p className="text-sm leading-relaxed">
                قد نجمع البيانات التالية لتقديم أفضل خدمة توصيل ممكنة:
              </p>
              <ul className="list-disc list-inside space-y-1.5 text-sm pr-2">
                <li>معلومات الحساب: الاسم الكامل، رقم الهاتف، البريد الإلكتروني.</li>
                <li>بيانات الموقع الجغرافي: تحديد موقعك بدقة لتوجيه المندوب وتسهيل تسليم الطلب.</li>
                <li>بيانات الطلب: تفاصيل المتاجر والمنتجات وطريقة الدفع المختارة.</li>
                <li>بيانات الجهاز: نوع الجهاز، نظام التشغيل ومعرفات الخدمة للإشعارات.</li>
              </ul>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-bold text-[#1A1D27] border-r-4 border-[#FF5722] pr-3">
                3. كيفية استخدام البيانات
              </h2>
              <p className="text-sm leading-relaxed">
                نستخدم معلوماتك للأغراض التالية فقط:
              </p>
              <ul className="list-disc list-inside space-y-1.5 text-sm pr-2">
                <li>معالجة وتنفيذ طلبات التوصيل وتحديث حالتها خطوة بخطوة.</li>
                <li>تمكين المندوب والمتجر من التواصل مع العميل لأغراض الطلب حصراً.</li>
                <li>إرسال التنبيهات والإشعارات المهمة المتعلقة بطلبك.</li>
                <li>تحسين جودة الخدمة وأمان المنصة وتجربة المستخدم.</li>
              </ul>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-bold text-[#1A1D27] border-r-4 border-[#FF5722] pr-3">
                4. مشاركة البيانات مع أطراف ثالثة
              </h2>
              <p className="text-sm leading-relaxed">
                نحن لا نبيع أو نؤجر بياناتك الشخصية لأي طرف ثالث. نقوم بمشاركة البيانات الضرورية فقط مع:
              </p>
              <ul className="list-disc list-inside space-y-1.5 text-sm pr-2">
                <li>المتاجر والمناديب المعنيين بالطلب لتنفيذ عملية الاستلام والتسليم.</li>
                <li>الجهات القضائية أو القانونية المعتمدة في السودان إذا لزم الأمر بموجب أحكام القانون.</li>
              </ul>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-bold text-[#1A1D27] border-r-4 border-[#FF5722] pr-3">
                5. أمان وحماية البيانات
              </h2>
              <p className="text-sm leading-relaxed">
                نطبق معايير أمنية وتقنية عالية التشفير لحماية بياناتك من الوصول غير المصرح به أو التعديل أو الإفصاح غير القانوني.
              </p>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-bold text-[#1A1D27] border-r-4 border-[#FF5722] pr-3">
                6. حقوق المستخدم والتواصل
              </h2>
              <p className="text-sm leading-relaxed">
                يحق لك دائماً تحديث بياناتك الشخصية أو طلب حذف حسابك وتعديل معلوماتك في أي وقت عن طريق التواصل معنا عبر البريد الإلكتروني الرسمي: <span className="font-bold text-[#FF5722] dir-ltr inline-block">privacy@mytalabaty.com</span>.
              </p>
            </section>

          </div>

        </div>
      </main>

      <Footer />
    </div>
  );
}
