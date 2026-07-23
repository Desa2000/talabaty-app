'use client';

import React, { useEffect, useState } from 'react';
import { adminFetch } from '@/lib/admin-api';
import { Bike, Search, CheckCircle, XCircle, RefreshCw, Eye } from 'lucide-react';

export default function AdminCouriersPage() {
  const [couriers, setCouriers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [verificationFilter, setVerificationFilter] = useState('ALL');
  const [vehicleFilter, setVehicleFilter] = useState('ALL');
  const [search, setSearch] = useState('');

  const fetchCouriers = async () => {
    setLoading(true);
    setError(null);
    try {
      const query = new URLSearchParams({
        verificationStatus: verificationFilter,
        vehicleType: vehicleFilter,
        q: search,
      });
      const res = await adminFetch(`/admin/couriers?${query.toString()}`);
      setCouriers(res.couriers || []);
    } catch (err: any) {
      setError(err.message || 'فشل جلب المناديب');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCouriers();
  }, [verificationFilter, vehicleFilter]);

  const handleUpdateCourier = async (courierId: string, verificationStatus?: string, status?: string) => {
    try {
      await adminFetch(`/admin/couriers/${courierId}/status`, {
        method: 'POST',
        body: JSON.stringify({ verificationStatus, status }),
      });
      alert('تم تحديث حساب المندوب بنجاح');
      fetchCouriers();
    } catch (err: any) {
      alert(err.message || 'فشل التحديث');
    }
  };

  return (
    <div className="space-y-6 dir-rtl" dir="rtl">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-white flex items-center gap-2">
            إدارة المناديب والأسطول <Bike className="w-6 h-6 text-[#FF5722]" />
          </h1>
          <p className="text-xs text-gray-400 mt-1">اعتماد تراخيص المناديب والتحكم في حالات التفرغ والإيقاف</p>
        </div>

        <button
          onClick={fetchCouriers}
          className="flex items-center gap-2 bg-[#16191D] hover:bg-gray-800 text-white text-xs font-semibold px-4 py-2.5 rounded-xl border border-gray-800 transition-colors cursor-pointer"
        >
          <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
          <span>تحديث الأسطول</span>
        </button>
      </div>

      {/* Filters */}
      <div className="bg-[#16191D] p-4 rounded-2xl border border-gray-800/80 grid grid-cols-1 sm:grid-cols-3 gap-3">
        <div className="relative">
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="بحث باسم المندوب، الرقم القومي، الهاتف..."
            className="w-full bg-[#0F1114] border border-gray-800 rounded-xl px-4 py-2.5 pr-10 text-xs text-white focus:outline-none focus:border-[#FF5722]"
          />
          <Search className="w-4 h-4 text-gray-500 absolute right-3.5 top-3" />
        </div>

        <select
          value={verificationFilter}
          onChange={(e) => setVerificationFilter(e.target.value)}
          className="bg-[#0F1114] border border-gray-800 rounded-xl px-3 py-2 text-xs text-white focus:outline-none focus:border-[#FF5722]"
        >
          <option value="ALL">جميع حالات التوثيق</option>
          <option value="PENDING">بانتظار الموافقة (Pending)</option>
          <option value="APPROVED">معتمد (Approved)</option>
          <option value="REJECTED">مرفوض (Rejected)</option>
        </select>

        <select
          value={vehicleFilter}
          onChange={(e) => setVehicleFilter(e.target.value)}
          className="bg-[#0F1114] border border-gray-800 rounded-xl px-3 py-2 text-xs text-white focus:outline-none focus:border-[#FF5722]"
        >
          <option value="ALL">جميع أنواع المركبات</option>
          <option value="MOTORCYCLE">دراجة نارية (Motorcycle)</option>
          <option value="ELECTRIC_BICYCLE">دراجة كهربائية (Electric Bike)</option>
          <option value="BICYCLE">دراجة هوائية (Bicycle)</option>
        </select>
      </div>

      {error && <div className="p-4 rounded-xl bg-red-500/10 text-red-400 text-sm font-medium">{error}</div>}

      {/* Couriers Table */}
      <div className="bg-[#16191D] rounded-2xl border border-gray-800/80 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-right text-sm text-gray-300">
            <thead className="bg-[#0F1114] text-xs text-gray-400 uppercase border-b border-gray-800">
              <tr>
                <th className="py-3.5 px-4">اسم المندوب</th>
                <th className="py-3.5 px-4">الهاتف</th>
                <th className="py-3.5 px-4">نوع المركبة</th>
                <th className="py-3.5 px-4">رقم الهوية / الرخصة</th>
                <th className="py-3.5 px-4">التوثيق</th>
                <th className="py-3.5 px-4">الحالة الميدانية</th>
                <th className="py-3.5 px-4 text-center">إجراءات</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-800/60">
              {couriers.map((c) => (
                <tr key={c.id} className="hover:bg-gray-800/30 transition-colors">
                  <td className="py-3.5 px-4 font-bold text-white">{c.user?.name}</td>
                  <td className="py-3.5 px-4 text-xs font-mono text-gray-400">{c.user?.phone}</td>
                  <td className="py-3.5 px-4 text-xs font-semibold text-amber-400">{c.vehicleType}</td>
                  <td className="py-3.5 px-4 text-xs font-mono">{c.idNumber} / {c.licenseNumber || 'لا يوجد'}</td>
                  <td className="py-3.5 px-4">
                    <span
                      className={`px-2.5 py-1 rounded-full text-xs font-bold ${
                        c.verificationStatus === 'APPROVED'
                          ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20'
                          : 'bg-amber-500/10 text-amber-400 border border-amber-500/20'
                      }`}
                    >
                      {c.verificationStatus}
                    </span>
                  </td>
                  <td className="py-3.5 px-4 text-xs font-semibold">{c.status}</td>
                  <td className="py-3.5 px-4 text-center">
                    <div className="flex items-center justify-center gap-2">
                      {c.verificationStatus !== 'APPROVED' && (
                        <button
                          onClick={() => handleUpdateCourier(c.id, 'APPROVED', 'AVAILABLE')}
                          className="px-2.5 py-1 rounded-lg bg-emerald-500/10 hover:bg-emerald-500/20 text-emerald-400 text-xs font-bold border border-emerald-500/20 cursor-pointer"
                        >
                          اعتماد المندوب
                        </button>
                      )}
                      {c.status !== 'SUSPENDED' && (
                        <button
                          onClick={() => handleUpdateCourier(c.id, undefined, 'SUSPENDED')}
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
    </div>
  );
}
