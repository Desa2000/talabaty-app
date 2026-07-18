import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/data_provider.dart';
import '../../../../data/models/user_model.dart';

class CourierEarningsTab extends StatefulWidget {
  const CourierEarningsTab({super.key});

  @override
  State<CourierEarningsTab> createState() => _CourierEarningsTabState();
}

class _CourierEarningsTabState extends State<CourierEarningsTab> {
  double _walletBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadWalletBalance();
  }

  Future<void> _loadWalletBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final auth = context.read<AuthProvider>();
    final balance = prefs.getDouble('wallet_${auth.currentUser?.id}') ?? 0;
    if (mounted) setState(() => _walletBalance = balance);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dataProvider = context.watch<DataProvider>();
    final courierId = auth.currentUser?.id ?? '';
    final courier = dataProvider.couriers.firstWhere(
      (c) => c.userId == courierId,
      orElse: () => dataProvider.couriers.isNotEmpty
          ? dataProvider.couriers.first
          : CourierProfile(
              userId: courierId,
              nationalId: '123',
              dateOfBirth: '1995-01-01',
              emergencyPhone: '123',
              vehicleType: VehicleType.motorcycle,
            ),
    );

    final completedOrders = dataProvider
        .getOrdersForCourier(courier.userId)
        .where((o) => o.status == OrderStatus.delivered)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final now = DateTime.now();
    final todayEarnings = completedOrders
        .where((o) =>
            o.createdAt.year == now.year &&
            o.createdAt.month == now.month &&
            o.createdAt.day == now.day)
        .fold<double>(0, (sum, o) => sum + o.deliveryFee);

    final totalEarnings =
        completedOrders.fold<double>(0, (sum, o) => sum + o.deliveryFee);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: _loadWalletBalance,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ===== WALLET BALANCE CARD =====
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A1D27), Color(0xFF252A40)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('رصيد المحفظة', style: TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Cairo')),
                              Text('متاح للسحب', style: TextStyle(color: Colors.white38, fontSize: 12, fontFamily: 'Cairo')),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${_walletBalance.toStringAsFixed(0)} ج.س',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          onPressed: _walletBalance > 0
                              ? () => _showWithdrawDialog(context)
                              : null,
                          icon: const Icon(Icons.upload_rounded, color: Colors.white),
                          label: const Text(
                            'سحب الرصيد',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ===== STATS ROW =====
                Row(
                  children: [
                    Expanded(
                      child: _buildStatBox(
                        icon: Icons.today_rounded,
                        color: AppColors.primaryColor,
                        label: 'أرباح اليوم',
                        value: '${todayEarnings.toStringAsFixed(0)} ج.س',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatBox(
                        icon: Icons.bar_chart_rounded,
                        color: Colors.blue,
                        label: 'إجمالي الأرباح',
                        value: '${totalEarnings.toStringAsFixed(0)} ج.س',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatBox(
                        icon: Icons.delivery_dining_rounded,
                        color: Colors.green,
                        label: 'الرحلات',
                        value: '${completedOrders.length}',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ===== TRANSACTIONS =====
                const Text(
                  'آخر العمليات',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 12),

                if (completedOrders.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 48, color: Color(0xFFCCCCCC)),
                          SizedBox(height: 12),
                          Text('لا توجد عمليات بعد', style: TextStyle(fontFamily: 'Cairo', color: Color(0xFF888888))),
                        ],
                      ),
                    ),
                  )
                else
                  ...completedOrders.take(20).map((order) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.add_circle_outline_rounded, color: Colors.green),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'رسوم توصيل — طلب ${order.id.substring(0, 8).toUpperCase()}',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Color(0xFF111111),
                                  ),
                                ),
                                Text(
                                  _formatDate(order.createdAt),
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    color: Color(0xFF888888),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '+ ${order.deliveryFee.toStringAsFixed(0)} ج.س',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 16, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF888888), fontSize: 11)),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context) {
    final nameController = TextEditingController();
    final accountController = TextEditingController();
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '💳 سحب الرصيد',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  'الرصيد المتاح: ${_walletBalance.toStringAsFixed(0)} ج.س',
                  style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF888888), fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Amount
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'المبلغ المراد سحبه (ج.س)',
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    prefixIcon: const Icon(Icons.attach_money_rounded, color: AppColors.primaryColor),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'أدخل المبلغ';
                    final amount = double.tryParse(v) ?? 0;
                    if (amount <= 0) return 'المبلغ يجب أن يكون أكبر من صفر';
                    if (amount > _walletBalance) return 'المبلغ أكبر من رصيدك المتاح';
                    if (amount < 5000) return 'الحد الأدنى للسحب 5,000 ج.س';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Name
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'الاسم الكامل (كما في البنك)',
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primaryColor),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'أدخل اسمك الكامل' : null,
                ),
                const SizedBox(height: 16),

                // Account number
                TextFormField(
                  controller: accountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'رقم الحساب — بنك الخرطوم',
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    prefixIcon: const Icon(Icons.account_balance_rounded, color: AppColors.primaryColor),
                    helperText: 'رقم حسابك في بنك الخرطوم',
                    helperStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'أدخل رقم الحساب';
                    if (v.length < 8) return 'رقم الحساب يجب أن يكون على الأقل 8 أرقام';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      Navigator.pop(ctx);
                      await _submitWithdrawal(
                        double.parse(amountController.text),
                        nameController.text.trim(),
                        accountController.text.trim(),
                      );
                    },
                    child: const Text(
                      'إرسال طلب السحب',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitWithdrawal(double amount, String name, String account) async {
    if (!mounted) return;

    // Save withdrawal request to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final auth = context.read<AuthProvider>();
    final walletKey = 'wallet_${auth.currentUser?.id}';
    
    // Deduct from wallet
    final newBalance = _walletBalance - amount;
    await prefs.setDouble(walletKey, newBalance);

    // Save withdrawal request record
    final requests = prefs.getStringList('withdrawal_requests') ?? [];
    requests.add('${auth.currentUser?.name}|$amount|$name|$account|${DateTime.now().toIso8601String()}|pending');
    await prefs.setStringList('withdrawal_requests', requests);

    if (mounted) {
      setState(() => _walletBalance = newBalance);
      _showSuccessSheet(amount, name, account);
    }
  }

  void _showSuccessSheet(double amount, String name, String account) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 48),
              ),
              const SizedBox(height: 20),
              const Text(
                'تم إرسال طلب السحب! ✅',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 22),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'سيتم مراجعة طلبك من فريق المحاسبة وتحويل\n${amount.toStringAsFixed(0)} ج.س إلى حسابك خلال 24 ساعة',
                style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF666666), fontSize: 14, height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('المبلغ', '${amount.toStringAsFixed(0)} ج.س'),
                    const Divider(height: 20),
                    _buildInfoRow('الاسم', name),
                    const Divider(height: 20),
                    _buildInfoRow('رقم الحساب', account),
                    const Divider(height: 20),
                    _buildInfoRow('البنك', 'بنك الخرطوم'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('حسناً', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF888888), fontSize: 14)),
        Text(value, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
