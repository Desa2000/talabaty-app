'use client';

import React, { useEffect, useState } from 'react';
import { adminFetch } from '@/lib/admin-api';
import {
  ShoppingBag,
  Search,
  Filter,
  RefreshCw,
  UserCheck,
  XCircle,
  Clock,
  Eye,
  MapPin,
  Phone,
  Store,
  User,
  Bike,
  CreditCard,
  FileText,
} from 'lucide-react';

export default function AdminOrdersPage() {
  const [orders, setOrders] = useState<any[]>([]);
  const [pagination, setPagination] = useState<any>({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Filters state
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('ALL');
  const [categoryFilter, setCategoryFilter] = useState('ALL');
  const [paymentFilter, setPaymentFilter] = useState('ALL');
  const [page, setPage] = useState(1);

  // Modal / Drawer state
  const [selectedOrder, setSelectedOrder] = useState<any | null>(null);
  const [reassignModalOpen, setReassignModalOpen] = useState(false);
  const [availableCouriers, setAvailableCouriers] = useState<any[]>([]);
  const [selectedCourierId, setSelectedCourierId] = useState('');
  const [reassignReason, setReassignReason] = useState('');
  const [actionLoading, setActionLoading] = useState(false);

  const fetchOrders = async () => {
    setLoading(true);
    setError(null);
    try {
      const query = new URLSearchParams({
        page: page.toString(),
        limit: '20',
        status: statusFilter,
        category: categoryFilter,
        paymentMethod: paymentFilter,
        q: search,
      });

      const res = await adminFetch(`/admin/orders?${query.toString()}`);
      setOrders(res.orders || []);
      setPagination(res.pagination || {});
    } catch (err: any) {
      setError(err.message || 'فشل جلب الطلبات');
    } fontally: {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchOrders();
  }, [page, statusFilter, categoryFilter, paymentFilter]);

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setPage(1);
    fetchOrders();
  };

  const openOrderDetail = async (orderId: string) => {
    try {
      const res = await adminFetch(`/admin/orders/${orderId}`);
      setSelectedOrder(res);
    } catch (err: any) {
      alert('فشل جلب تفاصيل الطلب');
    }
  };

  const openReassignModal = async (order: any) => {
    setSelectedOrder(order);
    setSelectedCourierId('');
    setReassignReason('');
    setReassignModalOpen(true);

    try {
      const res = await adminFetch('/admin/couriers?verificationStatus=APPROVED');
      setAvailableCouriers(res.couriers || []);
    } catch (err) {
      console.error(err);
    }
  };

  const handleReassignCourier = async () => {
    if (!selectedOrder || !selectedCourierId) {
      alert('يرجى اختيار المندوب المراد تعيينه');
      return;
    }

    setActionLoading(true);
    try {
      await adminFetch(`/admin/orders/${selectedOrder.id}/reassign-courier`, {
        method: 'POST',
        body: JSON.stringify({
          courierId: selectedCourierId,
          reason: reassignReason,
        }),
      });

      alert('تم إعادة تعيين المندوب بنجاح!');
      setReassignModalOpen(false);
      fetchOrders();
      if (selectedOrder) openOrderDetail(selectedOrder.id);
    } catch (err: any) {
      alert(err.message || 'فشل إعادة التعيين');
    } finally {
      setActionLoading(false);
    }
  };

  const handleCancelOrder = async (orderId: string) => {
    const reason = prompt('يرجى كتابة سبب إداري لإلغاء الطلب:');
    if (reason === null) return;

    try {
      await adminFetch(`/admin/orders/${orderId}/cancel`, {
        method: 'POST',
        body: JSON.stringify({ reason }),
      });
      alert('تم إلغاء الطلب بنجاح');
      fetchOrders();
      if (selectedOrder?.id === orderId) openOrderDetail(orderId);
    } catch (err: any) {
      alert(err.message || 'فشل إلغاء الطلب');
    }
  };

  return (
    <div className="space-y-6 dir-rtl" dir="rtl">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-white flex items-center gap-2">
            إدارة الطلبات الحية <ShoppingBag className="w-6 h-6 text-[#FF5722]" />
          </h1>
          <p className="text-xs text-gray-400 mt-1">متابعة دقيقة لكل الحالات وإعادة التعيين والتاريخ الكامل للعمليات</p>
        </div>

        <button
          onClick={fetchOrders}
          className="flex items-center gap-2 bg-[#16191D] hover:bg-gray-800 text-white text-xs font-semibold px-4 py-2.5 rounded-xl border border-gray-800 transition-colors cursor-pointer"
        >
          <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
          <span>تحديث الطلبات</span>
        </button>
      </div>

      {/* Filters Bar */}
      <div className="bg-[#16191D] p-4 rounded-2xl border border-gray-800/80 space-y-4">
        <form onSubmit={handleSearchSubmit} className="flex flex-col md:flex-row gap-3">
          <div className="relative flex-1">
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="بحث برقم الطلب، اسم العميل، التاجر، رقم الهاتف..."
              className="w-full bg-[#0F1114] border border-gray-800 rounded-xl px-4 py-2.5 pr-10 text-xs text-white placeholder-gray-500 focus:outline-none focus:border-[#FF5722]"
            />
            <Search className="w-4 h-4 text-gray-500 absolute right-3.5 top-3" />
          </div>

          <button
            type="submit"
            className="bg-[#FF5722] hover:bg-orange-600 text-white text-xs font-bold px-5 py-2.5 rounded-xl transition-colors cursor-pointer"
          >
            بحث
          </button>
        </form>

        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
          {/* Status Filter */}
          <div>
            <label className="block text-[11px] font-semibold text-gray-400 mb-1">حالة الطلب</label>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="w-full bg-[#0F1114] border border-gray-800 rounded-xl px-3 py-2 text-xs text-white focus:outline-none focus:border-[#FF5722]"
            >
              <option value="ALL">جميع الحالات</option>
              <option value="PENDING_MERCHANT">بانتظار قبول التاجر</option>
              <option value="MERCHANT_ACCEPTED">تم قبول التاجر</option>
              <option value="PREPARING">جاري التجهيز</option>
              <option value="SEARCHING_COURIER">جاري البحث عن مندوب</option>
              <option value="COURIER_ACCEPTED">تم قبول المندوب</option>
              <option value="PICKED_UP">تم استلام الشحنة</option>
              <option value="ON_THE_WAY">في الطريق للعميل</option>
              <option value="ARRIVED">وصل المندوب</option>
              <option value="COMPLETED">مكتمل</option>
              <option value="CUSTOMER_CANCELLED">ملغي من العميل</option>
              <option value="MERCHANT_REJECTED">مرفوض من التاجر</option>
            </select>
          </div>

          {/* Category Filter */}
          <div>
            <label className="block text-[11px] font-semibold text-gray-400 mb-1">نوع النشاط</label>
            <select
              value={categoryFilter}
              onChange={(e) => setCategoryFilter(e.target.value)}
              className="w-full bg-[#0F1114] border border-gray-800 rounded-xl px-3 py-2 text-xs text-white focus:outline-none focus:border-[#FF5722]"
            >
              <option value="ALL">جميع الأنشطة</option>
              <option value="RESTAURANT">مطعم</option>
              <option value="SUPERMARKET">سوبرماركت</option>
              <option value="PHARMACY">صيدلية</option>
            </select>
          </div>

          {/* Payment Method Filter */}
          <div>
            <label className="block text-[11px] font-semibold text-gray-400 mb-1">طريقة الدفع</label>
            <select
              value={paymentFilter}
              onChange={(e) => setPaymentFilter(e.target.value)}
              className="w-full bg-[#0F1114] border border-gray-800 rounded-xl px-3 py-2 text-xs text-white focus:outline-none focus:border-[#FF5722]"
            >
              <option value="ALL">جميع الطرق</option>
              <option value="CASH">نقداً (كاش)</option>
              <option value="BANKAK">بنكك</option>
            </select>
          </div>
        </div>
      </div>

      {error && (
        <div className="p-4 rounded-xl bg-red-500/10 border border-red-500/20 text-red-400 text-sm font-medium">
          {error}
        </div>
      )}

      {/* Orders Table */}
      <div className="bg-[#16191D] rounded-2xl border border-gray-800/80 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-right text-sm text-gray-300">
            <thead className="bg-[#0F1114] text-xs text-gray-400 uppercase border-b border-gray-800">
              <tr>
                <th className="py-3.5 px-4">رقم الطلب</th>
                <th className="py-3.5 px-4">العميل</th>
                <th className="py-3.5 px-4">المتجر</th>
                <th className="py-3.5 px-4">المندوب</th>
                <th className="py-3.5 px-4">الحالة الحالية</th>
                <th className="py-3.5 px-4">الدفع</th>
                <th className="py-3.5 px-4">الإجمالي</th>
                <th className="py-3.5 px-4 text-center">إجراءات</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-800/60">
              {orders.map((order) => (
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
                      <span className="text-amber-400 text-xs font-semibold">بانتظار مندوب</span>
                    )}
                  </td>
                  <td className="py-3.5 px-4">
                    <span className="px-2.5 py-1 rounded-full text-xs font-bold bg-[#FF5722]/10 text-[#FF5722] border border-[#FF5722]/20">
                      {order.status}
                    </span>
                  </td>
                  <td className="py-3.5 px-4 text-xs font-medium">
                    {order.paymentMethod === 'BANKAK' ? (
                      <span className="text-purple-400 bg-purple-500/10 px-2 py-0.5 rounded border border-purple-500/20">
                        بنكك ({order.paymentStatus})
                      </span>
                    ) : (
                      <span className="text-emerald-400 bg-emerald-500/10 px-2 py-0.5 rounded border border-emerald-500/20">
                        كاش
                      </span>
                    )}
                  </td>
                  <td className="py-3.5 px-4 font-bold text-white">{order.total} ج.س</td>
                  <td className="py-3.5 px-4">
                    <div className="flex items-center justify-center gap-2">
                      <button
                        onClick={() => openOrderDetail(order.id)}
                        className="p-1.5 rounded-lg bg-gray-800 hover:bg-gray-700 text-white transition-colors cursor-pointer"
                        title="عرض التفاصيل والخط الزمني"
                      >
                        <Eye className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => openReassignModal(order)}
                        className="p-1.5 rounded-lg bg-amber-500/10 hover:bg-amber-500/20 text-amber-400 border border-amber-500/20 transition-colors cursor-pointer"
                        title="إعادة تعيين المندوب"
                      >
                        <UserCheck className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => handleCancelOrder(order.id)}
                        className="p-1.5 rounded-lg bg-red-500/10 hover:bg-red-500/20 text-red-400 border border-red-500/20 transition-colors cursor-pointer"
                        title="إلغاء الطلب"
                      >
                        <XCircle className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Order Details Modal */}
      {selectedOrder && !reassignModalOpen && (
        <div className="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-[#16191D] border border-gray-800 rounded-3xl w-full max-w-3xl max-h-[90vh] overflow-y-auto p-6 space-y-6">
            <div className="flex items-center justify-between border-b border-gray-800 pb-4">
              <div>
                <h3 className="text-xl font-bold text-white flex items-center gap-2">
                  تفاصيل الطلب: <span className="text-[#FF5722] font-mono">{selectedOrder.orderNumber}</span>
                </h3>
                <p className="text-xs text-gray-400 mt-0.5">سجل التغييرات الكامل والمعلومات التشغيلية</p>
              </div>
              <button
                onClick={() => setSelectedOrder(null)}
                className="text-gray-400 hover:text-white text-sm font-bold bg-gray-800 p-2 rounded-xl"
              >
                إغلاق ✕
              </button>
            </div>

            {/* FULL ORDER TIMELINE */}
            <div>
              <h4 className="text-sm font-bold text-white mb-3 flex items-center gap-2">
                <Clock className="w-4 h-4 text-[#FF5722]" /> الخط الزمني الحقيقي (OrderStatusHistory)
              </h4>
              <div className="space-y-3 bg-[#0F1114] p-4 rounded-2xl border border-gray-800">
                {selectedOrder.statusHistory?.map((h: any, idx: number) => (
                  <div key={idx} className="flex items-start gap-3 text-xs border-r-2 border-[#FF5722] pr-3">
                    <div className="flex-1">
                      <div className="font-bold text-white">
                        {h.toStatus} &bull; <span className="text-gray-400">{h.actorType} ({h.actorId})</span>
                      </div>
                      {h.note && <div className="text-gray-400 mt-0.5">{h.note}</div>}
                    </div>
                    <div className="text-[10px] text-gray-500 font-mono">
                      {new Date(h.timestamp).toLocaleString('ar-SD')}
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Items Summary */}
            <div>
              <h4 className="text-sm font-bold text-white mb-3">عناصر الطلب ({selectedOrder.items?.length || 0})</h4>
              <div className="space-y-2">
                {selectedOrder.items?.map((item: any) => (
                  <div key={item.id} className="flex justify-between items-center bg-[#0F1114] p-3 rounded-xl text-xs">
                    <span className="text-white font-medium">{item.productName} × {item.quantity}</span>
                    <span className="text-gray-300 font-bold">{item.subtotal} ج.س</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Financial breakdown */}
            <div className="bg-[#0F1114] p-4 rounded-2xl border border-gray-800 text-xs space-y-2">
              <div className="flex justify-between text-gray-400">
                <span>المجموع الفرعي:</span> <span>{selectedOrder.subtotal} ج.س</span>
              </div>
              <div className="flex justify-between text-gray-400">
                <span>رسوم التوصيل:</span> <span>{selectedOrder.deliveryFee} ج.س</span>
              </div>
              <div className="flex justify-between text-white font-bold text-sm pt-2 border-t border-gray-800">
                <span>الإجمالي الكلي:</span> <span className="text-[#FF5722]">{selectedOrder.total} ج.س</span>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Courier Reassignment Modal */}
      {reassignModalOpen && selectedOrder && (
        <div className="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-[#16191D] border border-gray-800 rounded-3xl w-full max-w-md p-6 space-y-5">
            <h3 className="text-lg font-bold text-white">إعادة تعيين المندوب للطلب {selectedOrder.orderNumber}</h3>

            <div>
              <label className="block text-xs font-semibold text-gray-300 mb-2">اختر المندوب المتاح</label>
              <select
                value={selectedCourierId}
                onChange={(e) => setSelectedCourierId(e.target.value)}
                className="w-full bg-[#0F1114] border border-gray-800 rounded-xl p-3 text-xs text-white focus:outline-none focus:border-[#FF5722]"
              >
                <option value="">-- اختر مندوباً --</option>
                {availableCouriers.map((c) => (
                  <option key={c.id} value={c.userId}>
                    {c.user?.name} ({c.vehicleType}) - {c.status}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-xs font-semibold text-gray-300 mb-2">سبب إعادة التعيين</label>
              <input
                type="text"
                value={reassignReason}
                onChange={(e) => setReassignReason(e.target.value)}
                placeholder="مثال: المندوب السابق واجه عطلاً فأنياً"
                className="w-full bg-[#0F1114] border border-gray-800 rounded-xl p-3 text-xs text-white focus:outline-none focus:border-[#FF5722]"
              />
            </div>

            <div className="flex items-center gap-3 pt-2">
              <button
                onClick={handleReassignCourier}
                disabled={actionLoading}
                className="flex-1 bg-[#FF5722] hover:bg-orange-600 text-white font-bold py-2.5 rounded-xl text-xs transition-colors cursor-pointer"
              >
                تأكيد التعيين
              </button>
              <button
                onClick={() => setReassignModalOpen(false)}
                className="px-4 py-2.5 bg-gray-800 hover:bg-gray-700 text-gray-300 text-xs font-semibold rounded-xl"
              >
                إلغاء
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
