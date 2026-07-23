'use client';

import React, { useEffect, useState } from 'react';
import { adminFetch } from '@/lib/admin-api';
import { History, RefreshCw, ShieldAlert } from 'lucide-react';

export default function AdminAuditPage() {
  const [logs, setLogs] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchLogs = async () => {
    setLoading(true);
    try {
      const res = await adminFetch('/admin/audit');
      setLogs(res.logs || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchLogs();
  }, []);

  return (
    <div className="space-y-6 dir-rtl" dir="rtl">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-white flex items-center gap-2">
            سجل العمليات والتدقيق الإداري <History className="w-6 h-6 text-[#FF5722]" />
          </h1>
          <p className="text-xs text-gray-400 mt-1">سجل غير قابل للتعديل لتتبع كافة القرارات والإجراءات الحساسة المأخوذة في النظام</p>
        </div>

        <button onClick={fetchLogs} className="flex items-center gap-2 bg-[#16191D] text-white text-xs font-semibold px-4 py-2.5 rounded-xl border border-gray-800">
          <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
          <span>تحديث السجل</span>
        </button>
      </div>

      <div className="bg-[#16191D] rounded-2xl border border-gray-800 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-right text-sm text-gray-300">
            <thead className="bg-[#0F1114] text-xs text-gray-400 uppercase border-b border-gray-800">
              <tr>
                <th className="py-3.5 px-4">نوع الإجراء</th>
                <th className="py-3.5 px-4">نوع الكيان</th>
                <th className="py-3.5 px-4">معرف الكيان (Entity ID)</th>
                <th className="py-3.5 px-4">معرف المدير</th>
                <th className="py-3.5 px-4">تفاصيل التعديل</th>
                <th className="py-3.5 px-4">التاريخ والوقت</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-800/60">
              {logs.map((log) => (
                <tr key={log.id} className="hover:bg-gray-800/30">
                  <td className="py-3.5 px-4">
                    <span className="px-2.5 py-1 rounded-full text-xs font-bold bg-[#FF5722]/10 text-[#FF5722] border border-[#FF5722]/20">
                      {log.action}
                    </span>
                  </td>
                  <td className="py-3.5 px-4 text-xs font-bold text-gray-300">{log.entityType}</td>
                  <td className="py-3.5 px-4 text-xs font-mono text-gray-400">{log.entityId}</td>
                  <td className="py-3.5 px-4 text-xs font-mono text-gray-400">{log.adminId}</td>
                  <td className="py-3.5 px-4 text-xs font-mono max-w-xs truncate text-gray-400">
                    {log.afterData || log.beforeData || '-'}
                  </td>
                  <td className="py-3.5 px-4 text-xs font-mono text-gray-400">
                    {new Date(log.createdAt).toLocaleString('ar-SD')}
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
