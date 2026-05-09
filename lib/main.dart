import 'package:flutter/material.dart';
import 'package:oman_legacy_app/screens/splash_screen.dart';
import 'package:oman_legacy_app/supabase_config.dart';

// Theme Mode
final ValueNotifier<ThemeMode> themeNotifier =
    ValueNotifier(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SupabaseConfig.initialize();
    print("✅ Supabase Initialized");
  } catch (e) {
    print("❌ Supabase Error: $e");
  }

  runApp(const OmanLegacyApp());
}

class OmanLegacyApp extends StatelessWidget {
  const OmanLegacyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          title: "Oman Legacy",

          locale: const Locale('en'),
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],

          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.teal,
            scaffoldBackgroundColor: Colors.grey[100],
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.teal,
          ),

          themeMode: currentMode,

          home: const SplashScreen(),
        );
      },
    );
  }
}