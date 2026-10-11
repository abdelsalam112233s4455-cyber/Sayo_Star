import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../mainscreen/home.dart';
import 'login.dart';

class Auth extends StatefulWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  State<Auth> createState() => AuthState();
}

class AuthState extends State<Auth> {
  @override
  void initState() {
    super.initState();
    // تنفيذ التحقق بعد تحضير الشاشة
    Future.microtask(() => _checkAuthState());
  }

  void _checkAuthState() {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // المستخدم مسجل دخول سابقاً -> التوجيه للشاشة الرئيسية
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } else {
      // المستخدم غير مسجل دخول -> التوجيه لصفحة تسجيل الدخول
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // شاشة تحكم مؤقتة (Splash / Loading) أثناء إجراء عملية التحقق
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
