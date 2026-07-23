'use client';

import React, { useEffect, useState } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { usePathname, useRouter } from 'next/navigation';
import { getAdminToken, getAdminUser, clearAdminToken } from '@/lib/admin-api';
import {
  LayoutDashboard,
  ShoppingBag,
  Store,
  Bike,
  Users,
  CreditCard,
  MapPin,
  HelpCircle,
  History,
  Settings,
  LogOut,
  ShieldCheck,
  Search,
  Bell,
  Activity,
} from 'lucide-react';

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const [adminUser, setAdminUser] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  const isLoginPage = pathname === '/admin/login';

  useEffect(() => {
    if (isLoginPage) {
      setLoading(false);
      return;
    }

    const token = getAdminToken();
    const user = getAdminUser();

    if (!token || !user) {
      router.push('/admin/login');
      return;
    }

    const adminRoles = ['SUPER_ADMIN', 'ADMIN', 'OPERATIONS', 'FINANCE', 'SUPPORT'];
    if (!adminRoles.includes(user.role)) {
      clearAdminToken();
      router.push('/admin/login');
      return;
    }

    setAdminUser(user);
    setLoading(false);
  }, [pathname, isLoginPage, router]);

  if (isLoginPage) {
    return <>{children}</>;
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-[#14171A] flex items-center justify-center text-white dir-rtl" dir="rtl">
        <div className="flex flex-col items-center gap-3">
          <div className="w-10 h-10 border-4 border-[#FF5722] border-t-transparent rounded-full animate-spin" />
          <span className="text-sm font-medium text-gray-300">جاري التحقق من صلاحيات مدير النظام...</span>
        </div>
      </div>
    );
  }

  const navItems = [
    { href: '/admin', label: 'الرئيسية', icon: LayoutDashboard },
    { href: '/admin/orders', label: 'الطلبات', icon: ShoppingBag },
    { href: '/admin/merchants', label: 'التجار والمتاجر', icon: Store },
    { href: '/admin/couriers', label: 'المناديب', icon: Bike },
    { href: '/admin/customers', label: 'العملاء', icon: Users },
    { href: '/admin/payments', label: 'المدفوعات وبنكك', icon: CreditCard },
    { href: '/admin/coverage', label: 'مناطق التغطية', icon: MapPin },
    { href: '/admin/support', label: 'الشكاوى والدعم', icon: HelpCircle },
    { href: '/admin/audit', label: 'سجل العمليات', icon: History },
    { href: '/admin/settings', label: 'الإعدادات', icon: Settings },
  ];

  const handleLogout = () => {
    clearAdminToken();
    router.push('/admin/login');
  };

  return (
    <div className="min-h-screen bg-[#0F1114] text-gray-100 flex dir-rtl" dir="rtl">
      {/* Sidebar */}
      <aside className="w-64 bg-[#16191D] border-l border-gray-800 flex flex-col fixed inset-y-0 right-0 z-30">
        {/* Brand Header */}
        <div className="h-18 px-6 flex items-center gap-3 border-b border-gray-800/80">
          <Image src="/logo.png" alt="Talabaty" width={34} height={34} className="object-contain" />
          <div>
            <div className="text-base font-bold text-white tracking-wide">طلبــاتي</div>
            <div className="text-[10px] text-[#FF5722] font-semibold tracking-wider uppercase">Production Admin</div>
          </div>
        </div>

        {/* Navigation Menu */}
        <nav className="flex-1 px-3 py-4 space-y-1 overflow-y-auto custom-scrollbar">
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = pathname === item.href || (item.href !== '/admin' && pathname.startsWith(item.href));
            return (
              <Link
                key={item.href}
                href={item.href}
                className={`flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-medium transition-all ${
                  isActive
                    ? 'bg-[#FF5722] text-white shadow-lg shadow-orange-950/40 font-bold'
                    : 'text-gray-400 hover:text-white hover:bg-gray-800/60'
                }`}
              >
                <Icon className={`w-5 h-5 ${isActive ? 'text-white' : 'text-gray-400'}`} />
                <span>{item.label}</span>
              </Link>
            );
          })}
        </nav>

        {/* Footer Admin Info */}
        <div className="p-4 border-t border-gray-800/80 bg-[#121417]">
          <div className="flex items-center gap-3 mb-3">
            <div className="w-9 h-9 rounded-xl bg-[#FF5722]/15 border border-[#FF5722]/30 flex items-center justify-center text-[#FF5722] font-bold text-sm">
              {adminUser?.name?.substring(0, 1) || 'A'}
            </div>
            <div className="flex-1 min-w-0">
              <div className="text-xs font-bold text-white truncate">{adminUser?.name || 'مدير النظام'}</div>
              <div className="text-[10px] text-amber-400 font-semibold">{adminUser?.role || 'ADMIN'}</div>
            </div>
          </div>

          <button
            onClick={handleLogout}
            className="w-full flex items-center justify-center gap-2 py-2 px-3 rounded-lg bg-red-500/10 hover:bg-red-500/20 text-red-400 text-xs font-semibold border border-red-500/20 transition-colors cursor-pointer"
          >
            <LogOut className="w-4 h-4" />
            <span>تسجيل الخروج</span>
          </button>
        </div>
      </aside>

      {/* Main Content Area */}
      <div className="flex-1 mr-64 flex flex-col min-w-0">
        {/* Topbar */}
        <header className="h-18 bg-[#16191D]/80 backdrop-blur-md border-b border-gray-800/80 sticky top-0 z-20 px-6 flex items-center justify-between">
          <div className="flex items-center gap-4 flex-1 max-w-md">
            <div className="relative w-full">
              <input
                type="text"
                placeholder="بحث برقم الطلب، اسم العميل، التاجر، رقم الهاتف..."
                className="w-full bg-[#0F1114] border border-gray-800 rounded-xl px-4 py-2 pr-10 text-xs text-white placeholder-gray-500 focus:outline-none focus:border-[#FF5722]"
              />
              <Search className="w-4 h-4 text-gray-500 absolute right-3 top-2.5" />
            </div>
          </div>

          <div className="flex items-center gap-4">
            {/* Real-time status indicator */}
            <div className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs font-medium">
              <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
              <Activity className="w-3.5 h-3.5" />
              <span>البث المباشر متصل</span>
            </div>

            <div className="h-4 w-px bg-gray-800" />

            <div className="flex items-center gap-2 text-xs text-gray-400">
              <ShieldCheck className="w-4 h-4 text-[#FF5722]" />
              <span>جلسة محمية</span>
            </div>
          </div>
        </header>

        {/* Page Container */}
        <main className="flex-1 p-6 md:p-8 overflow-y-auto">{children}</main>
      </div>
    </div>
  );
}
