import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'rlogin.dart';
import 'terms.dart';
import 'auth.dart';

// ignore: non_constant_identifier_names
final host_link_timer =
    "https://test-celtic-libs-listen.trycloudflare.com";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? ID;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool _isLoading = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // دالة إنشاء مستند فارغ

  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _googleSignIn.initialize();

      final GoogleSignInAccount account = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = account.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 240, 21, 5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                const Text(
                  'خطأ في العثور على الidtoken',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1E222B),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
      final String email = FirebaseAuth.instance.currentUser?.email ?? '';

      final response = await http.get(
        Uri.parse('$host_link_timer/users/${Uri.encodeComponent(email)}'),
        headers: {'Content-Type': 'application/json'},
      );
      jsonEncode({'email': email});
      Map<String, dynamic> data = jsonDecode(response.body);

      if (data['atchevement'] == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Auth()),
          (route) => false, // يمسح كل الصفحات القديمة
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Complete_Registration()),
        );
      }
      if (!mounted) return;
    } catch (e) {
      debugPrint('❌ Google Sign-In Error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(178, 204, 8, 8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              const Text(
                'حدث خطأ في تسجيل بgoogle',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E222B),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,

        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,

            end: Alignment.bottomCenter,

            colors: [Color.fromARGB(255, 14, 59, 184), Color(0xFF071021)],
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),

            child: Column(
              children: [
                const Spacer(flex: 2),

                Image.asset(
                  'asset/sayo.png',

                  width: 250,

                  height: 250,

                  fit: BoxFit.contain,
                ),

                const Spacer(),

                const Text(
                  'مرحباً بكم في SaYo Star',

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 26,

                    fontWeight: FontWeight.bold,

                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'سجل الدخول أو قم بإنشاء حسابك',

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 16,

                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),

                const SizedBox(height: 36),

                SizedBox(
                  width: double.infinity,

                  height: 56,

                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signInWithGoogle,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,

                      foregroundColor: Colors.black,

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),

                    child: _isLoading
                        ? const SizedBox(
                            width: 24,

                            height: 24,

                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,

                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              Image.asset(
                                'asset/google.png',

                                width: 24,

                                height: 24,

                                fit: BoxFit.contain,
                              ),

                              const SizedBox(width: 12),

                              const Text(
                                'تسجيل الدخول بواسطة جوجل',

                                style: TextStyle(
                                  fontSize: 16,

                                  fontWeight: FontWeight.w600,

                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const Spacer(flex: 2),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsAndConditions(),
                      ),
                    );
                  },

                  child: Text(
                    'سياسة الخصوصية وشروط الخدمة',

                    style: TextStyle(
                      fontSize: 13,

                      color: Colors.white.withValues(alpha: 0.5),

                      decoration: TextDecoration.underline,

                      decorationColor: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
