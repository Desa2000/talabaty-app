import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  
  SocketService._internal();

  io.Socket? _socket;

  // You can change this to your live server URL later (e.g. https://api.talabaty.com)
  final String _serverUrl = 'http://10.0.2.2:3000'; // 10.0.2.2 is localhost for Android Emulator

  void connect() {
    if (_socket != null && _socket!.connected) return;

    _socket = io.io(_serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      log('✅ Connected to WebSocket Server');
    });

    _socket!.onDisconnect((_) {
      log('❌ Disconnected from WebSocket Server');
    });

    _socket!.onError((error) {
      log('⚠️ WebSocket Error: $error');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  // Courier joins their own tracking room or specific order room
  void joinOrderRoom(String orderId) {
    if (_socket == null || !_socket!.connected) connect();
    _socket?.emit('joinOrderRoom', orderId);
    log('Joined tracking room for order: $orderId');
  }

  // Courier emits their new location
  void emitLocation(String orderId, double lat, double lng) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('updateLocation', {
        'orderId': orderId,
        'lat': lat,
        'lng': lng,
      });
      log('📍 Location emitted: $lat, $lng');
    }
  }

  // Customer listens for location updates
  void onLocationUpdate(Function(double lat, double lng) callback) {
    _socket?.on('locationUpdated', (data) {
      if (data is Map && data['lat'] != null && data['lng'] != null) {
        callback((data['lat'] as num).toDouble(), (data['lng'] as num).toDouble());
      }
    });
  }
  
  // Cleanup listener
  void offLocationUpdate() {
    _socket?.off('locationUpdated');
  }
}
