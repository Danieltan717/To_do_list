import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'screens/login_page.dart';
import 'services/theme.dart'; // your lightTheme & darkTheme
//import 'screens/settings_page.dart'; // if you have it here

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load saved theme if any
  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('themeMode');
  switch (savedTheme) {
    case 'light':
      themeNotifier.value = ThemeMode.light;
      break;
    case 'dark':
      themeNotifier.value = ThemeMode.dark;
      break;
    default:
      themeNotifier.value = ThemeMode.system;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: 'Firebase Auth Demo',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: mode,
          home: const LoginPage(),
        );
      },
    );
  }
}

















// Stable
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// import 'screens/login_page.dart';
// import 'services/theme.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'screens/settings_page.dart';
//
// final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Firebase Auth Demo',
// //       theme: ThemeData(
// //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
// //       ),
// //       home: const LoginPage(), // Change this
// //     );
// //   }
// // }
//
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<ThemeMode>(
//       valueListenable: themeNotifier,
//       builder: (context, currentMode, _) {
//         return MaterialApp(
//           title: 'To-do list',
//           //title: 'Firebase Auth Demo',
//           theme: lightTheme,
//           // ✅ uses lightTheme
//           darkTheme: darkTheme,
//           // ✅ uses darkTheme
//           themeMode: ThemeMode.system,
//           // ✅ optional: auto switch by system
//           // home: const SettingsPage(),
//           home: const LoginPage(),
//         );
//       },
//     );
//   }
// }
