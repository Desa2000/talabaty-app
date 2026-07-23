'use client';

import React, { useEffect, useState } from 'react';
import { adminFetch } from '@/lib/admin-api';
import { HelpCircle, RefreshCw, MessageSquare } from 'lucide-react';

export default function AdminSupportPage() {
  const [tickets, setTickets] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchTickets = async () => {
    setLoading(true);
    try {
      const res = await adminFetch('/admin/support');
      setTickets(res || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchTickets();
  }, []);

  return (
    <div className="space-y-6 dir-rtl" dir="rtl">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-white flex items-center gap-2">
            إدارة البلاغات والشكاوى <HelpCircle className="w-6 h-6 text-[#FF5722]" />
          </h1>
          <p className="text-xs text-gray-400 mt-1">تذاكر الدعم الفني الخاصة بالعملاء والتجار والمناديب</p>
        </div>

        <button onClick={fetchTickets} className="flex items-center gap-2 bg-[#16191D] text-white text-xs font-semibold px-4 py-2.5 rounded-xl border border-gray-800">
          <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
          <span>تحديث</span>
        </button>
      </div>

      <div className="bg-[#16191D] rounded-2xl border border-gray-800 overflow-hidden">
        <table className="w-full text-right text-sm text-gray-300">
          <thead className="bg-[#0F1114] text-xs text-gray-400 uppercase border-b border-gray-800">
            <tr>
              <th className="py-3.5 px-4">رقم التذكرة</th>
              <th className="py-3.5 px-4">النوع</th>
              <th className="py-3.5 px-4">الأولويات</th>
              <th className="py-3.5 px-4">الوصف</th>
              <th className="py-3.5 px-4">الحالة</th>
              <th className="py-3.5 px-4">تاريخ الإنشاء</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-800/60">
            {tickets.length === 0 ? (
              <tr>
                <td colSpan={6} className="text-center py-8 text-gray-500 text-xs">
                  لا توجد بلاغات أو شكاوى مفتوحة حالياً 🎉
                </td>
              </tr>
            ) : (
              tickets.map((t) => (
                <tr key={t.id} className="hover:bg-gray-800/30">
                  <td className="py-3.5 px-4 font-mono font-bold text-white">{t.ticketNumber}</td>
                  <td className="py-3.5 px-4 text-xs">{t.type}</td>
                  <td className="py-3.5 px-4 text-xs font-bold text-amber-400">{t.priority}</td>
                  <td className="py-3.5 px-4 text-xs text-gray-300">{t.description}</td>
                  <td className="py-3.5 px-4">
                    <span className="px-2.5 py-1 rounded-full text-xs font-bold bg-blue-500/10 text-blue-400">
                      {t.status}
                    </span>
                  </td>
                  <td className="py-3.5 px-4 text-xs text-gray-400">{new Date(t.createdAt).toLocaleString('ar-SD')}</td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
