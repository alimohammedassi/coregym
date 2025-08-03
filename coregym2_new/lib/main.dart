import 'package:flutter/material.dart';
import 'splashScreen.dart';
import 'Login&SignUp.dart';
import 'FitnessHomePages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Core Gym',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display',
      ),
      home: AuthStateHandler(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Widget للتحكم في حالة المصادقة
class AuthStateHandler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // أثناء التحميل
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen();
        }

        // إذا كان المستخدم مسجل دخول
        if (snapshot.hasData && snapshot.data != null) {
          return FitnessHomePage(); // Navigate to the actual home page
        }

        // إذا لم يكن مسجل دخول
        return const AuthWrapper();
      },
    );
  }
}
