import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'firebase_options.dart';
import 'infouser/checkconnect.dart';
import 'theme.dart';

final GlobalKey<NavigatorState> navigatorKey =
GlobalKey<NavigatorState>();

void main() async {
  WidgetsBinding widgetsBinding =
  WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(
    widgetsBinding: widgetsBinding,
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  FlutterNativeSplash.remove();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SaYo Star',

      navigatorKey: navigatorKey,

      themeMode: themeProvider.themeMode,

      // LIGHT THEME
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        canvasColor: const Color(0xFFF8F9FA),
        cardColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B2BE2),
          brightness: Brightness.light,
          primary: const Color(0xFF8B2BE2),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF34343A),
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: const TextStyle(color: Color(0xFF9EA3A8)),
          labelStyle: const TextStyle(color: Color(0xFF666B73)),
          prefixIconColor: const Color(0xFF777C84),
          suffixIconColor: const Color(0xFF777C84),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E4E8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E4E8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF8B2BE2),
              width: 1.5,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B2BE2),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF8B2BE2),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF8B2BE2),
            side: const BorderSide(color: Color(0xFF8B2BE2)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: const Color(0xFF555A63),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE5E6EA),
          thickness: 1,
        ),
        bottomNavigationBarTheme:
        const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF9C27B0),
          unselectedItemColor: Color(0xFF9EA3A8),
          elevation: 12,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF292B30),
          contentTextStyle:
          const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF8B2BE2);
            }
            return const Color(0xFFB8BCC3);
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFFDBC1F2);
            }
            return const Color(0xFFE1E3E7);
          }),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF8B2BE2);
            }
            return Colors.transparent;
          }),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF34343A)),
          bodyMedium: TextStyle(color: Color(0xFF555A63)),
          bodySmall: TextStyle(color: Color(0xFF777C84)),
          titleLarge: TextStyle(
            color: Color(0xFF25262A),
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            color: Color(0xFF34343A),
            fontWeight: FontWeight.w600,
          ),
          titleSmall:
          TextStyle(color: Color(0xFF555A63)),
        ),
      ),

      // DARK THEME
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101114),
        canvasColor: const Color(0xFF101114),
        cardColor: const Color(0xFF181A1F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9C27B0),
          brightness: Brightness.dark,
          primary: const Color(0xFFB44BFF),
          surface: const Color(0xFF181A1F),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF101114),
          foregroundColor: Color(0xFFF1F1F3),
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF181A1F),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1C1E24),
          hintStyle: const TextStyle(color: Color(0xFF858A95)),
          labelStyle: const TextStyle(color: Color(0xFFA2A6AF)),
          prefixIconColor: const Color(0xFF9DA2AC),
          suffixIconColor: const Color(0xFF9DA2AC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF292C34)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF292C34)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFB44BFF),
              width: 1.5,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9C27B0),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFB44BFF),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFB44BFF),
            side: const BorderSide(color: Color(0xFF8D3CC4)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: const Color(0xFFD0D2D7),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF292C34),
          thickness: 1,
        ),
        bottomNavigationBarTheme:
        const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF181A1F),
          selectedItemColor: Color(0xFFB44BFF),
          unselectedItemColor: Color(0xFF858A95),
          elevation: 12,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF292C34),
          contentTextStyle: const TextStyle(
            color: Color(0xFFF1F1F3),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFF181A1F),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titleTextStyle: const TextStyle(
            color: Color(0xFFF1F1F3),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: const TextStyle(
            color: Color(0xFFB5BAC4),
            fontSize: 15,
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFFB44BFF);
            }
            return const Color(0xFF858A95);
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF54256D);
            }
            return const Color(0xFF30333B);
          }),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF9C27B0);
            }
            return const Color(0xFF30333B);
          }),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFF1F1F3)),
          bodyMedium: TextStyle(color: Color(0xFFD0D2D7)),
          bodySmall: TextStyle(color: Color(0xFF9DA2AC)),
          titleLarge: TextStyle(
            color: Color(0xFFF1F1F3),
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            color: Color(0xFFE5E6EA),
            fontWeight: FontWeight.w600,
          ),
          titleSmall:
          TextStyle(color: Color(0xFFB5BAC4)),
        ),
      ),

      home: const Checkconnect(),

      builder: (context, child) {
        return InternetMonitor(
          child: child!,
        );
      },
    );
  }
}

// ========================================
// مراقبة الإنترنت على مستوى التطبيق كله
// ========================================

class InternetMonitor extends StatefulWidget {
  final Widget child;

  const InternetMonitor({
    super.key,
    required this.child,
  });

  @override
  State<InternetMonitor> createState() =>
      _InternetMonitorState();
}

class _InternetMonitorState extends State<InternetMonitor> {
  late StreamSubscription<InternetStatus> internetSubscription;

  bool offlinePageOpened = false;

  @override
  void initState() {
    super.initState();

    internetSubscription =
        InternetConnection().onStatusChange.listen((status) {
          if (status == InternetStatus.disconnected) {
            _handleDisconnected();
          } else if (status == InternetStatus.connected) {
            offlinePageOpened = false;
          }
        });
  }

  void _handleDisconnected() {
    if (offlinePageOpened) return;

    final navigator = navigatorKey.currentState;

    if (navigator == null) return;

    offlinePageOpened = true;

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const Checkconnect(),
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
    return widget.child;
  }
}