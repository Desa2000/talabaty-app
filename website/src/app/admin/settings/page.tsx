'use client';

import React, { useEffect, useState } from 'react';
import { adminFetch } from '@/lib/admin-api';
import { Settings, UserPlus, Shield, Save, RefreshCw } from 'lucide-react';

export default function AdminSettingsPage() {
  const [settings, setSettings] = useState<Record<string, string>>({});
  const [adminUsers, setAdminUsers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  // New Admin Modal
  const [showAddAdmin, setShowAddAdmin] = useState(false);
  const [newAdmin, setNewAdmin] = useState({
    name: '',
    phone: '',
    email: '',
    password: '',
    role: 'ADMIN',
  });

  const fetchData = async () => {
    setLoading(true);
    try {
      const [sets, users] = await Promise.all([
        adminFetch('/admin/settings'),
        adminFetch('/admin/users').catch(() => []), // Super Admin only endpoint
      ]);
      setSettings(sets || {});
      setAdminUsers(users || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleSaveSettings = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await adminFetch('/admin/settings', {
        method: 'PUT',
        body: JSON.stringify(settings),
      });
      alert('تم حفظ إعدادات النظام بنجاح');
      fetchData();
    } catch (err: any) {
      alert(err.message || 'فشل حفظ الإعدادات');
    }
  };

  const handleCreateAdmin = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await adminFetch('/admin/users', {
        method: 'POST',
        body: JSON.stringify(newAdmin),
      });
      alert('تم إنشاء حساب المدير الجديد بنجاح');
      setShowAddAdmin(false);
      setNewAdmin({ name: '', phone: '', email: '', password: '', role: 'ADMIN' });
      fetchData();
    } catch (err: any) {
      alert(err.message || 'فشل إنشاء حساب المدير');
    }
  };

  return (
    <div className="space-y-8 dir-rtl" dir="rtl">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-white flex items-center gap-2">
            إعدادات النظام والمدراء <Settings className="w-6 h-6 text-[#FF5722]" />
          </h1>
          <p className="text-xs text-gray-400 mt-1">التحكم في المتغيرات التشغيلية للمنظومة وإدارة صلاحيات المشغلين (SUPER_ADMIN)</p>
        </div>

        <button onClick={fetchData} className="flex items-center gap-2 bg-[#16191D] text-white text-xs font-semibold px-4 py-2.5 rounded-xl border border-gray-800">
          <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
          <span>تحديث الإعدادات</span>
        </button>
      </div>

      {/* Settings Form */}
      <form onSubmit={handleSaveSettings} className="bg-[#16191D] p-6 rounded-2xl border border-gray-800 space-y-6">
        <h3 className="text-lg font-bold text-white border-b border-gray-800 pb-3">الإعدادات التشغيلية العامة</h3>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
          <div className="flex items-center justify-between p-4 bg-[#0F1114] rounded-xl border border-gray-800">
            <span className="text-xs font-semibold text-gray-300">استقبال طلبات جديدة</span>
            <input
              type="checkbox"
              checked={settings['accept_new_orders'] === 'true'}
              onChange={(e) => setSettings({ ...settings, accept_new_orders: String(e.target.checked) })}
              className="w-5 h-5 accent-[#FF5722] cursor-pointer"
            />
          </div>

          <div className="flex items-center justify-between p-4 bg-[#0F1114] rounded-xl border border-gray-800">
            <span className="text-xs font-semibold text-gray-300">تسجيل تجار جدد متاح</span>
            <input
              type="checkbox"
              checked={settings['merchant_registration_enabled'] === 'true'}
              onChange={(e) => setSettings({ ...settings, merchant_registration_enabled: String(e.target.checked) })}
              className="w-5 h-5 accent-[#FF5722] cursor-pointer"
            />
          </div>

          <div className="flex items-center justify-between p-4 bg-[#0F1114] rounded-xl border border-gray-800">
            <span className="text-xs font-semibold text-gray-300">تسجيل مناديب جدد متاح</span>
            <input
              type="checkbox"
              checked={settings['courier_registration_enabled'] === 'true'}
              onChange={(e) => setSettings({ ...settings, courier_registration_enabled: String(e.target.checked) })}
              className="w-5 h-5 accent-[#FF5722] cursor-pointer"
            />
          </div>

          <div>
            <label className="block text-xs text-gray-400 mb-1">أقصى نطاق للطلب (كم)</label>
            <input
              type="text"
              value={settings['maximum_order_radius_km'] || '25'}
              onChange={(e) => setSettings({ ...settings, maximum_order_radius_km: e.target.value })}
              className="w-full bg-[#0F1114] border border-gray-800 rounded-xl p-3 text-xs text-white"
            />
          </div>

          <div>
            <label className="block text-xs text-gray-400 mb-1">هاتف الدعم الفني</label>
            <input
              type="text"
              value={settings['support_phone'] || '0900000000'}
              onChange={(e) => setSettings({ ...settings, support_phone: e.target.value })}
              className="w-full bg-[#0F1114] border border-gray-800 rounded-xl p-3 text-xs text-white"
            />
          </div>

          <div>
            <label className="block text-xs text-gray-400 mb-1">البريد الإلكتروني للدعم</label>
            <input
              type="text"
              value={settings['support_email'] || 'support@mytalabaty.com'}
              onChange={(e) => setSettings({ ...settings, support_email: e.target.value })}
              className="w-full bg-[#0F1114] border border-gray-800 rounded-xl p-3 text-xs text-white"
            />
          </div>
        </div>

        <button type="submit" className="bg-[#FF5722] hover:bg-orange-600 text-white text-xs font-bold px-6 py-3 rounded-xl flex items-center gap-2 cursor-pointer">
          <Save className="w-4 h-4" />
          <span>حفظ إعدادات المنظومة</span>
        </button>
      </form>

      {/* Admin Users Management */}
      <div className="bg-[#16191D] p-6 rounded-2xl border border-gray-800 space-y-6">
        <div className="flex items-center justify-between border-b border-gray-800 pb-3">
          <h3 className="text-lg font-bold text-white flex items-center gap-2">
            <Shield className="w-5 h-5 text-[#FF5722]" /> حسابات مدراء النظام والـ RBAC
          </h3>
          <button
            onClick={() => setShowAddAdmin(true)}
            className="bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold px-4 py-2 rounded-xl flex items-center gap-2 cursor-pointer"
          >
            <UserPlus className="w-4 h-4" />
            <span>إضافة مدير جديد</span>
          </button>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-right text-sm text-gray-300">
            <thead className="bg-[#0F1114] text-xs text-gray-400 uppercase border-b border-gray-800">
              <tr>
                <th className="py-3 px-4">اسم المدير</th>
                <th className="py-3 px-4">الهاتف</th>
                <th className="py-3 px-4">البريد الإلكتروني</th>
                <th className="py-3 px-4">الدور الوظيفي (Role)</th>
                <th className="py-3 px-4">تاريخ الإنشاء</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-800/60">
              {adminUsers.map((u) => (
                <tr key={u.id} className="hover:bg-gray-800/30">
                  <td className="py-3 px-4 font-bold text-white">{u.name}</td>
                  <td className="py-3 px-4 text-xs font-mono text-gray-400">{u.phone}</td>
                  <td className="py-3 px-4 text-xs text-gray-400">{u.email || '-'}</td>
                  <td className="py-3 px-4">
                    <span className="px-2.5 py-1 rounded-full text-xs font-bold bg-amber-500/10 text-amber-400 border border-amber-500/20">
                      {u.role}
                    </span>
                  </td>
                  <td className="py-3 px-4 text-xs text-gray-400">{new Date(u.createdAt).toLocaleDateString('ar-SD')}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Add Admin Modal */}
      {showAddAdmin && (
        <div className="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <form onSubmit={handleCreateAdmin} className="bg-[#16191D] border border-gray-800 rounded-3xl w-full max-w-md p-6 space-y-4">
            <h3 className="text-lg font-bold text-white">إضافة حساب مدير جديد</h3>

            <div>
              <label className="block text-xs text-gray-400 mb-1">الاسم الكامل</label>
              <input
                type="text"
                required
                value={newAdmin.name}
                onChange={(e) => setNewAdmin({ ...newAdmin, name: e.target.value })}
                className="w-full bg-[#0F1114] border border-gray-800 rounded-xl p-2.5 text-xs text-white"
              />
            </div>

            <div>
              <label className="block text-xs text-gray-400 mb-1">رقم الهاتف</label>
              <input
                type="text"
                required
                value={newAdmin.phone}
                onChange={(e) => setNewAdmin({ ...newAdmin, phone: e.target.value })}
                className="w-full bg-[#0F1114] border border-gray-800 rounded-xl p-2.5 text-xs text-white"
              />
            </div>

            <div>
              <label className="block text-xs text-gray-400 mb-1">البريد الإلكتروني</label>
              <input
                type="email"
                required
                value={newAdmin.email}
                onChange={(e) => setNewAdmin({ ...newAdmin, email: e.target.value })}
                className="w-full bg-[#0F1114] border border-gray-800 rounded-xl p-2.5 text-xs text-white"
              />
            </div>

            <div>
              <label className="block text-xs text-gray-400 mb-1">كلمة المرور</label>
              <input
                type="password"
                required
                value={newAdmin.password}
                onChange={(e) => setNewAdmin({ ...newAdmin, password: e.target.value })}
                className="w-full bg-[#0F1114] border border-gray-800 rounded-xl p-2.5 text-xs text-white"
              />
            </div>

            <div>
              <label className="block text-xs text-gray-400 mb-1">الدور الوظيفي (RBAC Role)</label>
              <select
                value={newAdmin.role}
                onChange={(e) => setNewAdmin({ ...newAdmin, role: e.target.value })}
                className="w-full bg-[#0F1114] border border-gray-800 rounded-xl p-2.5 text-xs text-white"
              >
                <option value="ADMIN">ADMIN</option>
                <option value="OPERATIONS">OPERATIONS</option>
                <option value="FINANCE">FINANCE</option>
                <option value="SUPPORT">SUPPORT</option>
                <option value="SUPER_ADMIN">SUPER_ADMIN</option>
              </select>
            </div>

            <div className="flex items-center gap-3 pt-2">
              <button type="submit" className="flex-1 bg-[#FF5722] text-white font-bold py-2.5 rounded-xl text-xs">
                إنشاء الحساب
              </button>
              <button type="button" onClick={() => setShowAddAdmin(false)} className="px-4 py-2.5 bg-gray-800 text-gray-300 text-xs font-semibold rounded-xl">
                إلغاء
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  );
}
