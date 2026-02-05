import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaya/core/routing/router.dart';
import 'package:kaya/core/services/logger_service.dart';
import 'package:kaya/features/share/services/share_receiver_service.dart';
import 'package:kaya/features/sync/services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait on phones (allow rotation on tablets)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const ProviderScope(child: KayaApp()));
}

class KayaApp extends ConsumerWidget {
  const KayaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Initialize services
    ref.watch(loggerServiceProvider);
    ref.watch(shareReceiverServiceProvider);
    ref.watch(syncControllerProvider);

    return MaterialApp.router(
      title: 'Save Button',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }

  // GNOME Brand Colors (https://brand.gnome.org/)
  static const _gnomeBlue = Color(0xFF3584e4);
  static const _gnomeOrange = Color(0xFFFF7800);
  static const _gnomePurple = Color(0xFF9141AC);
  // static const _gnomeGreen = Color(0xFF33D17A); // Available for future use
  static const _gnomeRed = Color(0xFFE01B24);
  static const _gnomeGrey = Color(0xFF77767B);
  static const _gnomeQuiteBlack = Color(0xFF241F31);

  ThemeData _buildLightTheme() {
    final colorScheme = ColorScheme.light(
      primary: _gnomeBlue,
      onPrimary: Colors.white,
      secondary: _gnomePurple,
      onSecondary: Colors.white,
      tertiary: _gnomeOrange,
      onTertiary: Colors.white,
      error: _gnomeRed,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: _gnomeQuiteBlack,
      surfaceContainerHighest: const Color(0xFFF6F5F4),
      outline: _gnomeGrey,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: colorScheme.primary),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    // Dark mode colors (luminance multiplied by 0.85 per GNOME guidelines)
    const darkSurface = Color(0xFF1E1B26); // Darker than Quite Black
    const darkSurfaceContainer = Color(0xFF2D2A36);

    final colorScheme = ColorScheme.dark(
      primary: _gnomeBlue,
      onPrimary: Colors.white,
      secondary: _gnomePurple,
      onSecondary: Colors.white,
      tertiary: _gnomeOrange,
      onTertiary: Colors.white,
      error: _gnomeRed,
      onError: Colors.white,
      surface: darkSurface,
      onSurface: Colors.white,
      surfaceContainerHighest: darkSurfaceContainer,
      outline: _gnomeGrey,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: colorScheme.primary),
        ),
      ),
    );
  }
}
