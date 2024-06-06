import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeColors {
  final Brightness brightness;
  final Color primary;

  final Color secondary;
  final Color tertiary;
  final Color surface;
  final Color background;
  final Color offset;

  ThemeColors({
    required this.brightness,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.surface,
    required this.background,
    required this.offset,
  });
}

final lightTheme = ThemeColors(
  brightness: Brightness.light,
  primary: const Color.fromARGB(255, 48, 184, 100),
  secondary: Colors.white,
  tertiary: Colors.white,
  surface: Colors.white,
  background: const Color.fromARGB(255, 216, 216, 216),
  offset: Colors.white,
);

final darkTheme = ThemeColors(
  brightness: Brightness.dark,
  primary: const Color.fromARGB(255, 48, 184, 100),
  secondary: const Color.fromARGB(255, 36, 27, 47),
  tertiary: const Color.fromARGB(255, 36, 27, 47),
  surface: const Color.fromARGB(255, 36, 27, 47),
  background: const Color.fromARGB(255, 38, 35, 53),
  offset: const Color.fromARGB(255, 36, 27, 47),
);

const heatMapColorPaletteLight = [
  Color.fromARGB(25, 48, 184, 100), // 0
  Color.fromARGB(50, 48, 184, 100), // 100
  Color.fromARGB(75, 48, 184, 100), // 200
  Color.fromARGB(100, 48, 184, 100), // 300
  Color.fromARGB(125, 48, 184, 100), // 400
  Color.fromARGB(150, 48, 184, 100), // 500
  Color.fromARGB(175, 48, 184, 100), // 600
  Color.fromARGB(200, 48, 184, 100), // 700
  Color.fromARGB(225, 48, 184, 100), // 800
  Color.fromARGB(255, 48, 184, 100), // 900
];

const heatMapColorPaletteDark = [
  Color.fromARGB(25, 66, 49, 86), // 0
  Color.fromARGB(50, 66, 49, 86), // 100
  Color.fromARGB(75, 66, 49, 86), // 200
  Color.fromARGB(100, 66, 49, 86), // 300
  Color.fromARGB(125, 66, 49, 86), // 400
  Color.fromARGB(150, 66, 49, 86), // 500
  Color.fromARGB(175, 66, 49, 86), // 600
  Color.fromARGB(200, 66, 49, 86), // 700
  Color.fromARGB(225, 66, 49, 86), // 800
  Color.fromARGB(255, 66, 49, 86), // 900
];

const heatMapColorPaletteMonochrome = [
  Color.fromARGB(25, 51, 51, 51), // 0
  Color.fromARGB(50, 51, 51, 51), // 100
  Color.fromARGB(75, 51, 51, 51), // 200
  Color.fromARGB(100, 51, 51, 51), // 300
  Color.fromARGB(125, 51, 51, 51), // 400
  Color.fromARGB(150, 51, 51, 51), // 500
  Color.fromARGB(175, 51, 51, 51), // 600
  Color.fromARGB(200, 51, 51, 51), // 700
  Color.fromARGB(225, 51, 51, 51), // 800
  Color.fromARGB(255, 51, 51, 51), // 900
];

ThemeData mockerizeLightTheme = mockerizeThemeGenerator(lightTheme);
ThemeData mockerizeDarkTheme = mockerizeThemeGenerator(darkTheme);

ThemeData mockerizeThemeGenerator(ThemeColors themeColors) {
  return ThemeData(
    useMaterial3: true,
    primaryColor: themeColors.primary,
    scaffoldBackgroundColor: themeColors.background,
    colorScheme: ColorScheme.fromSeed(
      brightness: themeColors.brightness,
      seedColor: themeColors.primary,
      primary: themeColors.primary,
      primaryContainer: themeColors.background,
      surface: themeColors.surface,
      secondary: themeColors.secondary,
      tertiary: themeColors.offset,
    ),
    inputDecorationTheme: const InputDecorationTheme(),
    textTheme: TextTheme(
      displayLarge: const TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.bold,
      ),
      // ···
      titleLarge: GoogleFonts.robotoCondensed(
        color: themeColors.primary,
        fontSize: 30,
        fontStyle: FontStyle.normal,
      ),
      bodyMedium: GoogleFonts.robotoCondensed(),
      displaySmall: GoogleFonts.robotoCondensed(),
      // labelLarge: GoogleFonts.robotoCondensed(
      //   // Button text
      //   color: themeColors.primary,
      //   fontStyle: FontStyle.normal,
      // ),
    ),
    // buttonTheme: ButtonThemeData(),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: themeColors.offset,
      selectedIconTheme: IconThemeData(
        color: themeColors.primary,
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: themeColors.offset,
      indicatorColor: themeColors.primary.withAlpha(255),
      selectedIconTheme: IconThemeData(
        color: themeColors.offset,
      ),
    ),
    bottomAppBarTheme: BottomAppBarTheme(
      color: themeColors.offset,
    ),
    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: themeColors.offset,
      collapsedBackgroundColor: themeColors.surface,
      shape: const Border(),
    ),
    cardTheme: CardTheme(
      color: themeColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
