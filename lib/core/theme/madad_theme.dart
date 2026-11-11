import 'package:flutter/material.dart';

abstract final class MadadColors {
  static const orange = Color(0xFFE86B2F);
  static const orangeLight = Color(0xFFF38B56);
  static const orangeDark = Color(0xFFB94718);
  static const orangeSurface = Color(0xFF2C1E18);
  static const orangePale = Color(0xFF2B1D18);

  // Dark Theme Palette
  static const background = Color(0xFF0B0D12);
  static const surface = Color(0xFF141821);
  static const card = Color(0xFF191F2A);
  static const cardHover = Color(0xFF222A37);

  static const textPrimary = Color(0xFFF0F2F5);
  static const textSecondary = Color(0xFF949EAD);
  static const muted = Color(0xFF949EAD);
  static const ink = Color(0xFFF0F2F5);
  static const canvas = Color(0xFF16181F);
  static const line = Color(0xFF252D3B);
  static const border = Color(0xFF252D3B);

  static const green = Color(0xFF27AE60);
  static const red = Color(0xFFEB5757);
}

abstract final class MadadSpace {
  static const xs = 4.0, sm = 8.0, md = 16.0, lg = 24.0, xl = 32.0;
}

abstract final class MadadRadius {
  static const card = 20.0, field = 14.0, button = 16.0, pill = 99.0;
}

abstract final class MadadTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: MadadColors.background,
        colorScheme: const ColorScheme.dark(
          primary: MadadColors.orange,
          onPrimary: Colors.white,
          secondary: MadadColors.orangeLight,
          onSecondary: Colors.white,
          surface: MadadColors.surface,
          onSurface: MadadColors.textPrimary,
          error: MadadColors.red,
          surfaceTint: Colors.transparent,
        ),
        iconTheme: const IconThemeData(color: MadadColors.orange),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: MadadColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
          titleLarge: TextStyle(
            color: MadadColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
          titleMedium: TextStyle(
            color: MadadColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: TextStyle(color: MadadColors.textPrimary, fontSize: 15),
          bodyMedium: TextStyle(color: MadadColors.textSecondary, fontSize: 13),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: MadadColors.background,
          foregroundColor: MadadColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: MadadColors.orange),
          titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: MadadColors.textPrimary),
        ),
        cardTheme: CardThemeData(
          color: MadadColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MadadRadius.card),
            side: const BorderSide(color: MadadColors.border, width: 1),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: MadadColors.orange,
          textColor: MadadColors.textPrimary,
          subtitleTextStyle: TextStyle(color: MadadColors.textSecondary),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          minVerticalPadding: 10,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: MadadColors.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          hintStyle:
              const TextStyle(color: MadadColors.textSecondary, fontSize: 14),
          labelStyle:
              const TextStyle(color: MadadColors.textSecondary, fontSize: 14),
          prefixIconColor: MadadColors.orange,
          suffixIconColor: MadadColors.textSecondary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MadadRadius.field),
            borderSide: const BorderSide(color: MadadColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MadadRadius.field),
            borderSide: const BorderSide(color: MadadColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MadadRadius.field),
            borderSide: const BorderSide(color: MadadColors.orange, width: 1.5),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: MadadColors.surface,
          indicatorColor: MadadColors.orangeSurface,
          elevation: 0,
          height: 72,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: MadadColors.orange);
            }
            return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: MadadColors.textSecondary);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: MadadColors.orange, size: 24);
            }
            return const IconThemeData(
                color: MadadColors.textSecondary, size: 24);
          }),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: MadadColors.surface,
          selectedColor: MadadColors.orangeSurface,
          secondarySelectedColor: MadadColors.orangeSurface,
          disabledColor: MadadColors.surface,
          labelStyle: const TextStyle(color: MadadColors.textSecondary),
          secondaryLabelStyle: const TextStyle(color: MadadColors.orange),
          side: const BorderSide(color: MadadColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MadadRadius.pill),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? MadadColors.orange
                  : MadadColors.textSecondary),
          trackColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? MadadColors.orangeSurface
                  : MadadColors.surface),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: MadadColors.card,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MadadRadius.card),
            side: const BorderSide(color: MadadColors.border),
          ),
          titleTextStyle: const TextStyle(
            color: MadadColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
          contentTextStyle: const TextStyle(
            color: MadadColors.textSecondary,
            fontSize: 14,
            height: 1.45,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: MadadColors.cardHover,
          contentTextStyle: const TextStyle(color: MadadColors.textPrimary),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MadadRadius.field),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: MadadColors.orange,
          linearTrackColor: MadadColors.border,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: MadadColors.orange,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(MadadRadius.button)),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: MadadColors.orange,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(MadadRadius.button)),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: MadadColors.card,
          modalBackgroundColor: MadadColors.card,
          showDragHandle: true,
          surfaceTintColor: Colors.transparent,
        ),
        dividerTheme: const DividerThemeData(
          color: MadadColors.border,
          thickness: 1,
          space: 1,
        ),
      );
}
