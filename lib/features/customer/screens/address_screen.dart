import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/address_provider.dart';
import '../../../data/models/user_model.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final addressProvider = context.watch<AddressProvider>();
    final addresses = addressProvider.addresses;
    final selectedId = addressProvider.selectedAddressId;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // 1. The Map Background
          Positioned.fill(
            bottom: MediaQuery.of(context).size.height * 0.45,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: addressProvider.selectedAddress != null 
                    ? LatLng(addressProvider.selectedAddress!.latitude, addressProvider.selectedAddress!.longitude)
                    : const LatLng(15.5007, 32.5599),
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                  userAgentPackageName: 'com.example.talabaty_app',
                ),
                if (addressProvider.selectedAddress != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(addressProvider.selectedAddress!.latitude, addressProvider.selectedAddress!.longitude),
                        width: 60,
                        height: 60,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(color: AppColors.primaryColor.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))
                                ]
                              ),
                              child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 24),
                            ),
                          ],
                        ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                         .moveY(begin: 0, end: -8, duration: 800.ms, curve: Curves.easeInOut),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // 2. Custom App Bar over map
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                bottom: 16,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.black.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  Text(
                    'اختر موقعك',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      fontFamily: GoogleFonts.cairo().fontFamily,
                      shadows: [Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4)],
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.share_rounded, color: Colors.black87, size: 20),
                      onPressed: () {
                        final selected = addressProvider.selectedAddress;
                        if (selected != null) {
                          Clipboard.setData(ClipboardData(text: '${selected.title}: ${selected.area}، ${selected.street}'));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ العنوان إلى الحافظة!')));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء اختيار عنوان أولاً')));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Search Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'ابحث عن منطقة أو عنوان...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontFamily: GoogleFonts.cairo().fontFamily),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryColor),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune_rounded, color: Colors.black87),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ).animate().fade(duration: 400.ms).slideY(begin: -0.2),
          ),

          // 4. Bottom Sheet Container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 30, offset: const Offset(0, -10))
                ],
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 20),
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'المواقع المحفوظة',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            fontFamily: GoogleFonts.cairo().fontFamily,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: addresses.length >= 3 ? Colors.red.shade50 : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${addresses.length} / 3',
                            style: TextStyle(
                              color: addresses.length >= 3 ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Expanded(
                    child: addresses.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_off_rounded, size: 64, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  'لا توجد مواقع محفوظة',
                                  style: TextStyle(color: AppColors.textSecondary, fontFamily: GoogleFonts.cairo().fontFamily),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            physics: const BouncingScrollPhysics(),
                            itemCount: addresses.length,
                            itemBuilder: (context, index) {
                              final addr = addresses[index];
                              return _buildAddressItem(context, addr, selectedId == addr.id, addressProvider, index);
                            },
                          ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (addresses.length >= 3) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('الحد الأقصى هو 3 مواقع. الرجاء حذف موقع لإضافة جديد.')),
                          );
                          return;
                        }
                        final result = await context.push('/customer/map_picker');
                        if (result != null && result is LatLng && context.mounted) {
                          _showNameAddressDialog(context, result);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_location_alt_rounded, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'إضافة عنوان جديد',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: GoogleFonts.cairo().fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressItem(BuildContext context, AddressModel address, bool isSelected, AddressProvider provider, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryColor.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primaryColor : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            provider.selectAddress(address.id);
            context.pop();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryColor : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSelected ? Icons.my_location_rounded : Icons.location_on_rounded,
                    color: isSelected ? Colors.white : Colors.grey.shade500,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.title,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: GoogleFonts.cairo().fontFamily,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${address.area} - ${address.street}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontFamily: GoogleFonts.cairo().fontFamily,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!isSelected)
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade300),
                    onPressed: () {
                      provider.removeAddress(address.id);
                    },
                  )
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.check_circle_rounded, color: AppColors.primaryColor),
                  ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade(delay: (50 * index).ms).slideX(begin: 0.1);
  }

  void _showNameAddressDialog(BuildContext context, LatLng location) {
    final titleController = TextEditingController();
    final areaController = TextEditingController();
    final streetController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تفاصيل العنوان',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontFamily: GoogleFonts.cairo().fontFamily,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'اسم الموقع (مثال: المنزل، العمل)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: areaController,
                decoration: InputDecoration(
                  labelText: 'المنطقة',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: streetController,
                decoration: InputDecoration(
                  labelText: 'الشارع / تفاصيل إضافية',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.trim().isEmpty || areaController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى تعبئة الاسم والمنطقة')));
                    return;
                  }
                  final provider = context.read<AddressProvider>();
                  final newId = DateTime.now().millisecondsSinceEpoch.toString();
                  provider.addAddress(
                    AddressModel(
                      id: newId,
                      title: titleController.text.trim(),
                      city: 'الخرطوم',
                      area: areaController.text.trim(),
                      street: streetController.text.trim(),
                      landmark: '',
                      latitude: location.latitude,
                      longitude: location.longitude,
                      phone: '',
                    )
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة العنوان بنجاح')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('حفظ', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: GoogleFonts.cairo().fontFamily)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }
    );
  }
}
