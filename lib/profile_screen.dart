import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // If user is NOT logged in → show login prompt
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          backgroundColor: const Color(0xFF4DB6AC),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_off,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
              const Text(
                "You're not logged in",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Please login to view your profile",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4DB6AC),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If user exists → show complete profile
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF4DB6AC),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                "My Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF26A69A), Color(0xFF4DB6AC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Text(
                          currentUser.email![0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 45,
                            color: Color(0xFF4DB6AC),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  // Show confirmation dialog
                  bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            "Logout",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    }
                  }
                },
              ),
            ],
          ),

          // Profile Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Card
                  _buildInfoCard(
                    title: "Account Information",
                    children: [
                      _buildInfoRow(
                        Icons.email,
                        "Email",
                        currentUser.email ?? "No Email",
                      ),
                      const Divider(),
                      _buildInfoRow(
                        Icons.fingerprint,
                        "User ID",
                        currentUser.uid.substring(0, 20) + "...",
                      ),
                      const Divider(),
                      _buildInfoRow(
                        Icons.verified_user,
                        "Email Verified",
                        currentUser.emailVerified ? "Yes" : "No",
                        valueColor: currentUser.emailVerified
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // My Activity Section
                  _buildInfoCard(
                    title: "My Activity",
                    children: [
                      _buildActivityTile(
                        Icons.pets,
                        "My Adoption Posts",
                        "0",
                            () {
                          // Navigate to user's adoption posts
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Opening adoption posts...")),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildActivityTile(
                        Icons.search,
                        "My Lost & Found Posts",
                        "0",
                            () {
                          // Navigate to user's lost & found posts
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Opening lost & found posts...")),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildActivityTile(
                        Icons.favorite,
                        "Saved Pets",
                        "0",
                            () {
                          // Navigate to saved pets
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Opening saved pets...")),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Settings Section
                  _buildInfoCard(
                    title: "Settings",
                    children: [
                      _buildSettingsTile(
                        Icons.person_outline,
                        "Edit Profile",
                            () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Edit profile coming soon...")),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildSettingsTile(
                        Icons.lock_outline,
                        "Change Password",
                            () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Change password coming soon...")),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildSettingsTile(
                        Icons.notifications_outlined,
                        "Notifications",
                            () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Notifications settings coming soon...")),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildSettingsTile(
                        Icons.location_on_outlined,
                        "Location Settings",
                            () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Location settings coming soon...")),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Help & Support Section
                  _buildInfoCard(
                    title: "Help & Support",
                    children: [
                      _buildSettingsTile(
                        Icons.help_outline,
                        "Help Center",
                            () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Opening help center...")),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildSettingsTile(
                        Icons.privacy_tip_outlined,
                        "Privacy Policy",
                            () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Opening privacy policy...")),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildSettingsTile(
                        Icons.description_outlined,
                        "Terms of Service",
                            () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Opening terms of service...")),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildSettingsTile(
                        Icons.info_outline,
                        "About PetCare",
                            () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("About PetCare"),
                              content: const Text(
                                "PetCare v1.0\n\n"
                                    "Your trusted platform for pet adoption "
                                    "and finding lost pets.\n\n"
                                    "Made with ❤️ for pet lovers",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Close"),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Delete Account Button
                  Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Delete Account"),
                            content: const Text(
                              "Are you sure you want to delete your account? "
                                  "This action cannot be undone.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          try {
                            await currentUser.delete();
                            if (context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "Error deleting account: ${e.toString()}"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      label: const Text(
                        "Delete Account",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for info cards
  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004D40),
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  // Helper widget for info rows
  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4DB6AC), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: valueColor ?? Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for activity tiles
  Widget _buildActivityTile(
      IconData icon, String title, String count, VoidCallback onTap) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE0F2F1),
        child: Icon(icon, color: const Color(0xFF4DB6AC)),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4DB6AC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }

  // Helper widget for settings tiles
  Widget _buildSettingsTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4DB6AC)),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}