import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/enums.dart';
import '../../../core/providers/data_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/order_model.dart';
import '../widgets/order_details_panel.dart';

class MerchantOrdersScreen extends StatefulWidget {
  const MerchantOrdersScreen({super.key});

  @override
  State<MerchantOrdersScreen> createState() => _MerchantOrdersScreenState();
}

class _MerchantOrdersScreenState extends State<MerchantOrdersScreen> with SingleTickerProviderStateMixin {
  OrderModel? _selectedOrder;
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

  List<OrderModel> _filterOrders(List<OrderModel> orders, int tabIndex) {
    switch (tabIndex) {
      case 0: // New Orders
        return orders.where((o) => o.status == OrderStatus.pending || o.status == OrderStatus.acceptedByMerchant).toList();
      case 1: // Preparing
        return orders.where((o) => o.status == OrderStatus.preparing).toList();
      case 2: // Ready / Out for Delivery
        return orders.where((o) => 
          o.status == OrderStatus.readyForPickup ||
          o.status == OrderStatus.searchingCourier ||
          o.status == OrderStatus.assignedToCourier ||
          o.status == OrderStatus.courierGoingToStore ||
          o.status == OrderStatus.courierArrivedStore ||
          o.status == OrderStatus.pickedUp ||
          o.status == OrderStatus.onTheWay
        ).toList();
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<DataProvider>();
    final auth = context.read<AuthProvider>();
    
    // Get all orders for this merchant, sorted by newest first
    final allOrders = dataProvider.getOrdersForMerchant(auth.currentUser?.id ?? 'none');
    allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('إدارة الطلبات'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryColor,
          onTap: (_) => setState(() => _selectedOrder = null),
          tabs: const [
            Tab(text: 'طلبات جديدة'),
            Tab(text: 'قيد التجهيز'),
            Tab(text: 'جاهزة/في الطريق'),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth > 600;
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildResponsiveLayout(isTablet, _filterOrders(allOrders, 0)),
              _buildResponsiveLayout(isTablet, _filterOrders(allOrders, 1)),
              _buildResponsiveLayout(isTablet, _filterOrders(allOrders, 2)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResponsiveLayout(bool isTablet, List<OrderModel> currentOrders) {
    if (isTablet) {
      return Row(
        children: [
          // Left side: Order List (35% width)
          SizedBox(
            width: 350,
            child: _buildOrdersList(currentOrders, isTablet),
          ),
          const VerticalDivider(width: 1, thickness: 1, color: AppColors.borderGray),
          // Right side: Order Details (65% width)
          Expanded(
            child: _selectedOrder == null 
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 80, color: AppColors.borderGray),
                      SizedBox(height: 16),
                      Text('اختر طلباً لعرض تفاصيله', style: TextStyle(color: AppColors.textSecondary, fontSize: 18)),
                    ],
                  ),
                )
              : OrderDetailsPanel(order: _selectedOrder!),
          ),
        ],
      );
    } else {
      // Mobile Layout: Just the list. Clicking opens a modal or navigates.
      return _buildOrdersList(currentOrders, isTablet);
    }
  }

  Widget _buildOrdersList(List<OrderModel> orders, bool isTablet) {
    if (orders.isEmpty) {
      return const Center(child: Text('لا توجد طلبات في هذا القسم'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final isSelected = _selectedOrder?.id == order.id;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isSelected ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isSelected ? AppColors.primaryColor : Colors.transparent, width: 2),
          ),
          child: InkWell(
            onTap: () {
              if (isTablet) {
                setState(() => _selectedOrder = order);
              } else {
                // On mobile, show modal bottom sheet
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.85,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: OrderDetailsPanel(order: order),
                    ),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('#${order.id.length >= 8 ? order.id.substring(0, 8) : order.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${order.createdAt.hour}:${order.createdAt.minute.toString().padLeft(2, '0')}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  StatusChip(status: order.status),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${order.items.length} عناصر', style: const TextStyle(color: AppColors.textSecondary)),
                      Text('${order.total} ج.س', style: const TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
