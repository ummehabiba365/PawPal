import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

// Simple location class
class LatLng {
  final double latitude;
  final double longitude;
  const LatLng(this.latitude, this.longitude);
}

class LostFoundScreen extends StatefulWidget {
  const LostFoundScreen({super.key});

  @override
  State<LostFoundScreen> createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends State<LostFoundScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _type = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _contact = TextEditingController();

  LatLng? _location;
  String _statusType = 'Lost';
  bool _isSubmitting = false;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    _location = const LatLng(33.6844, 73.0479); // Islamabad
  }

  @override
  void dispose() {
    _name.dispose();
    _type.dispose();
    _description.dispose();
    _contact.dispose();
    super.dispose();
  }

  Future<void> pickLocation() async {
    setState(() => _isGettingLocation = true);
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _location = const LatLng(33.6844, 73.0479);
      _isGettingLocation = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Location set to Islamabad coordinates"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> submitLostPet() async {
    if (_isSubmitting) return;

    if (_name.text.isEmpty ||
        _type.text.isEmpty ||
        _description.text.isEmpty ||
        _contact.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please fill required fields.")));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      final Map<String, dynamic> doc = {
        "petName": _name.text.trim(),
        "petType": _type.text.trim(),
        "description": _description.text.trim(),
        "contactInfo": _contact.text.trim(),
        "statusType": _statusType,
        "userId": user?.uid ?? "test_user_123",
        "userEmail": user?.email ?? "test@example.com",
        "lat": _location!.latitude,
        "lng": _location!.longitude,
        "timestamp": FieldValue.serverTimestamp(),
        "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "status": "active",
      };

      await FirebaseFirestore.instance.collection("test_posts").add(doc);

      try {
        await FirebaseFirestore.instance.collection("lost_found_posts").add(doc);
      } catch (_) {}

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ SUCCESS! Data saved to Firebase!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      _name.clear();
      _type.clear();
      _description.clear();
      _contact.clear();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error saving data: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lost & Found Pet"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            /// 🔥 FIXED: Lost / Found always on one line
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text(
                          "Lost",
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        value: "Lost",
                        groupValue: _statusType,
                        onChanged: (v) => setState(() => _statusType = v!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text(
                          "Found",
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        value: "Found",
                        groupValue: _statusType,
                        onChanged: (v) => setState(() => _statusType = v!),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: "Pet Name *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pets),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _type,
              decoration: const InputDecoration(
                labelText: "Type (Dog, Cat, etc.) *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _contact,
              decoration: const InputDecoration(
                labelText: "Contact Info *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
                hintText: "Phone number or email",
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Location",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    if (_location != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Latitude: ${_location!.latitude.toStringAsFixed(6)}"),
                          Text("Longitude: ${_location!.longitude.toStringAsFixed(6)}"),
                        ],
                      ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: _isGettingLocation
                          ? const CircularProgressIndicator()
                          : const Icon(Icons.location_on),
                      label: Text(_isGettingLocation ? "Setting..." : "Use Current Location"),
                      onPressed: pickLocation,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _isSubmitting ? null : submitLostPet,
              style: ElevatedButton.styleFrom(
                backgroundColor: _statusType == 'Lost' ? Colors.orange : Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isSubmitting
                  ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(width: 10),
                  Text("Saving to Firebase...",
                      style: TextStyle(color: Colors.white)),
                ],
              )
                  : Text(
                "SUBMIT ${_statusType.toUpperCase()} REPORT",
                style: const TextStyle(
                    fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
