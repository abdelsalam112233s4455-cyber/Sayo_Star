import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'auth.dart';

class Checkconnect extends StatefulWidget {
  const Checkconnect({super.key});

  @override
  State<Checkconnect> createState() => _CheckconnectState();
}

class _CheckconnectState extends State<Checkconnect> {
  late StreamSubscription<InternetStatus> internetSubscription;

  bool isConnected = false;
  bool isChecking = true;
  bool hasNavigated = false;

  @override
  void initState() {
    super.initState();

    // فحص الاتصال مباشرة عند فتح الصفحة
    _checkInternet();

    // مراقبة الإنترنت باستمرار
    internetSubscription =
        InternetConnection().onStatusChange.listen((status) {
          if (!mounted) return;

          if (status == InternetStatus.connected) {
            _goToAuth();
          } else {
            setState(() {
              isConnected = false;
              isChecking = false;
            });
          }
        });
  }

  // ===============================
  // فحص الإنترنت يدويًا
  // ===============================

  Future<void> _checkInternet() async {
    if (!mounted) return;

    setState(() {
      isChecking = true;
    });

    final connected =
    await InternetConnection().hasInternetAccess;

    if (!mounted) return;

    if (connected) {
      _goToAuth();
    } else {
      setState(() {
        isConnected = false;
        isChecking = false;
      });
    }
  }

  // ===============================
  // الانتقال إلى Auth
  // ===============================

  void _goToAuth() {
    if (!mounted || hasNavigated) return;

    hasNavigated = true;

    setState(() {
      isConnected = true;
      isChecking = false;
    });

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const Auth(),
      ),
          (route) => false,
    );
  }

  @override
  void dispose() {
    internetSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF101114)
          : const Color(0xFFF8F8FA),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 28,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF181A1F)
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF292D35)
                  : const Color(0xFFE8E8ED),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  isDark ? 0.20 : 0.06,
                ),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isChecking
                    ? Container(
                  key: const ValueKey('loading'),
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B2BE2)
                        .withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(17),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Color(0xFF8B2BE2),
                    ),
                  ),
                )
                    : Icon(
                  Icons.wifi_off_rounded,
                  key: const ValueKey('offline'),
                  size: 58,
                  color: const Color(0xFFE53935),
                ),
              ),

              const SizedBox(height: 18),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  isChecking
                      ? 'جاري التحقق من الإنترنت'
                      : 'غير متصل بالإنترنت',
                  key: ValueKey(
                    '$isChecking-$isConnected',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? Colors.white
                        : const Color(0xFF202124),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                isChecking
                    ? 'يرجى الانتظار لحظات...'
                    : 'تحقق من اتصالك بالإنترنت ثم حاول مرة أخرى',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: isDark
                      ? const Color(0xFF8E949F)
                      : const Color(0xFF777B84),
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed:
                  isChecking ? null : _checkInternet,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 20,
                  ),
                  label: const Text(
                    'إعادة المحاولة',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF8B2BE2),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                    const Color(0xFF8B2BE2)
                        .withOpacity(0.35),
                    disabledForegroundColor:
                    Colors.white.withOpacity(0.7),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}