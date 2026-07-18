import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  
  // Default to Khartoum coordinates
  LatLng _currentCenter = const LatLng(15.5007, 32.5599); 
  bool _isLoading = true;
  bool _isMapReady = false;
  String _currentAddressText = "جاري تحديد الموقع...";
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationWarning('خدمات الموقع (GPS) مغلقة، يرجى تفعيلها من إعدادات الهاتف.');
      _finishLoading();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showLocationWarning('التطبيق يحتاج لصلاحية الموقع لتحديد عنوان التوصيل بدقة.');
        _finishLoading();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showLocationWarning('صلاحية الموقع مرفوضة دائماً. يرجى تفعيلها من إعدادات التطبيق.');
      _finishLoading();
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 10),
      );
      if (mounted) {
        setState(() {
          _currentCenter = LatLng(position.latitude, position.longitude);
          _isLoading = false;
          _updateAddressText();
        });
        
        if (_isMapReady) {
          _mapController.move(_currentCenter, 15.0);
        }
      }
    } catch (e) {
      _showLocationWarning('فشل في الحصول على الموقع الجغرافي. يرجى التأكد من قوة إشارة الـ GPS أو تحديد الموقع يدوياً.');
      _finishLoading();
    }
  }

  void _finishLoading() {
    setState(() {
      _isLoading = false;
      _updateAddressText();
    });
  }

  void _showLocationWarning(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontFamily: GoogleFonts.cairo().fontFamily)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade400,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
      )
    );
  }

  void _updateAddressText() {
    setState(() {
      _currentAddressText = "موقع التوصيل المحدد";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // 1. The Map Background
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 15.0,
              onMapReady: () {
                _isMapReady = true;
                if (!_isLoading) {
                  _mapController.move(_currentCenter, 15.0);
                }
              },
              onPositionChanged: (position, hasGesture) {
                if (hasGesture && position.center != null) {
                  setState(() {
                    _currentCenter = position.center!;
                    _isDragging = true;
                  });
                }
              },
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  setState(() {
                    _isDragging = false;
                    _updateAddressText();
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                userAgentPackageName: 'com.example.talabaty_app',
              ),
            ],
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
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'حدد موقع التوصيل',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      fontFamily: GoogleFonts.cairo().fontFamily,
                      shadows: [Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4)],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Center Pin
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40), // Offset for the pin point
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.translationValues(0, _isDragging ? -15 : 0, 0),
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
                      child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.white.withValues(alpha: 0.8),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              ),
            ),

          // 5. Current Location Button
          Positioned(
            right: 20,
            bottom: 220,
            child: FloatingActionButton(
              heroTag: 'my_location',
              backgroundColor: Colors.white,
              onPressed: () {
                setState(() => _isLoading = true);
                _determinePosition();
              },
              child: const Icon(Icons.my_location_rounded, color: AppColors.primaryColor),
            ),
          ),

          // 6. Bottom Sheet Container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 30, offset: const Offset(0, 10))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_on_rounded, color: AppColors.primaryColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'موقع التوصيل',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontFamily: GoogleFonts.cairo().fontFamily,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentAddressText,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: GoogleFonts.cairo().fontFamily,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isDragging || _isLoading
                        ? null
                        : () {
                            // Return selected coordinates
                            context.pop(_currentCenter);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      'تأكيد الموقع',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.cairo().fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fade().slideY(begin: 0.2),
          ),
        ],
      ),
    );
  }
}
