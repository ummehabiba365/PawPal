import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'firebase_options.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'verify_email_screen.dart'; // 👈 ADD THIS

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize AdMob
  await MobileAds.instance.initialize();

  // ✅ Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const PetCareApp());
}

class PetCareApp extends StatelessWidget {
  const PetCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Care & Adoption',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4DB6AC),
          secondary: const Color(0xFFFFB74D),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FDFD),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4DB6AC),
          foregroundColor: Colors.white,
          elevation: 4,
          centerTitle: true,
        ),
      ),

      // 🔐 AUTH + EMAIL VERIFICATION ROUTING
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // ⏳ Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // ✅ User logged in
          if (snapshot.hasData) {
            final user = snapshot.data!;

            // ✅ Email verified
            if (user.emailVerified) {
              return const HomeScreen();
            }

            // ❌ Email NOT verified
            return const VerifyEmailScreen();
          }

          // ❌ User not logged in
          return const LoginScreen();
        },
      ),
    );
  }
}
