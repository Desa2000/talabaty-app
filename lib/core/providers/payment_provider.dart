import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentCard {
  final String id;
  final String holderName;
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String cardType;

  PaymentCard({
    required this.id,
    required this.holderName,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.cardType,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'holderName': holderName,
    'cardNumber': cardNumber,
    'expiryDate': expiryDate,
    'cvv': cvv,
    'cardType': cardType,
  };

  factory PaymentCard.fromJson(Map<String, dynamic> json) => PaymentCard(
    id: json['id'] ?? '',
    holderName: json['holderName'] ?? '',
    cardNumber: json['cardNumber'] ?? '',
    expiryDate: json['expiryDate'] ?? '',
    cvv: json['cvv'] ?? '',
    cardType: json['cardType'] ?? '',
  );
}

class PaymentProvider extends ChangeNotifier {
  List<PaymentCard> _cards = [];
  String? _selectedCardId;
  bool _isDisposed = false;

  List<PaymentCard> get cards => _cards;
  String? get selectedCardId => _selectedCardId;

  PaymentCard? get selectedCard => 
      _cards.isEmpty ? null : _cards.firstWhere((c) => c.id == _selectedCardId, orElse: () => _cards.first);

  PaymentProvider() {
    _loadCards();
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

  Future<void> _loadCards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_isDisposed) return;
      final cardsData = prefs.getString('payment_cards');
      if (cardsData != null) {
        final List<dynamic> decoded = jsonDecode(cardsData);
        _cards = decoded.map((item) => PaymentCard.fromJson(item)).toList();
        _selectedCardId = prefs.getString('selected_card_id');
        notifyListeners();
      } else {
        // Add default mock card if empty
        _cards = [
          PaymentCard(
            id: 'card_default',
            holderName: 'MAZIN',
            cardNumber: '**** **** **** 1234',
            expiryDate: '12/28',
            cvv: '123',
            cardType: 'VISA',
          )
        ];
        _selectedCardId = 'card_default';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cards: $e');
      if (_cards.isEmpty) {
        _cards = [
          PaymentCard(
            id: 'card_default',
            holderName: 'MAZIN',
            cardNumber: '**** **** **** 1234',
            expiryDate: '12/28',
            cvv: '123',
            cardType: 'VISA',
          )
        ];
        _selectedCardId = 'card_default';
        notifyListeners();
      }
    }
  }

  Future<void> addCard(PaymentCard card) async {
    _cards.add(card);
    _selectedCardId = card.id;
    await _saveCards();
    if (_isDisposed) return;
    notifyListeners();
  }

  Future<void> removeCard(String id) async {
    _cards.removeWhere((c) => c.id == id);
    if (_selectedCardId == id) {
      _selectedCardId = _cards.isNotEmpty ? _cards.first.id : null;
    }
    await _saveCards();
    if (_isDisposed) return;
    notifyListeners();
  }

  Future<void> selectCard(String id) async {
    _selectedCardId = id;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_isDisposed) return;
      await prefs.setString('selected_card_id', id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error selecting card: $e');
    }
  }

  Future<void> _saveCards() async {
    if (_isDisposed) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_isDisposed) return;
      final String encoded = jsonEncode(_cards.map((c) => c.toJson()).toList());
      await prefs.setString('payment_cards', encoded);
      if (_selectedCardId != null) {
        await prefs.setString('selected_card_id', _selectedCardId!);
      } else {
        await prefs.remove('selected_card_id');
      }
    } catch (e) {
      debugPrint('Error saving cards: $e');
    }
  }
}
