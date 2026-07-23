'use client';

import React, { useState } from 'react';
import Image from 'next/image';
import { useRouter } from 'next/navigation';
import { adminFetch, setAdminToken } from '@/lib/admin-api';
import { Shield, Lock, Mail, ArrowRight } from 'lucide-react';

export default function AdminLoginPage() {
  const router = useRouter();
  const [identifier, setIdentifier] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!identifier || !password) {
      setError('يرجى إدخال البريد الإلكتروني وكلمة المرور');
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const data = await adminFetch('/auth/login', {
        method: 'POST',
        body: JSON.stringify({ identifier, password }),
      });

      const userRole = data.user?.role;
      const adminRoles = ['SUPER_ADMIN', 'ADMIN', 'OPERATIONS', 'FINANCE', 'SUPPORT'];

      if (!adminRoles.includes(userRole)) {
        setError('403 Forbidden: هذا الحساب ليس لديه صلاحية الوصول للوحة الإدارة');
        setLoading(false);
        return;
      }

      setAdminToken(data.accessToken);
      if (typeof window !== 'undefined') {
        localStorage.setItem('talabaty_admin_user', JSON.stringify(data.user));
      }

      router.push('/admin');
    } catch (err: any) {
      setError(err.message || 'فشل تسجيل الدخول، يرجى التأكد من البيانات');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#14171A] flex flex-col justify-center items-center p-4 dir-rtl" dir="rtl">
      {/* Background Decor */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute -top-40 -right-40 w-96 h-96 bg-[#FF5722]/10 rounded-full blur-3xl" />
        <div className="absolute -bottom-40 -left-40 w-96 h-96 bg-amber-500/10 rounded-full blur-3xl" />
      </div>

      <div className="w-full max-w-md bg-[#1D2126] border border-gray-800 rounded-3xl p-8 shadow-2xl relative z-10">
        {/* Header Logo & Title */}
        <div className="flex flex-col items-center text-center mb-8">
          <div className="w-16 h-16 bg-[#FF5722]/10 border border-[#FF5722]/20 rounded-2xl flex items-center justify-center mb-4">
            <Image src="/logo.png" alt="Talabaty Logo" width={40} height={40} className="object-contain" />
          </div>
          <h1 className="text-2xl font-bold text-white tracking-tight flex items-center gap-2">
            لوحة إدارة طلباتي <Shield className="w-5 h-5 text-[#FF5722]" />
          </h1>
          <p className="text-gray-400 text-sm mt-1">تسجيل الدخول الآمن للمسؤولين ومشغلي النظام</p>
        </div>

        {error && (
          <div className="mb-6 p-4 rounded-xl bg-red-500/10 border border-red-500/30 text-red-400 text-sm font-medium text-center">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-5">
          <div>
            <label className="block text-xs font-semibold text-gray-300 mb-2">البريد الإلكتروني / اسم المستخدم</label>
            <div className="relative">
              <input
                type="text"
                value={identifier}
                onChange={(e) => setIdentifier(e.target.value)}
                placeholder="admin@talabaty.com"
                required
                className="w-full bg-[#14171A] border border-gray-700/80 rounded-xl px-4 py-3 pr-11 text-white placeholder-gray-500 text-sm focus:outline-none focus:border-[#FF5722] transition-colors"
              />
              <Mail className="w-5 h-5 text-gray-500 absolute right-3.5 top-3.5" />
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold text-gray-300 mb-2">كلمة المرور</label>
            <div className="relative">
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
                required
                className="w-full bg-[#14171A] border border-gray-700/80 rounded-xl px-4 py-3 pr-11 text-white placeholder-gray-500 text-sm focus:outline-none focus:border-[#FF5722] transition-colors"
              />
              <Lock className="w-5 h-5 text-gray-500 absolute right-3.5 top-3.5" />
            </div>
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-gradient-to-r from-[#FF5722] to-orange-600 hover:from-orange-600 hover:to-orange-700 text-white font-bold py-3.5 px-4 rounded-xl shadow-lg shadow-orange-950/30 flex items-center justify-center gap-2 transition-all duration-200 disabled:opacity-50 mt-2 cursor-pointer"
          >
            {loading ? (
              <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
            ) : (
              <>
                <span>دخول لوحة التحكم</span>
                <ArrowRight className="w-5 h-5 rotate-180" />
              </>
            )}
          </button>
        </form>

        <div className="mt-8 text-center text-xs text-gray-500">
          نظام محمي برمز مشفر وروابط تشغيلية آمنة &bull; Talabaty Production v2.0
        </div>
      </div>
    </div>
  );
}
