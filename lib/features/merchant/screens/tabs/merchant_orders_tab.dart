import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/providers/data_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/user_model.dart';
import 'package:intl/intl.dart';

class MerchantOrdersTab extends StatefulWidget {
  const MerchantOrdersTab({super.key});

  @override
  State<MerchantOrdersTab> createState() => _MerchantOrdersTabState();
}

class _MerchantOrdersTabState extends State<MerchantOrdersTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isAuthenticated) return const SizedBox();
    
    final dataProvider = context.watch<DataProvider>();
    
    // Fallback to 's1' if no merchant profile
    final merchantId = auth.currentUser?.id ?? 's1'; 
    List<OrderModel> orders = dataProvider.getOrdersForMerchant(merchantId);

    // Mock orders if empty for testing
    if (orders.isEmpty) {
      orders = [
        OrderModel(
          id: 'ord1',
          customerId: 'c1',
          storeId: 's1',
          items: [],
          subtotal: 4500,
          deliveryFee: 0,
          serviceFee: 0,
          total: 4500,
          status: OrderStatus.pending,
          createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
          address: AddressModel(id: 'mock', title: 'mock', city: '', area: '', street: 'بحري - الحلفايا', landmark: '', latitude: 15.6, longitude: 32.5, phone: ''),
          customerLat: 15.6,
          customerLng: 32.5,
          storeLat: 15.6,
          storeLng: 32.5,
          paymentMethod: PaymentMethod.cashOnDelivery,
          paymentStatus: PaymentStatus.unpaid,
        ),
        OrderModel(
          id: 'ord2',
          customerId: 'c2',
          storeId: 's1',
          items: [],
          subtotal: 12000,
          deliveryFee: 0,
          serviceFee: 0,
          total: 12000,
          status: OrderStatus.preparing,
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
          address: AddressModel(id: 'mock', title: 'mock', city: '', area: '', street: 'الخرطوم - الرياض', landmark: '', latitude: 15.58, longitude: 32.55, phone: ''),
          customerLat: 15.58,
          customerLng: 32.55,
          storeLat: 15.6,
          storeLng: 32.5,
          paymentMethod: PaymentMethod.cashOnDelivery,
          paymentStatus: PaymentStatus.unpaid,
        ),
      ];
    }

    final newOrders = orders.where((o) => o.status == OrderStatus.pending).toList();
    final preparingOrders = orders.where((o) => o.status == OrderStatus.preparing).toList();
    final readyOrders = orders.where((o) => o.status == OrderStatus.readyForPickup || o.status == OrderStatus.onTheWay || o.status == OrderStatus.delivered).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('إدارة الطلبات الحية'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryColor,
          tabs: [
            Tab(text: 'جديد (${newOrders.length})'),
            Tab(text: 'قيد التحضير (${preparingOrders.length})'),
            Tab(text: 'جاهز/مكتمل (${readyOrders.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(newOrders, context, dataProvider, isNew: true),
          _buildOrdersList(preparingOrders, context, dataProvider, isPreparing: true),
          _buildOrdersList(readyOrders, context, dataProvider),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<OrderModel> orders, BuildContext context, DataProvider dataProvider, {bool isNew = false, bool isPreparing = false}) {
    if (orders.isEmpty) {
      return const Center(child: Text('لا توجد طلبات في هذه الخانة', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final timeFormat = DateFormat('hh:mm a');
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
            border: isNew ? Border.all(color: Colors.orange, width: 2) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isNew ? Colors.orange.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('طلب #${order.id.length >= 4 ? order.id.substring(0, 4).toUpperCase() : order.id.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(timeFormat.format(order.createdAt), style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              // Body
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('المبلغ الإجمالي:', style: TextStyle(color: AppColors.textSecondary)),
                        Text('${order.total} ج.س', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryColor)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('العنوان:', style: TextStyle(color: AppColors.textSecondary)),
                        Text(order.address.street, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 32),
                    
                    // Action Buttons
                    if (isNew)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                minimumSize: const Size(0, 48),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                dataProvider.updateOrderStatus(order.id, OrderStatus.preparing, 'تم قبول الطلب وجاري التحضير');
                              },
                              child: const Text('قبول وبدء التحضير', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              minimumSize: const Size(0, 48),
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('تأكيد رفض الطلب', style: TextStyle(fontWeight: FontWeight.bold)),
                                  content: const Text('هل أنت متأكد من رفض هذا الطلب؟ سيتم إلغاؤه نهائياً.'),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        dataProvider.updateOrderStatus(order.id, OrderStatus.cancelled, 'تم رفض الطلب من قِبل المطعم');
                                      },
                                      child: const Text('نعم، رفض الطلب', style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text('رفض'),
                          ),
                        ],
                      )
                    else if (isPreparing)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            dataProvider.updateOrderStatus(order.id, OrderStatus.readyForPickup, 'الطلب جاهز للتسليم للسائق');
                          },
                          icon: const Icon(Icons.check_circle),
                          label: const Text('الطلب جاهز للتسليم للسائق', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text('جاهز / تم التسليم', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
