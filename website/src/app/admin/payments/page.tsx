'use client';

import React, { useEffect, useState } from 'react';
import { adminFetch } from '@/lib/admin-api';
import { CreditCard, CheckCircle, XCircle, RefreshCw, FileText, Search } from 'lucide-react';

export default function AdminPaymentsPage() {
  const [orders, setOrders] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [paymentFilter, setPaymentFilter] = useState('ALL');
  const [statusFilter, setStatusFilter] = useState('ALL');

  const fetchPayments = async () => {
    setLoading(true);
    try {
      const query = new URLSearchParams({
        paymentMethod: paymentFilter,
        paymentStatus: statusFilter,
      });
      const res = await adminFetch(`/admin/payments?${query.toString()}`);
      setOrders(res.orders || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchPayments();
  }, [paymentFilter, statusFilter]);

  const handleVerifyBankak = async (orderId: string) => {
    try {
      await adminFetch(`/admin/payments/${orderId}/verify`, { method: 'POST' });
      alert('تم توثيق تحويل بنكك بنجاح');
      fetchPayments();
    } catch (err: any) {
      alert(err.message || 'فشل التوثيق');
    }
  };

  const handleRejectBankak = async (orderId: string) => {
    const reason = prompt('يرجى تقديم سبب عدم تطابق التحويل البنكي:');
    if (reason === null) return;

    try {
      await adminFetch(`/admin/payments/${orderId}/reject`, {
        method: 'POST',
        body: JSON.stringify({ reason }),
      });
      alert('تم رفض تحويل بنكك وتسجيل السبب');
      fetchPayments();
    } catch (err: any) {
      alert(err.message || 'فشل عملية الرفض');
    }
  };

  return (
    <div className="space-y-6 dir-rtl" dir="rtl">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-white flex items-center gap-2">
            إدارة المدفوعات وتوثيق بنكك <CreditCard className="w-6 h-6 text-[#FF5722]" />
          </h1>
          <p className="text-xs text-gray-400 mt-1">مراجعة تحويلات تطبيق بنكك اليدوية وتوثيق المبالغ المستلمة</p>
        </div>

        <button
          onClick={fetchPayments}
          className="flex items-center gap-2 bg-[#16191D] text-white text-xs font-semibold px-4 py-2.5 rounded-xl border border-gray-800"
        >
          <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
          <span>تحديث المدفوعات</span>
        </button>
      </div>

      {/* Filters */}
      <div className="bg-[#16191D] p-4 rounded-2xl border border-gray-800 grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div>
          <label className="block text-xs font-semibold text-gray-400 mb-1.5">طريقة الدفع</label>
          <select
            value={paymentFilter}
            onChange={(e) => setPaymentFilter(e.target.value)}
            className="w-full bg-[#0F1114] border border-gray-800 rounded-xl p-2.5 text-xs text-white"
          >
            <option value="ALL">جميع طرق الدفع</option>
            <option value="BANKAK">تحويل بنكك (Bankak)</option>
            <option value="CASH">نقداً عند الاستلام (COD)</option>
          </select>
        </div>

        <div>
          <label className="block text-xs font-semibold text-gray-400 mb-1.5">حالة التوثيق</label>
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="w-full bg-[#0F1114] border border-gray-800 rounded-xl p-2.5 text-xs text-white"
          >
            <option value="ALL">جميع الحالات</option>
            <option value="BANKAK_PENDING">بانتظار التوثيق (Pending Verification)</option>
            <option value="BANKAK_VERIFIED">موثق ومقبول (Verified)</option>
            <option value="BANKAK_REJECTED">مرفوض (Rejected)</option>
            <option value="PAID">مدفوع (Paid)</option>
          </select>
        </div>
      </div>

      {/* Payments Table */}
      <div className="bg-[#16191D] rounded-2xl border border-gray-800 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-right text-sm text-gray-300">
            <thead className="bg-[#0F1114] text-xs text-gray-400 uppercase border-b border-gray-800">
              <tr>
                <th className="py-3.5 px-4">رقم الطلب</th>
                <th className="py-3.5 px-4">العميل</th>
                <th className="py-3.5 px-4">المبلغ</th>
                <th className="py-3.5 px-4">طريقة الدفع</th>
                <th className="py-3.5 px-4">رقم العملية / الإشعار</th>
                <th className="py-3.5 px-4">حالة التوثيق</th>
                <th className="py-3.5 px-4 text-center">إجراء التوثيق</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-800/60">
              {orders.map((o) => (
                <tr key={o.id} className="hover:bg-gray-800/30">
                  <td className="py-3.5 px-4 font-mono font-bold text-white">{o.orderNumber}</td>
                  <td className="py-3.5 px-4">
                    <div className="font-semibold text-white">{o.customer?.name}</div>
                    <div className="text-xs text-gray-500">{o.customer?.phone}</div>
                  </td>
                  <td className="py-3.5 px-4 font-bold text-white">{o.total} ج.س</td>
                  <td className="py-3.5 px-4 text-xs font-semibold text-purple-400">{o.paymentMethod}</td>
                  <td className="py-3.5 px-4 font-mono text-xs text-gray-300">{o.bankakTxnRef || 'غير مدخل'}</td>
                  <td className="py-3.5 px-4">
                    <span
                      className={`px-2.5 py-1 rounded-full text-xs font-bold ${
                        o.paymentStatus === 'BANKAK_VERIFIED' || o.paymentStatus === 'PAID'
                          ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20'
                          : o.paymentStatus === 'BANKAK_PENDING'
                          ? 'bg-purple-500/10 text-purple-400 border border-purple-500/20 animate-pulse'
                          : 'bg-red-500/10 text-red-400 border border-red-500/20'
                      }`}
                    >
                      {o.paymentStatus}
                    </span>
                  </td>
                  <td className="py-3.5 px-4 text-center">
                    {o.paymentMethod === 'BANKAK' && o.paymentStatus === 'BANKAK_PENDING' ? (
                      <div className="flex items-center justify-center gap-2">
                        <button
                          onClick={() => handleVerifyBankak(o.id)}
                          className="px-3 py-1 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold rounded-lg cursor-pointer"
                        >
                          تأكيد واستلام
                        </button>
                        <button
                          onClick={() => handleRejectBankak(o.id)}
                          className="px-3 py-1 bg-red-600 hover:bg-red-700 text-white text-xs font-bold rounded-lg cursor-pointer"
                        >
                          رفض التحويل
                        </button>
                      </div>
                    ) : (
                      <span className="text-xs text-gray-500">لا يتطلب إجراء</span>
                    )}
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
