import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/data_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/enums.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../data/models/order_model.dart';
import '../../../data/models/store_model.dart';
import '../../../core/widgets/custom_image.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final myOrders = context.select<DataProvider, List<OrderModel>>(
      (dp) => dp.getOrdersForCustomer(auth.currentUser?.id ?? '')
    );
    final stores = context.select<DataProvider, List<StoreModel>>((dp) => dp.stores);

    final activeOrders = myOrders.where((o) =>
        o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled && o.status != OrderStatus.rejectedByMerchant).toList();
    final pastOrders = myOrders.where((o) =>
        o.status == OrderStatus.delivered || o.status == OrderStatus.cancelled || o.status == OrderStatus.rejectedByMerchant).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'طلباتي', 
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            fontFamily: GoogleFonts.cairo().fontFamily,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: GoogleFonts.cairo().fontFamily,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                fontFamily: GoogleFonts.cairo().fontFamily,
              ),
              tabs: [
                Tab(text: 'نشطة (${activeOrders.length})'),
                Tab(text: 'السابقة (${pastOrders.length})'),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          physics: const BouncingScrollPhysics(),
          children: [
            _buildOrdersList(context, stores, activeOrders, isActive: true),
            _buildOrdersList(context, stores, pastOrders, isActive: false),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, List<StoreModel> stores, List<OrderModel> orders, {required bool isActive}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.primaryColor.withValues(alpha: 0.1), blurRadius: 40)
                ]
              ),
              child: Icon(isActive ? Icons.receipt_long_rounded : Icons.history_rounded, size: 80, color: AppColors.primaryColor.withValues(alpha: 0.8)),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 32),
            Text(
              isActive ? 'لا توجد طلبات نشطة حالياً' : 'لا توجد طلبات سابقة',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontFamily: GoogleFonts.cairo().fontFamily,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isActive ? 'اطلب الآن وتتبع طلبك هنا' : 'سجل طلباتك سيظهر هنا',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                fontFamily: GoogleFonts.cairo().fontFamily,
              ),
            ),
            const SizedBox(height: 32),
            if (isActive)
              ElevatedButton(
                onPressed: () => context.go('/customer/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  'تصفح المطاعم والمتاجر',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: GoogleFonts.cairo().fontFamily,
                  ),
                ),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
          ],
        ),
      ).animate().fade();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final store = stores.firstWhere(
          (s) => s.id == order.storeId,
          orElse: () => stores.isNotEmpty ? stores.first : StoreModel(id: 'dummy', ownerId: '', name: 'متجر غير معروف', type: StoreType.restaurant, phone: '', area: '', street: '', landmark: '', latitude: 0, longitude: 0, openingTime: '', closingTime: '', preparationTime: '', minimumOrder: 0, deliveryFee: 0, status: '', rating: 0, ratingCount: 0),
        );
        final dateStr = DateFormat('dd/MM/yyyy hh:mm a').format(order.createdAt);

        Color statusColor = Colors.grey;
        Color statusBgColor = Colors.grey.shade100;
        String statusText = order.status.name;
        IconData statusIcon = Icons.info_outline_rounded;
        
        switch (order.status) {
          case OrderStatus.pending:
            statusColor = const Color(0xFFF57C00);
            statusBgColor = const Color(0xFFFFF3E0);
            statusText = 'قيد المراجعة';
            statusIcon = Icons.hourglass_empty_rounded;
            break;
          case OrderStatus.acceptedByMerchant:
          case OrderStatus.preparing:
            statusColor = const Color(0xFF1976D2);
            statusBgColor = const Color(0xFFE3F2FD);
            statusText = 'جاري التحضير';
            statusIcon = Icons.restaurant_menu_rounded;
            break;
          case OrderStatus.readyForPickup:
          case OrderStatus.searchingCourier:
          case OrderStatus.assignedToCourier:
            statusColor = const Color(0xFF7B1FA2);
            statusBgColor = const Color(0xFFF3E5F5);
            statusText = 'بانتظار المندوب';
            statusIcon = Icons.delivery_dining_rounded;
            break;
          case OrderStatus.courierGoingToStore:
          case OrderStatus.courierArrivedStore:
          case OrderStatus.pickedUp:
          case OrderStatus.onTheWay:
          case OrderStatus.courierArrivedCustomer:
            statusColor = const Color(0xFF0097A7);
            statusBgColor = const Color(0xFFE0F7FA);
            statusText = 'في الطريق';
            statusIcon = Icons.directions_bike_rounded;
            break;
          case OrderStatus.delivered:
            statusColor = const Color(0xFF388E3C);
            statusBgColor = const Color(0xFFE8F5E9);
            statusText = 'تم التوصيل';
            statusIcon = Icons.check_circle_rounded;
            break;
          case OrderStatus.rejectedByMerchant:
          case OrderStatus.cancelled:
            statusColor = const Color(0xFFD32F2F);
            statusBgColor = const Color(0xFFFFEBEE);
            statusText = 'ملغي';
            statusIcon = Icons.cancel_rounded;
            break;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => context.push('/customer/order-tracking/${order.id}'),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade100, width: 2),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))
                            ]
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: CustomImage(imagePath: store.logo ?? ''),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                store.name,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: GoogleFonts.cairo().fontFamily,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.calendar_month_rounded, size: 14, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Text(
                                    dateStr,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                      fontFamily: GoogleFonts.cairo().fontFamily,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'رقم الطلب',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '#${order.id.substring(0, 8)}',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: GoogleFonts.cairo().fontFamily,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'المبلغ الإجمالي',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${order.totalAmount.toInt()} ج.س',
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  fontFamily: GoogleFonts.cairo().fontFamily,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, color: statusColor, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  fontFamily: GoogleFonts.cairo().fontFamily,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              'التفاصيل',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily: GoogleFonts.cairo().fontFamily,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textPrimary),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fade(delay: (50 * index).ms).slideX(begin: 0.1, duration: 400.ms, curve: Curves.easeOutQuad);
      },
    );
  }
}
