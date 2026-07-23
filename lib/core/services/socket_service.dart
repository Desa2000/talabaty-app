import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../network/api_endpoints.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  SocketService._internal();

  io.Socket? _socket;

  String get _socketUrl {
    final base = ApiEndpoints.baseUrl;
    if (base.endsWith('/api')) {
      return base.substring(0, base.length - 4);
    }
    return base;
  }

  void connect() {
    if (_socket != null && _socket!.connected) return;

    _socket = io.io(_socketUrl, <String, dynamic>{
      'transports': ['websocket', 'polling'],
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      debugPrint('✅ Connected to Socket.IO Server at $_socketUrl');
    });

    _socket!.onDisconnect((_) {
      debugPrint('❌ Disconnected from Socket.IO Server');
    });

    _socket!.onError((error) {
      debugPrint('⚠️ Socket Error: $error');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void joinOrderRoom(String orderId) {
    if (_socket == null || !_socket!.connected) connect();
    _socket?.emit('joinOrderRoom', orderId);
    debugPrint('Joined tracking room for order: $orderId');
  }

  void joinUserRoom(String userId) {
    if (_socket == null || !_socket!.connected) connect();
    _socket?.emit('joinUserRoom', userId);
    debugPrint('Joined user room: user_$userId');
  }

  void joinStoreRoom(String storeId) {
    if (_socket == null || !_socket!.connected) connect();
    _socket?.emit('joinStoreRoom', storeId);
    debugPrint('Joined store room: store_$storeId');
  }

  void joinCourierChannel() {
    if (_socket == null || !_socket!.connected) connect();
    _socket?.emit('joinCourierChannel');
    debugPrint('Joined available couriers channel');
  }

  void emitLocation(String orderId, double lat, double lng, {double heading = 0.0}) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('updateLocation', {
        'orderId': orderId,
        'lat': lat,
        'lng': lng,
        'heading': heading,
      });
    }
  }

  void onLocationUpdate(Function(Map<String, dynamic> data) callback) {
    _socket?.on('courier.location_updated', (data) {
      if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  void onOrderStatusUpdate(Function(Map<String, dynamic> data) callback) {
    _socket?.on('order.status_updated', (data) {
      if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  void onOrderCreated(Function(Map<String, dynamic> data) callback) {
    _socket?.on('order.created', (data) {
      if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  void onCourierOfferReceived(Function(Map<String, dynamic> data) callback) {
    _socket?.on('courier.offer_received', (data) {
      if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  void offAllListeners() {
    _socket?.off('courier.location_updated');
    _socket?.off('order.status_updated');
    _socket?.off('order.created');
    _socket?.off('courier.offer_received');
  }
}
