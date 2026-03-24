import 'package:flutter/material.dart';
import 'package:leithmail/presentation/theme/color_theme.dart';

class AppTheme {
  AppTheme._();

  static const _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  static ThemeData _overrides(ThemeData base) => base.copyWith(
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
    ),
    dividerTheme: const DividerThemeData(thickness: 0.5, space: 0),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(shape: _shape),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(shape: _shape),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(shape: _shape),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    drawerTheme: const DrawerThemeData(
      shape: RoundedRectangleBorder(),
      endShape: RoundedRectangleBorder(),
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  static ThemeData light(TextTheme textTheme) =>
      _overrides(ColorTheme(textTheme).light());

  static ThemeData dark(TextTheme textTheme) =>
      _overrides(ColorTheme(textTheme).dark());
}
