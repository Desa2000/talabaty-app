import 'dart:ui' as ui;

class TalabatyMapTheme {
  // Brand Color Palette
  static const String primaryColorHex = '#FF5722';
  static const String secondaryColorHex = '#1A1D20';
  static const String warmBgHex = '#FAF7F2';

  // Custom JSON style for Google Maps (Clean, warm, branded, legibility optimized)
  static const String lightMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{ "color": "#faf7f2" }]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#4a4e54" }]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{ "color": "#ffffff" }, { "weight": 2 }]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#1a1d20" }, { "weight": 600 }]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#7a8088" }]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [{ "color": "#e8f3e8" }]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{ "color": "#ffffff" }]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [{ "color": "#e2e6ea" }]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{ "color": "#ffe8df" }]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [{ "color": "#ffab91" }]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{ "color": "#d4e6f1" }]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#34495e" }]
  }
]
''';

  static const String darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{ "color": "#16191d" }]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#9aa0a6" }]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{ "color": "#16191d" }]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{ "color": "#23272d" }]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{ "color": "#38241e" }]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [{ "color": "#ff5722" }]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{ "color": "#0e1824" }]
  }
]
''';
}
