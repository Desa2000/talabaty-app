'use client';

import React, { useEffect, useState } from 'react';
import { adminFetch } from '@/lib/admin-api';
import { Users, Search, RefreshCw, UserX, UserCheck } from 'lucide-react';

export default function AdminCustomersPage() {
  const [customers, setCustomers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');

  const fetchCustomers = async () => {
    setLoading(true);
    try {
      const res = await adminFetch(`/admin/customers?q=${encodeURIComponent(search)}`);
      setCustomers(res.customers || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCustomers();
  }, []);

  const handleToggleCustomerStatus = async (customerId: string, currentActive: boolean) => {
    const nextActive = !currentActive;
    const reason = prompt(`يرجى كتابة سبب ${nextActive ? 'تفعيل' : 'إيقاف'} حساب العميل:`);
    if (reason === null) return;

    try {
      await adminFetch(`/admin/customers/${customerId}/status`, {
        method: 'POST',
        body: JSON.stringify({ isActive: nextActive, reason }),
      });
      alert('تم تحديث حالة حساب العميل');
      fetchCustomers();
    } catch (err: any) {
      alert(err.message || 'فشل التحديث');
    }
  };

  return (
    <div className="space-y-6 dir-rtl" dir="rtl">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-white flex items-center gap-2">
            إدارة حسابات العملاء <Users className="w-6 h-6 text-[#FF5722]" />
          </h1>
          <p className="text-xs text-gray-400 mt-1">سجل العملاء المسجلين، عدد الطلبات وإدارة تجميد الحسابات</p>
        </div>

        <button
          onClick={fetchCustomers}
          className="flex items-center gap-2 bg-[#16191D] text-white text-xs font-semibold px-4 py-2.5 rounded-xl border border-gray-800"
        >
          <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
          <span>تحديث</span>
        </button>
      </div>

      <div className="bg-[#16191D] p-4 rounded-2xl border border-gray-800 flex gap-3">
        <div className="relative flex-1">
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="بحث باسم العميل، رقم الهاتف، البريد الإلكتروني..."
            className="w-full bg-[#0F1114] border border-gray-800 rounded-xl px-4 py-2.5 pr-10 text-xs text-white focus:outline-none focus:border-[#FF5722]"
          />
          <Search className="w-4 h-4 text-gray-500 absolute right-3.5 top-3" />
        </div>
        <button onClick={fetchCustomers} className="bg-[#FF5722] text-white text-xs font-bold px-5 py-2.5 rounded-xl">
          بحث
        </button>
      </div>

      <div className="bg-[#16191D] rounded-2xl border border-gray-800 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-right text-sm text-gray-300">
            <thead className="bg-[#0F1114] text-xs text-gray-400 uppercase border-b border-gray-800">
              <tr>
                <th className="py-3.5 px-4">اسم العميل</th>
                <th className="py-3.5 px-4">الهاتف</th>
                <th className="py-3.5 px-4">البريد الإلكتروني</th>
                <th className="py-3.5 px-4">عدد الطلبات</th>
                <th className="py-3.5 px-4">تاريخ الانضمام</th>
                <th className="py-3.5 px-4">الحالة</th>
                <th className="py-3.5 px-4 text-center">إجراءات</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-800/60">
              {customers.map((c) => (
                <tr key={c.id} className="hover:bg-gray-800/30">
                  <td className="py-3.5 px-4 font-bold text-white">{c.name}</td>
                  <td className="py-3.5 px-4 text-xs font-mono text-gray-400">{c.phone}</td>
                  <td className="py-3.5 px-4 text-xs text-gray-400">{c.email || 'لا يوجد'}</td>
                  <td className="py-3.5 px-4 font-bold text-[#FF5722]">{c._count?.customerOrders || 0}</td>
                  <td className="py-3.5 px-4 text-xs text-gray-400">{new Date(c.createdAt).toLocaleDateString('ar-SD')}</td>
                  <td className="py-3.5 px-4">
                    <span className={`px-2.5 py-1 rounded-full text-xs font-bold ${c.isActive ? 'bg-emerald-500/10 text-emerald-400' : 'bg-red-500/10 text-red-400'}`}>
                      {c.isActive ? 'نشط' : 'موقوف'}
                    </span>
                  </td>
                  <td className="py-3.5 px-4 text-center">
                    <button
                      onClick={() => handleToggleCustomerStatus(c.id, c.isActive)}
                      className={`px-3 py-1 rounded-lg text-xs font-bold cursor-pointer ${
                        c.isActive ? 'bg-red-500/10 text-red-400 border border-red-500/20' : 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20'
                      }`}
                    >
                      {c.isActive ? 'تجميد الحساب' : 'إعادة التفعيل'}
                    </button>
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
