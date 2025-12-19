import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestFirebase extends StatelessWidget {
  const TestFirebase({super.key});

  Future<void> _testFirestore(BuildContext context) async {
    try {
      // Test 1: Simple write
      await FirebaseFirestore.instance
          .collection("test_collection")
          .doc("test_doc")
          .set({
        "message": "Hello from Flutter!",
        "timestamp": DateTime.now().toString(),
        "test": "working"
      });

      // Test 2: Simple read
      final doc = await FirebaseFirestore.instance
          .collection("test_collection")
          .doc("test_doc")
          .get();

      // Test 3: Add to your actual collection
      await FirebaseFirestore.instance.collection("lost_found_posts").add({
        "test": "test_post",
        "timestamp": DateTime.now().toString(),
        "petName": "Test Pet",
        "description": "Testing Firebase connection",
        "contactInfo": "test@example.com",
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ FIREBASE WORKS! All tests passed."),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          )
      );

      print("✅ Firebase tests passed!");

    } catch (e) {
      print("❌ Firebase test error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ FIREBASE ERROR:\n$e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firebase Test")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Firebase Test",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _testFirestore(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: const Text("TEST FIRESTORE"),
            ),
            const SizedBox(height: 20),
            const Text(
              "If this works, your LostFoundScreen will also work.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}