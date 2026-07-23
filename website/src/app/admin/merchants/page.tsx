'use client';

import React, { useEffect, useState } from 'react';
import { adminFetch } from '@/lib/admin-api';
import { Store, Search, CheckCircle, XCircle, AlertCircle, RefreshCw, Eye } from 'lucide-react';

export default function AdminMerchantsPage() {
  const [merchants, setMerchants] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [statusFilter, setStatusFilter] = useState('ALL');
  const [search, setSearch] = useState('');
  const [selectedMerchant, setSelectedMerchant] = useState<any | null>(null);

  const fetchMerchants = async () => {
    setLoading(true);
    setError(null);
    try {
      const query = new URLSearchParams({
        status: statusFilter,
        q: search,
      });
      const res = await adminFetch(`/admin/merchants?${query.toString()}`);
      setMerchants(res.merchants || []);
    } catch (err: any) {
      setError(err.message || 'فشل جلب التجار');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchMerchants();
  }, [statusFilter]);

  const handleUpdateStatus = async (merchantId: string, status: string) => {
    let reason: string | null = null;
    if (status === 'REJECTED' || status === 'SUSPENDED') {
      reason = prompt('يرجى تقديم سبب القرار:');
      if (reason === null) return;
    }

    try {
      await adminFetch(`/admin/merchants/${merchantId}/status`, {
        method: 'POST',
        body: JSON.stringify({ status, reason }),
      });
      alert(`تم تحديث حالة التاجر إلى ${status}`);
      setSelectedMerchant(null);
      fetchMerchants();
    } catch (err: any) {
      alert(err.message || 'فشل تحديث الحالة');
    }
  };

  return (
    <div className="space-y-6 dir-rtl" dir="rtl">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-white flex items-center gap-2">
            إدارة التجار والمتاجر <Store className="w-6 h-6 text-[#FF5722]" />
          </h1>
          <p className="text-xs text-gray-400 mt-1">مراجعة طلبات التسجيل الجدد، تفعيل وتعطيل المتاجر</p>
        </div>

        <button
          onClick={fetchMerchants}
          className="flex items-center gap-2 bg-[#16191D] hover:bg-gray-800 text-white text-xs font-semibold px-4 py-2.5 rounded-xl border border-gray-800 transition-colors cursor-pointer"
        >
          <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
          <span>تحديث القائمة</span>
        </button>
      </div>

      {/* Filter & Search */}
      <div className="bg-[#16191D] p-4 rounded-2xl border border-gray-800/80 flex flex-col md:flex-row gap-3">
        <div className="relative flex-1">
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="بحث باسم التجارة، صاحب المتجر، رقم الهاتف..."
            className="w-full bg-[#0F1114] border border-gray-800 rounded-xl px-4 py-2.5 pr-10 text-xs text-white placeholder-gray-500 focus:outline-none focus:border-[#FF5722]"
          />
          <Search className="w-4 h-4 text-gray-500 absolute right-3.5 top-3" />
        </div>

        <select
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
          className="bg-[#0F1114] border border-gray-800 rounded-xl px-4 py-2.5 text-xs text-white focus:outline-none focus:border-[#FF5722]"
        >
          <option value="ALL">جميع الحالات</option>
          <option value="PENDING">بانتظار الاعتماد (Pending)</option>
          <option value="APPROVED">معتمد ونشط (Approved)</option>
          <option value="REJECTED">مرفوض (Rejected)</option>
          <option value="SUSPENDED">موقوف (Suspended)</option>
        </select>
      </div>

      {error && (
        <div className="p-4 rounded-xl bg-red-500/10 border border-red-500/20 text-red-400 text-sm font-medium">
          {error}
        </div>
      )}

      {/* Merchants Table */}
      <div className="bg-[#16191D] rounded-2xl border border-gray-800/80 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-right text-sm text-gray-300">
            <thead className="bg-[#0F1114] text-xs text-gray-400 uppercase border-b border-gray-800">
              <tr>
                <th className="py-3.5 px-4">اسم التجارة / المتجر</th>
                <th className="py-3.5 px-4">المالك</th>
                <th className="py-3.5 px-4">الهاتف</th>
                <th className="py-3.5 px-4">التصنيف</th>
                <th className="py-3.5 px-4">حالة الاعتماد</th>
                <th className="py-3.5 px-4 text-center">إجراءات</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-800/60">
              {merchants.map((merchant) => (
                <tr key={merchant.id} className="hover:bg-gray-800/30 transition-colors">
                  <td className="py-3.5 px-4 font-bold text-white">{merchant.businessName}</td>
                  <td className="py-3.5 px-4">{merchant.user?.name}</td>
                  <td className="py-3.5 px-4 text-xs font-mono text-gray-400">{merchant.user?.phone}</td>
                  <td className="py-3.5 px-4 text-xs">
                    {merchant.stores?.[0]?.category || 'RESTAURANT'}
                  </td>
                  <td className="py-3.5 px-4">
                    <span
                      className={`px-2.5 py-1 rounded-full text-xs font-bold ${
                        merchant.status === 'APPROVED'
                          ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20'
                          : merchant.status === 'PENDING'
                          ? 'bg-amber-500/10 text-amber-400 border border-amber-500/20'
                          : 'bg-red-500/10 text-red-400 border border-red-500/20'
                      }`}
                    >
                      {merchant.status}
                    </span>
                  </td>
                  <td className="py-3.5 px-4 text-center">
                    <div className="flex items-center justify-center gap-2">
                      <button
                        onClick={() => setSelectedMerchant(merchant)}
                        className="p-1.5 rounded-lg bg-gray-800 hover:bg-gray-700 text-white text-xs font-semibold flex items-center gap-1 cursor-pointer"
                      >
                        <Eye className="w-4 h-4" />
                        <span>مراجعة</span>
                      </button>

                      {merchant.status !== 'APPROVED' && (
                        <button
                          onClick={() => handleUpdateStatus(merchant.id, 'APPROVED')}
                          className="px-2.5 py-1 rounded-lg bg-emerald-500/10 hover:bg-emerald-500/20 text-emerald-400 text-xs font-bold border border-emerald-500/20 cursor-pointer"
                        >
                          اعتماد
                        </button>
                      )}

                      {merchant.status !== 'SUSPENDED' && (
                        <button
                          onClick={() => handleUpdateStatus(merchant.id, 'SUSPENDED')}
                          className="px-2.5 py-1 rounded-lg bg-red-500/10 hover:bg-red-500/20 text-red-400 text-xs font-bold border border-red-500/20 cursor-pointer"
                        >
                          إيقاف
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Review Modal */}
      {selectedMerchant && (
        <div className="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-[#16191D] border border-gray-800 rounded-3xl w-full max-w-lg p-6 space-y-5">
            <div className="flex items-center justify-between border-b border-gray-800 pb-3">
              <h3 className="text-lg font-bold text-white">تفاصيل التاجر: {selectedMerchant.businessName}</h3>
              <button onClick={() => setSelectedMerchant(null)} className="text-gray-400 hover:text-white">✕</button>
            </div>

            <div className="space-y-3 text-xs text-gray-300">
              <div className="flex justify-between border-b border-gray-800/50 pb-2">
                <span>اسم المالك:</span> <span className="font-bold text-white">{selectedMerchant.user?.name}</span>
              </div>
              <div className="flex justify-between border-b border-gray-800/50 pb-2">
                <span>الهاتف:</span> <span className="font-mono text-white">{selectedMerchant.user?.phone}</span>
              </div>
              <div className="flex justify-between border-b border-gray-800/50 pb-2">
                <span>المنطقة:</span> <span className="text-white">{selectedMerchant.businessArea || 'الخرطوم'}</span>
              </div>
              <div className="flex justify-between border-b border-gray-800/50 pb-2">
                <span>وصف النشاط:</span> <span className="text-white">{selectedMerchant.businessDescription || 'لا يوجد'}</span>
              </div>
            </div>

            <div className="flex items-center justify-end gap-3 pt-3">
              <button
                onClick={() => handleUpdateStatus(selectedMerchant.id, 'APPROVED')}
                className="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-xl text-xs"
              >
                اعتماد التاجر
              </button>
              <button
                onClick={() => handleUpdateStatus(selectedMerchant.id, 'REJECTED')}
                className="px-4 py-2 bg-red-600 hover:bg-red-700 text-white font-bold rounded-xl text-xs"
              >
                رفض
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
