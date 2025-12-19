import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Get current location
  Future<Position> getCurrentLocation() async {
    if (kIsWeb) {
      return _getWebLocation();
    } else {
      return _getMobileLocation();
    }
  }

  // --- Web ---
  Future<Position> _getWebLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      throw Exception(
          "Browser blocked location. Ensure HTTPS or allow location manually.");
    }
  }

  // --- Android/iOS ---
  Future<Position> _getMobileLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("GPS is OFF. Please enable location.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception("Location permission denied.");
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 7));
    } catch (e) {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(const Duration(seconds: 5));
    }
  }
}
