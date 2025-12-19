import 'package:flutter/material.dart';

class CareTipsScreen extends StatelessWidget {
  const CareTipsScreen({super.key});

  final tips = const [
    {
      "title": "Feed your pets healthy food",
      "desc": "Avoid overfeeding and give them clean water daily.",
    },
    {
      "title": "Regular Vet Visits",
      "desc": "Keep vaccinations up to date and check health regularly.",
    },
    {
      "title": "Daily Exercise",
      "desc": "Walk your pets to keep them active and happy.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pet Care Tips")),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F2F1), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tips.length,
          itemBuilder: (context, index) {
            final tip = tips[index];
            return Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              margin: const EdgeInsets.symmetric(vertical: 10),
              elevation: 5,
              child: ListTile(
                leading: const Icon(Icons.favorite, color: Colors.teal),
                title: Text(
                  tip["title"]!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(tip["desc"]!),
              ),
            );
          },
        ),
      ),
    );
  }
}
