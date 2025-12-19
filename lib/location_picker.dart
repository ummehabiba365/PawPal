import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

// Simple LatLng class for Web + Android
class LatLng {
  final double latitude;
  final double longitude;
  const LatLng(this.latitude, this.longitude);
}

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  bool _isLoading = false;
  String _statusMessage = 'Tap the button to detect your location';

  // ------------------- Check permissions -------------------
  Future<bool> _checkPermissions() async {
    if (kIsWeb) {
      // Web doesn't need permission check; just HTTPS
      return true;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _statusMessage =
      'Location services disabled. Enable them in settings.');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() =>
        _statusMessage = 'Permission denied. Enable location manually.');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _statusMessage =
      'Permission permanently denied. Open settings to allow.');
      return false;
    }

    return true;
  }

  // ------------------- Get current location -------------------
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Fetching location...';
    });

    try {
      final allowed = await _checkPermissions();
      if (!allowed) return;

      Position? position;

      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        ).timeout(const Duration(seconds: 7));
      } catch (_) {
        // fallback
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        ).timeout(const Duration(seconds: 5));
      }

      final latLng =
      LatLng(position.latitude, position.longitude);

      Navigator.pop(context, latLng);
    } catch (e) {
      setState(() => _statusMessage =
      "Error fetching location. Using default coordinates.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick Location"),
        actions: [
          TextButton(
            onPressed: () {
              // Fallback default location (Karachi)
              Navigator.pop(context, const LatLng(24.8607, 67.0011));
            },
            child:
            const Text("Use Default", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_pin, size: 90, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 25),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
              icon: const Icon(Icons.my_location),
              label: const Text("Detect My Location"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
              ),
              onPressed: _getCurrentLocation,
            ),
            const SizedBox(height: 30),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Icon(Icons.info, color: Colors.blue),
                    SizedBox(height: 8),
                    Text(
                      "Your device's GPS will be used to get precise coordinates for lost pet reporting.",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            if (kIsWeb)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  "Note: Web requires HTTPS for accurate location.",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
