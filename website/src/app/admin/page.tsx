'use client';

import React, { useEffect, useState } from 'react';
import Link from 'next/link';
import { adminFetch } from '@/lib/admin-api';
import {
  ShoppingBag,
  Clock,
  CheckCircle2,
  XCircle,
  Store,
  Bike,
  CreditCard,
  AlertTriangle,
  Server,
  RefreshCw,
  ArrowUpRight,
  TrendingUp,
} from 'lucide-react';

export default function AdminOverviewPage() {
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchOverview = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await adminFetch('/admin/overview');
      setData(res);
    } catch (err: any) {
      setError(err.message || 'فشل تحميل بيانات النظرة العامة');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchOverview();
    const interval = setInterval(fetchOverview, 15000); // Auto refresh every 15s
    return () => clearInterval(interval);
  }, []);

  if (loading && !data) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] text-gray-400">
        <RefreshCw className="w-8 h-8 animate-spin text-[#FF5722] mb-2" />
        <span>جاري جلب إحصائيات النظام اللحظية من PostgreSQL...</span>
      </div>
    );
  }

  const metrics = data?.metrics || {};
  const alerts: string[] = data?.alerts || [];
  const recentOrders: any[] = data?.recentOrders || [];

  return (
    <div className="space-y-8 dir-rtl" dir="rtl">
      {/* Top Banner */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 bg-gradient-to-r from-[#1A1E23] to-[#14171A] p-6 rounded-2xl border border-gray-800">
        <div>
          <h1 className="text-2xl font-bold text-white tracking-tight flex items-center gap-2">
            لوحة الإدارة التشغيلية لمناطق الخرطوم 🚀
          </h1>
          <p className="text-gray-400 text-xs mt-1">
            بيانات حقيقية مباشرة من قاعدة بيانات PostgreSQL والـ Socket.IO Engine
          </p>
        </div>

        <button
          onClick={fetchOverview}
          className="flex items-center gap-2 bg-gray-800 hover:bg-gray-700 text-white text-xs font-semibold px-4 py-2.5 rounded-xl border border-gray-700 transition-colors self-start md:self-auto cursor-pointer"
        >
          <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
          <span>تحديث البيانات</span>
        </button>
      </div>

      {error && (
        <div className="p-4 rounded-xl bg-red-500/10 border border-red-500/20 text-red-400 text-sm font-medium">
          {error}
        </div>
      )}

      {/* Operational Alerts */}
      {alerts.length > 0 && (
        <div className="space-y-2">
          {alerts.map((alert, idx) => (
            <div
              key={idx}
              className="p-4 rounded-xl bg-amber-500/10 border border-amber-500/30 text-amber-300 text-sm font-medium flex items-center gap-3 shadow-lg shadow-amber-950/20"
            >
              <AlertTriangle className="w-5 h-5 text-amber-400 shrink-0" />
              <span>{alert}</span>
            </div>
          ))}
        </div>
      )}

      {/* Primary Metrics Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Today Orders */}
        <div className="bg-[#16191D] p-5 rounded-2xl border border-gray-800/80 hover:border-gray-700 transition-colors">
          <div className="flex items-center justify-between mb-3">
            <span className="text-xs font-semibold text-gray-400">طلبات اليوم</span>
            <div className="p-2 bg-orange-500/10 text-[#FF5722] rounded-xl">
              <ShoppingBag className="w-5 h-5" />
            </div>
          </div>
          <div className="text-3xl font-extrabold text-white">{metrics.todayOrdersCount || 0}</div>
          <div className="text-[11px] text-gray-500 mt-1 flex items-center gap-1">
            <TrendingUp className="w-3.5 h-3.5 text-emerald-400" />
            <span>طلب مسجل اليوم</span>
          </div>
        </div>

        {/* Active Orders */}
        <div className="bg-[#16191D] p-5 rounded-2xl border border-gray-800/80 hover:border-gray-700 transition-colors">
          <div className="flex items-center justify-between mb-3">
            <span className="text-xs font-semibold text-gray-400">الطلبات النشطة حلياً</span>
            <div className="p-2 bg-blue-500/10 text-blue-400 rounded-xl">
              <Clock className="w-5 h-5" />
            </div>
          </div>
          <div className="text-3xl font-extrabold text-blue-400">{metrics.activeOrdersCount || 0}</div>
          <div className="text-[11px] text-gray-500 mt-1">تتطلب متابعة مباشرة</div>
        </div>

        {/* Pending Bankak */}
        <div className="bg-[#16191D] p-5 rounded-2xl border border-gray-800/80 hover:border-gray-700 transition-colors">
          <div className="flex items-center justify-between mb-3">
            <span className="text-xs font-semibold text-gray-400">بنكك بانتظار التوثيق</span>
            <div className="p-2 bg-purple-500/10 text-purple-400 rounded-xl">
              <CreditCard className="w-5 h-5" />
            </div>
          </div>
          <div className="text-3xl font-extrabold text-purple-400">{metrics.pendingBankakCount || 0}</div>
          <div className="text-[11px] text-gray-500 mt-1">تحويلات مالية معلقة</div>
        </div>

        {/* Completed Orders */}
        <div className="bg-[#16191D] p-5 rounded-2xl border border-gray-800/80 hover:border-gray-700 transition-colors">
          <div className="flex items-center justify-between mb-3">
            <span className="text-xs font-semibold text-gray-400">الطلبات المكتملة</span>
            <div className="p-2 bg-emerald-500/10 text-emerald-400 rounded-xl">
              <CheckCircle2 className="w-5 h-5" />
            </div>
          </div>
          <div className="text-3xl font-extrabold text-emerald-400">{metrics.completedOrdersCount || 0}</div>
          <div className="text-[11px] text-gray-500 mt-1">تم توصيلها بنجاح</div>
        </div>
      </div>

      {/* Secondary Status Breakdown */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Merchants Card */}
        <div className="bg-[#16191D] p-6 rounded-2xl border border-gray-800/80">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-base font-bold text-white flex items-center gap-2">
              <Store className="w-5 h-5 text-[#FF5722]" /> التجار والمتاجر
            </h3>
            <Link href="/admin/merchants" className="text-xs text-[#FF5722] font-semibold hover:underline flex items-center gap-0.5">
              <span>عرض الكل</span> <ArrowUpRight className="w-3.5 h-3.5" />
            </Link>
          </div>
          <div className="space-y-3">
            <div className="flex justify-between items-center p-3 rounded-xl bg-[#0F1114]">
              <span className="text-xs text-gray-400">بانتظار الاعتماد</span>
              <span className="text-sm font-bold text-amber-400">{metrics.merchants?.pending || 0}</span>
            </div>
            <div className="flex justify-between items-center p-3 rounded-xl bg-[#0F1114]">
              <span className="text-xs text-gray-400">تجار معتمدون ونشطون</span>
              <span className="text-sm font-bold text-emerald-400">{metrics.merchants?.approved || 0}</span>
            </div>
            <div className="flex justify-between items-center p-3 rounded-xl bg-[#0F1114]">
              <span className="text-xs text-gray-400">حسابات موقوفة</span>
              <span className="text-sm font-bold text-red-400">{metrics.merchants?.suspended || 0}</span>
            </div>
          </div>
        </div>

        {/* Couriers Card */}
        <div className="bg-[#16191D] p-6 rounded-2xl border border-gray-800/80">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-base font-bold text-white flex items-center gap-2">
              <Bike className="w-5 h-5 text-[#FF5722]" /> المناديب والأسطول
            </h3>
            <Link href="/admin/couriers" className="text-xs text-[#FF5722] font-semibold hover:underline flex items-center gap-0.5">
              <span>عرض الكل</span> <ArrowUpRight className="w-3.5 h-3.5" />
            </Link>
          </div>
          <div className="space-y-3">
            <div className="flex justify-between items-center p-3 rounded-xl bg-[#0F1114]">
              <span className="text-xs text-gray-400">متاحين للتوصيل الآن</span>
              <span className="text-sm font-bold text-emerald-400">{metrics.couriers?.available || 0}</span>
            </div>
            <div className="flex justify-between items-center p-3 rounded-xl bg-[#0F1114]">
              <span className="text-xs text-gray-400">مشغولين في توصيل طلبات</span>
              <span className="text-sm font-bold text-blue-400">{metrics.couriers?.busy || 0}</span>
            </div>
            <div className="flex justify-between items-center p-3 rounded-xl bg-[#0F1114]">
              <span className="text-xs text-gray-400">بانتظار موافقة الإدارة</span>
              <span className="text-sm font-bold text-amber-400">{metrics.couriers?.pending || 0}</span>
            </div>
          </div>
        </div>

        {/* System Health */}
        <div className="bg-[#16191D] p-6 rounded-2xl border border-gray-800/80">
          <h3 className="text-base font-bold text-white flex items-center gap-2 mb-4">
            <Server className="w-5 h-5 text-[#FF5722]" /> حالة السيرفر والخدمات
          </h3>
          <div className="space-y-3">
            <div className="flex justify-between items-center p-3 rounded-xl bg-[#0F1114]">
              <span className="text-xs text-gray-400">Express REST API</span>
              <span className="px-2.5 py-1 rounded-full bg-emerald-500/10 text-emerald-400 text-xs font-bold border border-emerald-500/20">
                {data?.systemHealth?.api}
              </span>
            </div>
            <div className="flex justify-between items-center p-3 rounded-xl bg-[#0F1114]">
              <span className="text-xs text-gray-400">PostgreSQL Database</span>
              <span className="px-2.5 py-1 rounded-full bg-emerald-500/10 text-emerald-400 text-xs font-bold border border-emerald-500/20">
                {data?.systemHealth?.database}
              </span>
            </div>
            <div className="flex justify-between items-center p-3 rounded-xl bg-[#0F1114]">
              <span className="text-xs text-gray-400">Socket.IO Real-Time</span>
              <span className="px-2.5 py-1 rounded-full bg-emerald-500/10 text-emerald-400 text-xs font-bold border border-emerald-500/20">
                {data?.systemHealth?.socket}
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* Recent Orders Table */}
      <div className="bg-[#16191D] rounded-2xl border border-gray-800/80 p-6">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h3 className="text-lg font-bold text-white">آخر الطلبات المسجلة</h3>
            <p className="text-xs text-gray-400 mt-0.5">تأكيد حالة الطلبات وتفاعلات العميل والتاجر والمندوب</p>
          </div>
          <Link
            href="/admin/orders"
            className="bg-[#FF5722] hover:bg-orange-600 text-white text-xs font-bold px-4 py-2 rounded-xl transition-colors"
          >
            إدارة كل الطلبات
          </Link>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-right text-sm text-gray-300">
            <thead className="bg-[#0F1114] text-xs text-gray-400 uppercase border-b border-gray-800">
              <tr>
                <th className="py-3 px-4">رقم الطلب</th>
                <th className="py-3 px-4">العميل</th>
                <th className="py-3 px-4">المتجر</th>
                <th className="py-3 px-4">المندوب</th>
                <th className="py-3 px-4">الحالة</th>
                <th className="py-3 px-4">الإجمالي</th>
                <th className="py-3 px-4">التاريخ</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-800/60">
              {recentOrders.map((order: any) => (
                <tr key={order.id} className="hover:bg-gray-800/30 transition-colors">
                  <td className="py-3.5 px-4 font-mono font-bold text-white">{order.orderNumber}</td>
                  <td className="py-3.5 px-4">
                    <div className="font-semibold text-white">{order.customer?.name}</div>
                    <div className="text-xs text-gray-500">{order.customer?.phone}</div>
                  </td>
                  <td className="py-3.5 px-4">
                    <div className="font-semibold text-white">{order.store?.name}</div>
                    <div className="text-xs text-gray-500">{order.store?.category}</div>
                  </td>
                  <td className="py-3.5 px-4">
                    {order.courier ? (
                      <span className="text-emerald-400 font-medium">{order.courier.name}</span>
                    ) : (
                      <span className="text-gray-500 text-xs">غير مسند</span>
                    )}
                  </td>
                  <td className="py-3.5 px-4">
                    <span className="px-2.5 py-1 rounded-full text-xs font-bold bg-amber-500/10 text-amber-400 border border-amber-500/20">
                      {order.status}
                    </span>
                  </td>
                  <td className="py-3.5 px-4 font-bold text-white">{order.total} ج.س</td>
                  <td className="py-3.5 px-4 text-xs text-gray-400">
                    {new Date(order.createdAt).toLocaleTimeString('ar-SD', { hour: '2-digit', minute: '2-digit' })}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
