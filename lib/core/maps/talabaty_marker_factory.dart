import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TalabatyMarkerFactory {
  // Brand Colors
  static const Color primaryOrange = Color(0xFFFF5722);
  static const Color darkCharcoal = Color(0xFF1A1D20);
  static const Color pureWhite = Color(0xFFFFFFFF);

  /// Create Customer Destination Marker
  static Future<BitmapDescriptor> createCustomerMarker() async {
    const int width = 120;
    const int height = 120;
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Paint fillPaint = Paint()
      ..color = primaryOrange
      ..style = PaintingStyle.fill;

    final Paint whiteCirclePaint = Paint()
      ..color = pureWhite
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = primaryOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    // Draw outer pin circle
    const Offset center = Offset(width / 2, height / 2 - 10);
    canvas.drawCircle(center, 42, fillPaint);
    canvas.drawCircle(center, 34, whiteCirclePaint);

    // Draw bottom pointer tip
    final Path pointerPath = Path()
      ..moveTo(width / 2 - 14, height / 2 + 18)
      ..lineTo(width / 2, height / 2 + 48)
      ..lineTo(width / 2 + 14, height / 2 + 18)
      ..close();
    canvas.drawPath(pointerPath, fillPaint);

    // Draw center dot
    canvas.drawCircle(center, 12, fillPaint);

    final ui.Image image = await pictureRecorder.endRecording().toImage(width, height);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  /// Create Merchant Store Marker based on Category (RESTAURANT, SUPERMARKET, PHARMACY)
  static Future<BitmapDescriptor> createMerchantMarker({String category = 'RESTAURANT'}) async {
    const int width = 130;
    const int height = 130;
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    Color categoryBg = primaryOrange;
    if (category == 'SUPERMARKET') {
      categoryBg = const Color(0xFF2E7D32); // Emerald Green
    } else if (category == 'PHARMACY') {
      categoryBg = const Color(0xFF7B1FA2); // Purple
    }

    final Paint bgPaint = Paint()..color = categoryBg;
    final Paint whitePaint = Paint()..color = pureWhite;
    final Paint borderPaint = Paint()
      ..color = pureWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    const Offset center = Offset(width / 2, height / 2 - 10);

    // Outer circle pin
    canvas.drawCircle(center, 44, bgPaint);
    canvas.drawCircle(center, 44, borderPaint);
    canvas.drawCircle(center, 34, whitePaint);

    // Tip
    final Path pointerPath = Path()
      ..moveTo(width / 2 - 16, height / 2 + 20)
      ..lineTo(width / 2, height / 2 + 52)
      ..lineTo(width / 2 + 16, height / 2 + 20)
      ..close();
    canvas.drawPath(pointerPath, bgPaint);

    // Inner icon representation
    final Paint iconFill = Paint()..color = categoryBg;
    canvas.drawRect(Rect.fromCenter(center: center, width: 22, height: 18), iconFill);

    final ui.Image image = await pictureRecorder.endRecording().toImage(width, height);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  /// Create Branded Courier Directional Arrow Marker (Rotatable according to Bearing)
  static Future<BitmapDescriptor> createCourierArrowMarker() async {
    const int width = 140;
    const int height = 140;
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Paint orangePaint = Paint()..color = primaryOrange;
    final Paint whitePaint = Paint()..color = pureWhite;
    final Paint shadowPaint = Paint()
      ..color = darkCharcoal.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    const Offset center = Offset(width / 2, height / 2);

    // Draw shadow circle
    canvas.drawCircle(center + const Offset(0, 4), 38, shadowPaint);

    // Draw base circle
    canvas.drawCircle(center, 36, whitePaint);
    canvas.drawCircle(center, 32, orangePaint);

    // Draw Directional Arrow pointing UP (north = 0 deg)
    final Path arrowPath = Path()
      ..moveTo(center.dx, center.dy - 22) // Arrow head tip
      ..lineTo(center.dx - 14, center.dy + 16) // Left wing
      ..lineTo(center.dx, center.dy + 8) // Center notch
      ..lineTo(center.dx + 14, center.dy + 16) // Right wing
      ..close();

    canvas.drawPath(arrowPath, whitePaint);

    final ui.Image image = await pictureRecorder.endRecording().toImage(width, height);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }
}
