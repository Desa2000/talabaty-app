import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_model.dart';
import '../../data/models/store_model.dart';
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

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // EmailJS Configuration
  final String _emailJsServiceId = 'service_jsuc8aw';
  final String _emailJsTemplateId = 'template_vzcvnsc';
  final String _emailJsPublicKey = 'Ed5rNbSOVlZ8Fh9v9';

  String? _generatedOtp;
  String? _pendingEmail;

  // Secret suffix to generate a deterministic password for Firebase Auth
  final String _secretSuffix = '_@TalabatySecret2026';

  bool _isDisposed = false;

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
      final user = _auth.currentUser;
      if (user != null) {
        final userModel = await _firestoreService.getUser(user.uid);
        if (_isDisposed) return;
        if (userModel != null) {
          _currentUser = userModel;
        } else {
          // User is authenticated but has no profile, sign out
          await _auth.signOut();
          if (_isDisposed) return;
          _currentUser = null;
        }
      } else {
        _currentUser = null;
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
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
      // FIX: ensure loading is never left true on early-exit error paths
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

    // OTP Correct! Authenticate with Firebase using Email & Password trick
    final deterministicPassword = '$_pendingEmail$_secretSuffix';

    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _pendingEmail!,
        password: deterministicPassword,
      );
      if (_isDisposed) return null;
      
      final user = userCredential.user;
      
      if (user != null) {
        final userModel = await _firestoreService.getUser(user.uid);
        if (_isDisposed) return null;
        
        _isLoading = false;
        if (userModel != null) {
          _currentUser = userModel;
          notifyListeners();
          return userModel.role;
        } else {
          // User needs to register (should rarely happen if they successfully signed in)
          notifyListeners();
          return null; 
        }
      } else {
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } on FirebaseAuthException catch (e) {
      if (_isDisposed) return null;
      _isLoading = false;
      notifyListeners();
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        return null;
      }
      onError(e.message ?? 'حدث خطأ أثناء تسجيل الدخول');
      return null;
    } catch (e) {
      if (_isDisposed) return null;
      _isLoading = false;
      notifyListeners();
      onError(e.toString());
      return null;
    }
  }

  Future<void> register({required String name, required String phone, required String email, required UserRole role}) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final deterministicPassword = '$email$_secretSuffix';
      // Create user in Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: deterministicPassword,
      );
      if (_isDisposed) return;

      final user = userCredential.user;
      if (user == null) {
        throw Exception('فشل إنشاء الحساب');
      }

      final newUser = UserModel(
        id: user.uid,
        name: name,
        phone: phone,
        password: '', // Not used anymore
        role: role,
        createdAt: DateTime.now(),
      );

      await _firestoreService.saveUser(newUser);
      if (_isDisposed) return;
      
      // If the user is a merchant, create a default store for them
      if (role == UserRole.merchant) {
        final newStore = StoreModel(
          id: 'store_${user.uid}', 
          ownerId: user.uid,
          name: 'مطعم $name',
          type: StoreType.restaurant,
          logo: 'https://images.unsplash.com/photo-1550547660-d9450f859349?q=80&w=400&auto=format&fit=crop',
          phone: phone,
          area: 'الخرطوم',
          street: 'عام',
          landmark: '',
          latitude: 15.5,
          longitude: 32.5,
          openingTime: '08:00 AM',
          closingTime: '11:00 PM',
          preparationTime: '15 - 30 دقيقة',
          minimumOrder: 2000,
          deliveryFee: 1000,
          status: 'active',
          rating: 5.0,
        );
        await _firestoreService.saveStore(newStore);
        if (_isDisposed) return;
      }

      _currentUser = newUser;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (_isDisposed) return;
      
      if (e.toString().contains('email-already-in-use') || e.toString().contains('already-in-use')) {
        try {
          final deterministicPassword = '$email$_secretSuffix';
          final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: deterministicPassword,
          );
          if (_isDisposed) return;
          final user = userCredential.user;
          if (user != null) {
            final newUser = UserModel(
              id: user.uid,
              name: name,
              phone: phone,
              email: email,
              password: '',
              role: role,
              createdAt: DateTime.now(),
            );
            await _firestoreService.saveUser(newUser);
            if (_isDisposed) return;

            if (role == UserRole.merchant) {
              final newStore = StoreModel(
                id: 'store_${user.uid}', 
                ownerId: user.uid,
                name: 'مطعم $name',
                type: StoreType.restaurant,
                logo: 'https://images.unsplash.com/photo-1550547660-d9450f859349?q=80&w=400&auto=format&fit=crop',
                phone: phone,
                area: 'الخرطوم',
                street: 'عام',
                landmark: '',
                latitude: 15.5,
                longitude: 32.5,
                openingTime: '08:00 AM',
                closingTime: '11:00 PM',
                preparationTime: '15 - 30 دقيقة',
                minimumOrder: 2000,
                deliveryFee: 1000,
                status: 'active',
                rating: 5.0,
              );
              await _firestoreService.saveStore(newStore);
              if (_isDisposed) return;
            }

            _currentUser = newUser;
            _isLoading = false;
            notifyListeners();
            return;
          }
        } catch (signInErr) {
          debugPrint('Self-heal registration bypass failed: $signInErr');
        }
      }

      _isLoading = false;
      notifyListeners();
      throw Exception(e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
    if (_isDisposed) return;
    // FIX: clear ALL local auth state so no stale data leaks into the next session
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
    
    try {
      await _firestoreService.saveUser(_currentUser!);
    } catch (e) {
      debugPrint('Error saving user address: $e');
    }
    if (_isDisposed) return;
    notifyListeners();
  }
}
