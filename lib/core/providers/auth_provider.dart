import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_api_service.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../services/firestore_service.dart';
import '../constants/enums.dart';
import '../router/app_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _verificationId;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  final AuthApiService _authApiService = AuthApiService();
  final FirestoreService _firestoreService = FirestoreService();

  // EmailJS Configuration
  final String _emailJsServiceId = 'service_jsuc8aw';
  final String _emailJsTemplateId = 'template_vzcvnsc';
  final String _emailJsPublicKey = 'Ed5rNbSOVlZ8Fh9v9';

  String? _generatedOtp;
  String? _pendingEmail;

  // Secret suffix to generate a deterministic password for Backend login
  final String _secretSuffix = '_@TalabatySecret2026';

  bool _isDisposed = false;

  AuthProvider() {
    // Register auto-logout hook when API token expires
    ApiClient().onSessionExpired = () {
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    };
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
      AppRouter.authNotifier.notify();
    }
  }

  /// Development-only: auto-login as test customer
  void devAutoLogin() {
    _currentUser = UserModel(
      id: 'cu1',
      name: 'عمر صديق',
      phone: '0912345678',
      email: 'omar@talabaty.com',
      password: '123',
      role: UserRole.customer,
      createdAt: DateTime.now(),
    );
    _isLoading = false;
    notifyListeners();
    debugPrint('DEV: Auto-logged in as customer عمر صديق');
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await ApiClient().getAccessToken();
      if (token != null) {
        final user = await _authApiService.getMe();
        if (_isDisposed) return;
        if (user != null) {
          _currentUser = user;
        } else {
          await ApiClient().clearTokens();
          _currentUser = null;
        }
      } else {
        _currentUser = null;
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      _currentUser = null;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> sendOtp({required String phone, required String email, required Function(String) onError, required Function() onCodeSent}) async {
    _generatedOtp = null;
    _pendingEmail = null;
    _isLoading = true;
    notifyListeners();

    try {
      final random = Random();
      _generatedOtp = (100000 + random.nextInt(900000)).toString();
      _pendingEmail = email;

      debugPrint('==== EMAIL OTP GENERATED: $_generatedOtp ====');

      if (_emailJsServiceId == 'YOUR_SERVICE_ID' || _emailJsServiceId.isEmpty) {
        debugPrint('EmailJS keys not configured. OTP printed in console only.');
        _isLoading = false;
        notifyListeners();
        onCodeSent();
        return;
      }

      try {
        final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'service_id': _emailJsServiceId,
            'template_id': _emailJsTemplateId,
            'user_id': _emailJsPublicKey,
            'template_params': {
              'email': email,
              'otp': _generatedOtp,
            }
          }),
        );
        if (_isDisposed) return;

        if (response.statusCode == 200) {
          _isLoading = false;
          notifyListeners();
          onCodeSent();
        } else {
          throw Exception('فشل إرسال الإيميل: ${response.body}');
        }
      } catch (e) {
        if (_isDisposed) return;
        debugPrint('EmailJS sending failed ($e). Proceeding in offline testing mode.');
        _isLoading = false;
        notifyListeners();
        onCodeSent();
      }
    } catch (e) {
      if (_isDisposed) return;
      _isLoading = false;
      notifyListeners();
      onError(e.toString());
    }
  }

  Future<UserRole?> verifyOtp(String otp, {required Function(String) onError}) async {
    if (_generatedOtp == null || _pendingEmail == null) {
      _isLoading = false;
      notifyListeners();
      onError('خطأ غير متوقع، الرجاء طلب الرمز مرة أخرى');
      return null;
    }

    _isLoading = true;
    notifyListeners();

    // Verify OTP (allow master test codes 1234, 123456, 123457 for testing)
    if (otp != _generatedOtp && otp != '1234' && otp != '123456' && otp != '123457') {
      _isLoading = false;
      notifyListeners();
      onError('رمز التحقق غير صحيح');
      return null;
    }

    // OTP Correct! Login to REST Backend using Email & Password trick
    final deterministicPassword = '$_pendingEmail$_secretSuffix';

    try {
      final res = await _authApiService.login(
        identifier: _pendingEmail!,
        password: deterministicPassword,
      );

      if (_isDisposed) return null;

      final user = res['user'] as UserModel;
      await ApiClient().saveTokens(
        accessToken: res['accessToken'],
        refreshToken: res['refreshToken'],
      );

      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return user.role;
    } on ApiException catch (e) {
      _isLoading = false;
      notifyListeners();
      
      // If user not found (status 401), we return null to trigger Register Screen navigation
      if (e.statusCode == 401) {
        return null; 
      }
      
      onError(e.message);
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      onError(e.toString());
      return null;
    }
  }

  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required UserRole role,
    String? businessName,
    String? businessDescription,
    String? businessArea,
    String? storeName,
    String? storeCategory,
    String? vehicleType,
    String? idNumber,
    String? licenseNumber,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final deterministicPassword = '$email$_secretSuffix';
      Map<String, dynamic> res;

      if (role == UserRole.merchant) {
        res = await _authApiService.registerMerchant(
          name: name,
          phone: phone,
          email: email,
          password: deterministicPassword,
          businessName: businessName ?? 'مطعم $name',
          businessDescription: businessDescription ?? 'وجبات سودانية وعالمية طازجة',
          businessArea: businessArea ?? 'الخرطوم',
          storeName: storeName ?? 'مطعم $name',
          storeCategory: storeCategory ?? 'RESTAURANT',
          storeAddress: businessArea ?? 'الخرطوم',
          latitude: 15.5640,
          longitude: 32.5840,
        );
      } else if (role == UserRole.courier) {
        res = await _authApiService.registerCourier(
          name: name,
          phone: phone,
          email: email,
          password: deterministicPassword,
          vehicleType: vehicleType ?? 'MOTORCYCLE',
          idNumber: idNumber ?? '123456789',
          licenseNumber: licenseNumber ?? 'خ 1234',
        );
      } else {
        res = await _authApiService.registerCustomer(
          name: name,
          phone: phone,
          email: email,
          password: deterministicPassword,
        );
      }

      if (_isDisposed) return;

      final user = res['user'] as UserModel;
      await ApiClient().saveTokens(
        accessToken: res['accessToken'],
        refreshToken: res['refreshToken'],
      );

      _currentUser = user;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception(e.toString());
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authApiService.logout();
    } catch (e) {
      debugPrint('Error during backend logout: $e');
    }

    if (_isDisposed) return;
    _currentUser = null;
    _generatedOtp = null;
    _pendingEmail = null;
    _verificationId = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSavedAddress(AddressModel address) async {
    if (_currentUser == null) return;

    final updatedAddresses = List<AddressModel>.from(_currentUser!.savedAddresses ?? []);
    updatedAddresses.add(address);

    _currentUser = UserModel(
      id: _currentUser!.id,
      name: _currentUser!.name,
      phone: _currentUser!.phone,
      email: _currentUser!.email,
      password: _currentUser!.password,
      role: _currentUser!.role,
      profileImage: _currentUser!.profileImage,
      createdAt: _currentUser!.createdAt,
      fcmToken: _currentUser!.fcmToken,
      savedAddresses: updatedAddresses,
    );

    // Save to Firestore if firebase is active, wrap in try-catch so it never crashes
    try {
      await _firestoreService.saveUser(_currentUser!);
    } catch (e) {
      debugPrint('Error syncing user address: $e');
    }
    if (_isDisposed) return;
    notifyListeners();
  }
}
