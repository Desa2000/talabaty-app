'use client';

import React, { useEffect, useState, Suspense } from 'react';
import { useSearchParams, useRouter } from 'next/navigation';
import { ShieldCheck, Eye, EyeOff, Lock, Check, X, AlertCircle, ArrowRight } from 'lucide-react';
import Link from 'next/link';

function AdminSetupContent() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const token = searchParams.get('token');

  const [loading, setLoading] = useState(true);
  const [tokenValid, setTokenValid] = useState<boolean | null>(null);
  const [errorMessage, setErrorMessage] = useState('');
  const [email, setEmail] = useState('superadmin@talabaty.com');

  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState('');

  const API_URL = process.env.NEXT_PUBLIC_API_URL || 'https://api.mytalabaty.com/api';

  useEffect(() => {
    if (!token) {
      setTokenValid(false);
      setErrorMessage('رابط التفعيل غير صالح أو ناقص. يرجى استخدام الرابط المولّد من الـ Terminal');
      setLoading(false);
      return;
    }

    // Verify token validity
    fetch(`${API_URL}/admin/setup-verify?token=${encodeURIComponent(token)}`)
      .then((res) => res.json())
      .then((data) => {
        if (data.valid) {
          setTokenValid(true);
          if (data.email) setEmail(data.email);
        } else {
          setTokenValid(false);
          setErrorMessage(data.error || 'رابط التفعيل غير صالح أو تم استخدامه سابقاً');
        }
      })
      .catch(() => {
        setTokenValid(false);
        setErrorMessage('تعذر الاتصال بالسيرفر للتحقق من رابط التفعيل');
      })
      .finally(() => setLoading(false));
  }, [token, API_URL]);

  // Password Requirement Checks
  const hasMinLen = password.length >= 12;
  const hasUpper = /[A-Z]/.test(password);
  const hasLower = /[a-z]/.test(password);
  const hasNumber = /[0-9]/.test(password);
  const hasSpecial = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password);
  const passwordsMatch = password.length > 0 && password === confirmPassword;

  const isFormValid = hasMinLen && hasUpper && hasLower && hasNumber && hasSpecial && passwordsMatch;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!isFormValid || !token) return;

    setSubmitting(true);
    setSubmitError('');

    try {
      const res = await fetch(`${API_URL}/admin/setup-password`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ token, newPassword: password }),
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || 'فشل إنشاء كلمة المرور');
      }

      // Save tokens
      localStorage.setItem('talabaty_admin_token', data.token);
      localStorage.setItem('talabaty_admin_user', JSON.stringify(data.user));

      // Immediate redirect to Dashboard
      router.push('/admin');
    } catch (err: any) {
      setSubmitError(err.message || 'حدث خطأ أثناء حفظ كلمة المرور');
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-[#0F1114] flex items-center justify-center p-4 dir-rtl" dir="rtl">
        <div className="flex flex-col items-center gap-3">
          <div className="w-10 h-10 border-4 border-[#FF5722] border-t-transparent rounded-full animate-spin" />
          <p className="text-gray-400 text-sm font-semibold">جاري التحقق من رابط التفعيل الأمني...</p>
        </div>
      </div>
    );
  }

  if (!tokenValid) {
    return (
      <div className="min-h-screen bg-[#0F1114] flex items-center justify-center p-4 dir-rtl" dir="rtl">
        <div className="max-w-md w-full bg-[#16191D] border border-red-500/30 rounded-3xl p-8 text-center shadow-2xl space-y-6">
          <div className="w-16 h-16 bg-red-500/10 border border-red-500/30 rounded-2xl flex items-center justify-center mx-auto text-red-500">
            <AlertCircle className="w-8 h-8" />
          </div>
          <div>
            <h1 className="text-xl font-bold text-white">رابط التفعيل غير صالح</h1>
            <p className="text-sm text-gray-400 mt-2">{errorMessage}</p>
          </div>
          <Link
            href="/admin/login"
            className="inline-flex items-center justify-center gap-2 w-full bg-[#FF5722] hover:bg-[#E64A19] text-white font-bold py-3.5 px-6 rounded-2xl transition shadow-lg shadow-[#FF5722]/20"
          >
            <span>الذهاب إلى تسجيل الدخول</span>
            <ArrowRight className="w-4 h-4 rotate-180" />
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#0F1114] flex items-center justify-center p-4 dir-rtl" dir="rtl">
      <div className="max-w-lg w-full bg-[#16191D] border border-gray-800 rounded-3xl p-8 shadow-2xl space-y-6">
        {/* Header */}
        <div className="text-center space-y-2">
          <div className="w-16 h-16 bg-[#FF5722]/15 border border-[#FF5722]/30 rounded-2xl flex items-center justify-center mx-auto text-[#FF5722]">
            <ShieldCheck className="w-8 h-8" />
          </div>
          <h1 className="text-2xl font-bold text-white">إعداد حساب المدير العام</h1>
          <p className="text-xs text-gray-400 max-w-sm mx-auto">
            أنشئ كلمة مرور آمنة لحساب الإدارة. هذه الخطوة مطلوبة مرة واحدة فقط.
          </p>
        </div>

        {submitError && (
          <div className="bg-red-500/10 border border-red-500/30 text-red-400 text-xs font-semibold p-3.5 rounded-2xl flex items-center gap-2">
            <AlertCircle className="w-4 h-4 shrink-0" />
            <span>{submitError}</span>
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-5">
          {/* Email */}
          <div>
            <label className="block text-xs font-bold text-gray-300 mb-1.5">البريد الإلكتروني</label>
            <input
              type="text"
              value={email}
              disabled
              className="w-full bg-[#0F1114] border border-gray-800 text-gray-400 text-sm font-semibold rounded-2xl px-4 py-3 cursor-not-allowed opacity-80"
            />
          </div>

          {/* New Password */}
          <div>
            <label className="block text-xs font-bold text-gray-300 mb-1.5">كلمة المرور الجديدة</label>
            <div className="relative">
              <input
                type={showPassword ? 'text' : 'password'}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="أدخل كلمة مرور قوية"
                className="w-full bg-[#0F1114] border border-gray-800 focus:border-[#FF5722] text-white text-sm rounded-2xl px-4 py-3 pl-11 outline-none transition"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400 hover:text-white"
              >
                {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
              </button>
            </div>
          </div>

          {/* Confirm Password */}
          <div>
            <label className="block text-xs font-bold text-gray-300 mb-1.5">تأكيد كلمة المرور</label>
            <input
              type={showPassword ? 'text' : 'password'}
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              placeholder="أعد كتابة كلمة المرور"
              className="w-full bg-[#0F1114] border border-gray-800 focus:border-[#FF5722] text-white text-sm rounded-2xl px-4 py-3 outline-none transition"
            />
          </div>

          {/* Requirements Checklist */}
          <div className="bg-[#0F1114] border border-gray-800/80 rounded-2xl p-4 space-y-2">
            <span className="text-[11px] font-bold text-gray-400 block mb-1">شروط كلمة المرور:</span>
            <div className="grid grid-cols-2 gap-2 text-[11px]">
              <ReqItem met={hasMinLen} label="12 حرفاً على الأقل" />
              <ReqItem met={hasUpper} label="حرف كبير (A-Z)" />
              <ReqItem met={hasLower} label="حرف صغير (a-z)" />
              <ReqItem met={hasNumber} label="رقم (0-9)" />
              <ReqItem met={hasSpecial} label="رمز خاص (!@#$%)" />
              <ReqItem met={passwordsMatch} label="تطابق كلمة المرور" />
            </div>
          </div>

          {/* Submit Button */}
          <button
            type="submit"
            disabled={!isFormValid || submitting}
            className={`w-full font-bold text-sm py-4 px-6 rounded-2xl transition flex items-center justify-center gap-2 shadow-lg ${
              isFormValid && !submitting
                ? 'bg-[#FF5722] hover:bg-[#E64A19] text-white shadow-[#FF5722]/25 cursor-pointer'
                : 'bg-gray-800 text-gray-500 cursor-not-allowed'
            }`}
          >
            {submitting ? (
              <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
            ) : (
              <>
                <Lock className="w-4 h-4" />
                <span>إنشاء كلمة المرور ودخول لوحة التحكم</span>
              </>
            )}
          </button>
        </form>
      </div>
    </div>
  );
}

function ReqItem({ met, label }: { met: boolean; label: string }) {
  return (
    <div className={`flex items-center gap-1.5 font-medium ${met ? 'text-emerald-400' : 'text-gray-500'}`}>
      {met ? <Check className="w-3.5 h-3.5 text-emerald-400 shrink-0" /> : <X className="w-3.5 h-3.5 text-gray-600 shrink-0" />}
      <span>{label}</span>
    </div>
  );
}

export default function AdminSetupPage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen bg-[#0F1114] flex items-center justify-center p-4">
        <div className="w-10 h-10 border-4 border-[#FF5722] border-t-transparent rounded-full animate-spin" />
      </div>
    }>
      <AdminSetupContent />
    </Suspense>
  );
}
