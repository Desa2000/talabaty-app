import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';

class AddressProvider extends ChangeNotifier {
  List<AddressModel> _addresses = [];
  String? _selectedAddressId;
  bool _isDisposed = false;

  AddressProvider() {
    _loadAddresses();
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
    }
  }

  List<AddressModel> get addresses => List.unmodifiable(_addresses);
  AddressModel? get selectedAddress => _addresses.where((a) => a.id == _selectedAddressId).firstOrNull;
  String? get selectedAddressId => _selectedAddressId;

  Future<void> _loadAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_isDisposed) return;
      final addressesJson = prefs.getString('saved_addresses');
      final selectedId = prefs.getString('selected_address_id');
      
      if (addressesJson != null) {
        final List<dynamic> decodedList = json.decode(addressesJson);
        _addresses = decodedList.map((item) => AddressModel.fromJson(item)).toList();
      }
      
      _selectedAddressId = selectedId;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading addresses: $e');
    }
  }

  Future<void> _saveAddresses() async {
    if (_isDisposed) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_isDisposed) return;
      final encodedList = json.encode(_addresses.map((a) => a.toJson()).toList());
      await prefs.setString('saved_addresses', encodedList);
      if (_selectedAddressId != null) {
        await prefs.setString('selected_address_id', _selectedAddressId!);
      } else {
        await prefs.remove('selected_address_id');
      }
    } catch (e) {
      debugPrint('Error saving addresses: $e');
    }
  }

  /// Returns true if added successfully, false if limit reached
  bool addAddress(AddressModel address) {
    if (_addresses.length >= 3) {
      return false; // Cannot add more than 3 addresses
    }
    _addresses.add(address);
    _selectedAddressId = address.id; // Auto select the newly added address
    _saveAddresses();
    notifyListeners();
    return true;
  }

  void removeAddress(String id) {
    _addresses.removeWhere((a) => a.id == id);
    if (_selectedAddressId == id) {
      _selectedAddressId = _addresses.isNotEmpty ? _addresses.first.id : null;
    }
    _saveAddresses();
    notifyListeners();
  }

  void selectAddress(String id) {
    _selectedAddressId = id;
    _saveAddresses();
    notifyListeners();
  }
}
