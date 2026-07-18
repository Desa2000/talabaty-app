import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/data_provider.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../data/models/store_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../core/constants/enums.dart';

class MerchantSettingsTab extends StatefulWidget {
  const MerchantSettingsTab({super.key});

  @override
  State<MerchantSettingsTab> createState() => _MerchantSettingsTabState();
}

class _MerchantSettingsTabState extends State<MerchantSettingsTab> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  bool _isInit = true;
  bool _isOpen = true;
  bool _isUpdating = false;

  late TextEditingController _nameController;
  late TextEditingController _ownerNameController;
  late TextEditingController _phoneController;
  late TextEditingController _descController;
  late TextEditingController _openTimeController;
  late TextEditingController _closeTimeController;
  late TextEditingController _prepTimeController;
  late TextEditingController _minOrderController;
  late TextEditingController _latController;
  late TextEditingController _lngController;

  File? _selectedLogoFile;

  @override
  void dispose() {
    _nameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _descController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    _prepTimeController.dispose();
    _minOrderController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _pickLogoImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (image != null) {
        setState(() {
          _selectedLogoFile = File(image.path);
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleStoreStatus(String storeId, bool newValue) async {
    setState(() => _isUpdating = true);
    try {
      await FirestoreService().updateStoreStatus(storeId, newValue ? 'active' : 'closed');
      setState(() => _isOpen = newValue);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newValue ? 'تم فتح المطعم بنجاح' : 'تم إغلاق المطعم وإيقاف استقبال الطلبات',
              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
            ),
            backgroundColor: newValue ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء تحديث حالة المطعم', style: TextStyle(fontFamily: 'Cairo')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _saveSettings(StoreModel currentStore, UserModel merchantUser) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isUpdating = true);

    try {
      final updatedStore = StoreModel(
        id: currentStore.id,
        ownerId: currentStore.ownerId,
        name: _nameController.text.trim(),
        type: currentStore.type,
        logo: _selectedLogoFile?.path ?? currentStore.logo,
        coverImage: currentStore.coverImage,
        phone: _phoneController.text.trim(),
        area: currentStore.area,
        street: currentStore.street,
        landmark: _descController.text.trim(), // Use landmark field to store description
        latitude: double.tryParse(_latController.text) ?? currentStore.latitude,
        longitude: double.tryParse(_lngController.text) ?? currentStore.longitude,
        openingTime: _openTimeController.text.trim(),
        closingTime: _closeTimeController.text.trim(),
        preparationTime: _prepTimeController.text.trim(),
        minimumOrder: double.tryParse(_minOrderController.text) ?? currentStore.minimumOrder,
        deliveryFee: currentStore.deliveryFee,
        status: _isOpen ? 'active' : 'closed',
        rating: currentStore.rating,
        ratingCount: currentStore.ratingCount,
      );

      // Save to Firestore & local cache provider
      await FirestoreService().saveStore(updatedStore);

      // Update merchant owner profile user name if changed
      if (_ownerNameController.text.trim() != merchantUser.name) {
        final updatedUser = UserModel(
          id: merchantUser.id,
          name: _ownerNameController.text.trim(),
          email: merchantUser.email,
          phone: _phoneController.text.trim(),
          password: merchantUser.password,
          role: merchantUser.role,
          createdAt: merchantUser.createdAt,
          profileImage: merchantUser.profileImage,
          fcmToken: merchantUser.fcmToken,
          savedAddresses: merchantUser.savedAddresses,
        );
        await FirestoreService().saveUser(updatedUser);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ بيانات المطعم بنجاح! ✅', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل حفظ البيانات. حاول مرة أخرى.', style: TextStyle(fontFamily: 'Cairo')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dataProvider = context.watch<DataProvider>();

    if (!auth.isAuthenticated) return const SizedBox();

    final merchantUser = auth.currentUser!;
    final merchantId = merchantUser.id;

    if (dataProvider.stores.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('إعدادات المطعم')),
        body: const Center(
          child: Text('لا يوجد مطعم مرتبط بحسابك حالياً', style: TextStyle(fontFamily: 'Cairo')),
        ),
      );
    }

    final store = dataProvider.stores.firstWhere(
      (s) => s.ownerId == merchantId,
      orElse: () => dataProvider.stores.isNotEmpty
          ? dataProvider.stores.first
          : StoreModel(
              id: 'store_$merchantId',
              ownerId: merchantId,
              name: 'مطعم جديد',
              type: StoreType.restaurant,
              phone: merchantUser.phone,
              area: '',
              street: '',
              landmark: '',
              latitude: 15.5006,
              longitude: 32.5599,
              openingTime: '08:00',
              closingTime: '23:00',
              preparationTime: '20',
              minimumOrder: 1000,
              deliveryFee: 3000,
              status: 'active',
              rating: 5.0,
              ratingCount: 1,
            ),
    );

    // Initialize controllers with current store values once on load
    if (_isInit) {
      _nameController = TextEditingController(text: store.name);
      _ownerNameController = TextEditingController(text: merchantUser.name);
      _phoneController = TextEditingController(text: store.phone.isNotEmpty ? store.phone : merchantUser.phone);
      _descController = TextEditingController(text: store.landmark ?? '');
      _openTimeController = TextEditingController(text: store.openingTime);
      _closeTimeController = TextEditingController(text: store.closingTime);
      _prepTimeController = TextEditingController(text: store.preparationTime);
      _minOrderController = TextEditingController(text: store.minimumOrder.toInt().toString());
      _latController = TextEditingController(text: store.latitude.toString());
      _lngController = TextEditingController(text: store.longitude.toString());

      _isOpen = store.status == 'active';
      _isInit = false;
    }

    final statusColor = _isOpen ? Colors.green : Colors.red;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text('إعدادات الملف والمطعم', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Store Active/Closed Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.15), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: statusColor.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isOpen ? 'المطعم مفتوح ونشط' : 'المطعم مغلق حالياً',
                            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 16, color: statusColor),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isOpen ? 'يستقبل طلبات العملاء الآن' : 'لا يظهر للعملاء ولا يستقبل طلبات',
                            style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      _isUpdating
                          ? const CircularProgressIndicator(color: AppColors.primaryColor)
                          : Switch.adaptive(
                              value: _isOpen,
                              activeColor: Colors.green,
                              onChanged: (v) => _toggleStoreStatus(store.id, v),
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Logo Picker Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickLogoImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 54,
                              backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                              backgroundImage: _selectedLogoFile != null
                                  ? FileImage(_selectedLogoFile!)
                                  : (store.logo != null && store.logo!.isNotEmpty && !store.logo!.startsWith('/')
                                      ? NetworkImage(store.logo!) as ImageProvider
                                      : null),
                              child: _selectedLogoFile == null && (store.logo == null || store.logo!.isEmpty)
                                  ? const Icon(Icons.store_rounded, size: 54, color: AppColors.primaryColor)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle),
                                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'شعار المطعم',
                        style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        'اضغط على الدائرة لتغيير الشعار',
                        style: TextStyle(fontFamily: 'Cairo', color: Colors.grey.shade400, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 3. Edit Form Section
                const Text(
                  'بيانات المطعم والمالك',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF111111)),
                ),
                const SizedBox(height: 12),

                // Form fields
                _buildTextField(controller: _nameController, label: 'اسم المطعم', icon: Icons.storefront_rounded),
                _buildTextField(controller: _ownerNameController, label: 'اسم مالك المطعم', icon: Icons.person_rounded),
                _buildTextField(controller: _phoneController, label: 'رقم الهاتف للتواصل', icon: Icons.phone_rounded, keyboardType: TextInputType.phone),
                _buildTextField(controller: _descController, label: 'وصف المطعم والوجبات', icon: Icons.description_rounded, maxLines: 2),

                Row(
                  children: [
                    Expanded(child: _buildTextField(controller: _openTimeController, label: 'وقت الفتح (مثال 08:00 AM)', icon: Icons.access_time_rounded)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(controller: _closeTimeController, label: 'وقت الإغلاق (مثال 11:00 PM)', icon: Icons.access_time_filled_rounded)),
                  ],
                ),

                Row(
                  children: [
                    Expanded(child: _buildTextField(controller: _prepTimeController, label: 'وقت التجهيز (مثال 30 دقيقة)', icon: Icons.timer_outlined)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(controller: _minOrderController, label: 'الحد الأدنى للطلب (ج.س)', icon: Icons.shopping_bag_outlined, keyboardType: TextInputType.number)),
                  ],
                ),

                const SizedBox(height: 12),
                const Text(
                  'الموقع الجغرافي للمطعم (حساب التوصيل)',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildTextField(controller: _latController, label: 'خط العرض (Latitude)', icon: Icons.map_outlined, keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(controller: _lngController, label: 'خط الطول (Longitude)', icon: Icons.map_outlined, keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                  ],
                ),

                // Read-only delivery fee policy card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryColor.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'يتم احتساب رسوم التوصيل لعملائك تلقائياً بقيمة 3,000 ج.س لكل 1 كم بناءً على موقع مطعمك الجغرافي المحدد أعلاه وموقع العميل.',
                          style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF666666), height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: _isUpdating ? null : () => _saveSettings(store, merchantUser),
                    child: _isUpdating
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            '💾 حفظ التغييرات',
                            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade200, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      await auth.logout();
                      if (mounted) context.go('/login');
                    },
                    child: Text(
                      'تسجيل الخروج ⏏',
                      style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red.shade700),
                    ),
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF888888)),
          prefixIcon: Icon(icon, color: AppColors.primaryColor),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
        style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null,
      ),
    );
  }
}
