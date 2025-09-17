import 'package:flutter/material.dart';

class AppTheme {
  // Color scheme based on the original design
  static const Color primaryColor = Color(0xFF77B5FE); // Soft Blue
  static const Color accentColor = Color(0xFFF0E68C); // Pale Yellow
  static const Color backgroundColor = Color(0xFFF0F4F8); // Very light blue-gray
  
  static const Color darkBackgroundColor = Color(0xFF1A1A1A);
  static const Color darkSurfaceColor = Color(0xFF2D2D2D);
  static const Color darkPrimaryColor = Color(0xFF77B5FE);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: _createMaterialColor(primaryColor),
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: Colors.white.withValues(alpha: 0.8),
      
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.black87,
        onSurface: Colors.black87,
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontFamily: 'PT Sans', fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontFamily: 'PT Sans', fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(fontFamily: 'PT Sans', fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontFamily: 'PT Sans'),
        bodyMedium: TextStyle(fontFamily: 'PT Sans'),
        bodySmall: TextStyle(fontFamily: 'PT Sans'),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: ZoomPageTransitionsBuilder(),
        TargetPlatform.windows: ZoomPageTransitionsBuilder(),
      }),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: _createMaterialColor(darkPrimaryColor),
      primaryColor: darkPrimaryColor,
      scaffoldBackgroundColor: darkBackgroundColor,
      cardColor: darkSurfaceColor.withValues(alpha: 0.7),
      
      colorScheme: const ColorScheme.dark(
        primary: darkPrimaryColor,
        secondary: accentColor,
        surface: darkSurfaceColor,
        onPrimary: Colors.black87,
        onSecondary: Colors.black87,
        onSurface: Colors.white70,
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white70),
        titleTextStyle: TextStyle(
          color: Colors.white70,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      cardTheme: CardThemeData(
        color: darkSurfaceColor.withValues(alpha: 0.7),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryColor,
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontFamily: 'PT Sans', fontWeight: FontWeight.bold, color: Colors.white70),
        headlineMedium: TextStyle(fontFamily: 'PT Sans', fontWeight: FontWeight.bold, color: Colors.white70),
        headlineSmall: TextStyle(fontFamily: 'PT Sans', fontWeight: FontWeight.w600, color: Colors.white70),
        bodyLarge: TextStyle(fontFamily: 'PT Sans', color: Colors.white70),
        bodyMedium: TextStyle(fontFamily: 'PT Sans', color: Colors.white70),
        bodySmall: TextStyle(fontFamily: 'PT Sans', color: Colors.white70),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: ZoomPageTransitionsBuilder(),
        TargetPlatform.windows: ZoomPageTransitionsBuilder(),
      }),
    );
  }

  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = (color.r * 255.0).round() & 0xff,
        g = (color.g * 255.0).round() & 0xff,
        b = (color.b * 255.0).round() & 0xff;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.toARGB32(), swatch);
  }
}