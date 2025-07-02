import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist/main.dart'; // adjust import if needed
import 'profile_page.dart'; // make sure this exists

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _showThemeSelector(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, currentMode, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('System Default'),
                  leading: Radio<ThemeMode>(
                    value: ThemeMode.system,
                    groupValue: currentMode,
                    onChanged: (mode) {
                      if (mode != null) {
                        themeNotifier.value = mode;
                        _saveThemeMode(mode);
                        Navigator.pop(ctx);
                      }
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Light Theme'),
                  leading: Radio<ThemeMode>(
                    value: ThemeMode.light,
                    groupValue: currentMode,
                    onChanged: (mode) {
                      if (mode != null) {
                        themeNotifier.value = mode;
                        _saveThemeMode(mode);
                        Navigator.pop(ctx);
                      }
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Dark Theme'),
                  leading: Radio<ThemeMode>(
                    value: ThemeMode.dark,
                    groupValue: currentMode,
                    onChanged: (mode) {
                      if (mode != null) {
                        themeNotifier.value = mode;
                        _saveThemeMode(mode);
                        Navigator.pop(ctx);
                      }
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> settingsOptions = [
      {
        'title': 'Select Theme',
        'icon': Icons.palette,
        'onTap': () => _showThemeSelector(context),
      },
      {
        'title': 'Edit Profile',
        'icon': Icons.person,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          );
        },
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView.builder(
        itemCount: settingsOptions.length,
        itemBuilder: (context, index) {
          final option = settingsOptions[index];
          return ListTile(
            leading: Icon(option['icon']),
            title: Text(option['title']),
            onTap: option['onTap'],
          );
        },
      ),
    );
  }
}








// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:todolist/main.dart';
//
// class SettingsPage extends StatelessWidget {
//   const SettingsPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Settings'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () => _showThemeSelector(context),
//           child: const Text('Select Theme'),
//         ),
//       ),
//     );
//   }
//
//   void _showThemeSelector(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.settings_suggest),
//                 title: const Text('System Default'),
//                 onTap: () async {
//                   themeNotifier.value = ThemeMode.system;
//                   final prefs = await SharedPreferences.getInstance();
//                   await prefs.setString('themeMode', 'system');
//                   Navigator.pop(context);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.light_mode),
//                 title: const Text('Light Theme'),
//                 onTap: () async {
//                   themeNotifier.value = ThemeMode.light;
//                   final prefs = await SharedPreferences.getInstance();
//                   await prefs.setString('themeMode', 'light');
//                   Navigator.pop(context);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.dark_mode),
//                 title: const Text('Dark Theme'),
//                 onTap: () async {
//                   themeNotifier.value = ThemeMode.dark;
//                   final prefs = await SharedPreferences.getInstance();
//                   await prefs.setString('themeMode', 'dark');
//                   Navigator.pop(context);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }