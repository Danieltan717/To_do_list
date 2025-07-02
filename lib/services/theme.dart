//https://medium.com/@blup-tool/learn-how-to-implement-dark-mode-and-light-mode-in-your-flutter-app-f90df3f9cdc8
import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: Colors.deepPurple,        // main color
    secondary: Colors.deepPurpleAccent, // accent color
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.deepPurple,
    foregroundColor: Colors.white,
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: Colors.grey,
    secondary: Colors.deepPurpleAccent,
  ),
);
