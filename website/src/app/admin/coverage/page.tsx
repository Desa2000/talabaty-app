'use client';

import React, { useEffect, useState } from 'react';
import { adminFetch } from '@/lib/admin-api';
import { MapPin, RefreshCw, Edit2, CheckCircle2 } from 'lucide-react';

export default function AdminCoveragePage() {
  const [areas, setAreas] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [editingArea, setEditingArea] = useState<any | null>(null);

  const fetchCoverage = async () => {
    setLoading(true);
    try {
      const res = await adminFetch('/admin/coverage');
      setAreas(res || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCoverage();
  }, []);

  const handleUpdateArea = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingArea) return;

    try {
      await adminFetch(`/admin/coverage/${editingArea.id}`, {
        method: 'PUT',
        body: JSON.stringify({
          isActive: editingArea.isActive,
          deliveryRadius: editingArea.deliveryRadius,
          minimumDeliveryFee: editingArea.minimumDeliveryFee,
          pricePerKm: editingArea.pricePerKm,
        }),
      });
      alert('تم تحديث منطقة التغطية وإعدادات التسعير بنجاح');
      setEditingArea(null);
      fetchCoverage();
    } catch (err: any) {
      alert(err.message || 'فشل التحديث');
    }
  };

  return (
    <div className="space-y-6 dir-rtl" dir="rtl">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-white flex items-center gap-2">
            إدارة مناطق التغطية ورسوم التوصيل <MapPin className="w-6 h-6 text-[#FF5722]" />
          </h1>
          <p className="text-xs text-gray-400 mt-1">تحديد محليات ولاية الخرطوم النشطة ونطاقات الخدمة والتعريفة للكيلومتر</p>
        </div>

        <button
          onClick={fetchCoverage}
          className="flex items-center gap-2 bg-[#16191D] text-white text-xs font-semibold px-4 py-2.5 rounded-xl border border-gray-800"
        >
          <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
          <span>تحديث المناطق</span>
        </button>
      </div>

      {/* Coverage Areas Table */}
      <div className="bg-[#16191D] rounded-2xl border border-gray-800 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-right text-sm text-gray-300">
            <thead className="bg-[#0F1114] text-xs text-gray-400 uppercase border-b border-gray-800">
              <tr>
                <th className="py-3.5 px-4">الولاية</th>
                <th className="py-3.5 px-4">المحلية</th>
                <th className="py-3.5 px-4">حالة التغطية</th>
                <th className="py-3.5 px-4">نطاق التوصيل (كم)</th>
                <th className="py-3.5 px-4">الحد الأدنى للرسوم</th>
                <th className="py-3.5 px-4">السعر / كم</th>
                <th className="py-3.5 px-4 text-center">تعديل</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-800/60">
              {areas.map((a) => (
                <tr key={a.id} className="hover:bg-gray-800/30">
                  <td className="py-3.5 px-4 font-bold text-white">{a.state}</td>
                  <td className="py-3.5 px-4 font-semibold text-[#FF5722]">{a.nameAr}</td>
                  <td className="py-3.5 px-4">
                    <span className={`px-2.5 py-1 rounded-full text-xs font-bold ${a.isActive ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20' : 'bg-gray-800 text-gray-500'}`}>
                      {a.isActive ? 'نشطة (Active)' : 'قيد التخطيط (Inactive)'}
                    </span>
                  </td>
                  <td className="py-3.5 px-4 font-mono">{a.deliveryRadius} كم</td>
                  <td className="py-3.5 px-4 font-bold text-white">{a.minimumDeliveryFee} ج.س</td>
                  <td className="py-3.5 px-4 font-mono text-gray-400">{a.pricePerKm} ج.س</td>
                  <td className="py-3.5 px-4 text-center">
                    <button
                      onClick={() => setEditingArea(a)}
                      className="p-2 rounded-lg bg-gray-800 hover:bg-gray-700 text-white text-xs font-semibold cursor-pointer"
                    >
                      <Edit2 className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Edit Area Modal */}
      {editingArea && (
        <div className="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <form onSubmit={handleUpdateArea} className="bg-[#16191D] border border-gray-800 rounded-3xl w-full max-w-md p-6 space-y-4">
            <h3 className="text-lg font-bold text-white">تعديل منطقة {editingArea.nameAr}</h3>

            <div className="flex items-center justify-between p-3 bg-[#0F1114] rounded-xl">
              <span className="text-xs text-gray-300 font-semibold">تفعيل التغطية لهذه المنطقة</span>
              <input
                type="checkbox"
                checked={editingArea.isActive}
                onChange={(e) => setEditingArea({ ...editingArea, isActive: e.target.checked })}
                className="w-5 h-5 accent-[#FF5722] cursor-pointer"
              />
            </div>

            <div>
              <label className="block text-xs text-gray-400 mb-1">نطاق التوصيل الأقصى (كم)</label>
              <input
                type="number"
                value={editingArea.deliveryRadius}
                onChange={(e) => setEditingArea({ ...editingArea, deliveryRadius: parseFloat(e.target.value) })}
                className="w-full bg-[#0F1114] border border-gray-800 rounded-xl p-2.5 text-xs text-white"
              />
            </div>

            <div>
              <label className="block text-xs text-gray-400 mb-1">الحد الأدنى لرسوم التوصيل (ج.س)</label>
              <input
                type="number"
                value={editingArea.minimumDeliveryFee}
                onChange={(e) => setEditingArea({ ...editingArea, minimumDeliveryFee: parseFloat(e.target.value) })}
                className="w-full bg-[#0F1114] border border-gray-800 rounded-xl p-2.5 text-xs text-white"
              />
            </div>

            <div>
              <label className="block text-xs text-gray-400 mb-1">تعريفة الكيلومتر (ج.س/كم)</label>
              <input
                type="number"
                value={editingArea.pricePerKm}
                onChange={(e) => setEditingArea({ ...editingArea, pricePerKm: parseFloat(e.target.value) })}
                className="w-full bg-[#0F1114] border border-gray-800 rounded-xl p-2.5 text-xs text-white"
              />
            </div>

            <div className="flex items-center gap-3 pt-2">
              <button type="submit" className="flex-1 bg-[#FF5722] hover:bg-orange-600 text-white font-bold py-2.5 rounded-xl text-xs">
                حفظ التغييرات
              </button>
              <button type="button" onClick={() => setEditingArea(null)} className="px-4 py-2.5 bg-gray-800 text-gray-300 text-xs font-semibold rounded-xl">
                إلغاء
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  );
}
