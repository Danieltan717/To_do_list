import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;

  void _signUp() async {
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match.")),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created. Please log in.")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primary = colorScheme.primary;
    final onPrimary = colorScheme.onPrimary;
    final background = theme.scaffoldBackgroundColor;

    final bool isDark = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light // white status bar icons for dark bg
          : SystemUiOverlayStyle.dark, // dark status bar icons for light bg
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TodoApp",
                    style: TextStyle(
                      color: primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Let’s create you an account",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildTextField(_emailController, "Email", Icons.email_outlined),
                  const SizedBox(height: 16),
                  _buildPasswordField(_passwordController, "Password"),
                  const SizedBox(height: 16),
                  _buildPasswordField(_confirmController, "Confirm Password"),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _signUp,
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: Text.rich(
                        TextSpan(
                          text: "Already have an account? ",
                          children: [
                            TextSpan(
                              text: "Sign In",
                              style: TextStyle(color: primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  // @override
  // Widget build(BuildContext context) {
  //   final theme = Theme.of(context);
  //   final colorScheme = theme.colorScheme;
  //   final primary = colorScheme.primary;
  //   final onPrimary = colorScheme.onPrimary;
  //   final background = theme.scaffoldBackgroundColor;
  //
  //   return Scaffold(
  //     backgroundColor: background,
  //     body: SafeArea(
  //       child: Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
  //         child: SingleChildScrollView(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 "TodoApp",
  //                 style: TextStyle(
  //                   color: primary,
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               const SizedBox(height: 32),
  //               const Text(
  //                 "Sign Up",
  //                 style: TextStyle(
  //                   fontSize: 32,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               const SizedBox(height: 8),
  //               Text(
  //                 "Let’s create you an account",
  //                 style: theme.textTheme.bodyMedium?.copyWith(
  //                   color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
  //                   fontSize: 16,
  //                 ),
  //               ),
  //               const SizedBox(height: 24),
  //
  //               _buildTextField(_emailController, "Email", Icons.email_outlined),
  //               const SizedBox(height: 16),
  //               _buildPasswordField(_passwordController, "Password"),
  //               const SizedBox(height: 16),
  //               _buildPasswordField(_confirmController, "Confirm Password"),
  //
  //               const SizedBox(height: 24),
  //               SizedBox(
  //                 width: double.infinity,
  //                 height: 50,
  //                 child: ElevatedButton(
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: primary,
  //                     foregroundColor: onPrimary,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                   ),
  //                   onPressed: _signUp,
  //                   child: const Text(
  //                     "Sign Up",
  //                     style: TextStyle(fontSize: 16),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: 12),
  //               Center(
  //                 child: GestureDetector(
  //                   onTap: () {
  //                     Navigator.pushReplacement(
  //                       context,
  //                       MaterialPageRoute(builder: (_) => const LoginPage()),
  //                     );
  //                   },
  //                   child: Text.rich(
  //                     TextSpan(
  //                       text: "Already have an account? ",
  //                       children: [
  //                         TextSpan(
  //                           text: "Sign In",
  //                           style: TextStyle(color: primary),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon,
      ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () => setState(() {
            _obscurePassword = !_obscurePassword;
          }),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}








// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'login_page.dart';
//
// class SignUpPage extends StatefulWidget {
//   const SignUpPage({super.key});
//
//   @override
//   State<SignUpPage> createState() => _SignUpPageState();
// }
//
// class _SignUpPageState extends State<SignUpPage> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmController = TextEditingController();
//   bool _obscurePassword = true;
//
//   void _signUp() async {
//     if (_passwordController.text != _confirmController.text) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match.")));
//       return;
//     }
//     try {
//       await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: _emailController.text.trim().toLowerCase(),
//         password: _passwordController.text.trim(),
//       );
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account created. Please log in.")));
//       Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signup failed: $e")));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     const blue = Color(0xFF0DD8EE);
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text("TodoApp", style: TextStyle(color: blue, fontSize: 16, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 32),
//                 const Text("Sign Up", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 8),
//                 const Text("Let’s create you an account", style: TextStyle(fontSize: 16, color: Colors.black54)),
//                 const SizedBox(height: 24),
//
//                 _buildTextField(_emailController, "Email", Icons.email_outlined),
//                 const SizedBox(height: 16),
//                 _buildPasswordField(_passwordController, "Password"),
//                 const SizedBox(height: 16),
//                 _buildPasswordField(_confirmController, "Confirm Password"),
//
//                 const SizedBox(height: 24),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: blue,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     ),
//                     onPressed: _signUp,
//                     child: const Text("Sign Up", style: TextStyle(fontSize: 16)),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Center(
//                   child: GestureDetector(
//                     onTap: () {
//                       Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
//                     },
//                     child: const Text.rich(
//                       TextSpan(
//                         text: "Already have an account? ",
//                         children: [
//                           TextSpan(text: "Sign In", style: TextStyle(color: blue)),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
//     return TextField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }
//
//   Widget _buildPasswordField(TextEditingController controller, String label) {
//     return TextField(
//       controller: controller,
//       obscureText: _obscurePassword,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: const Icon(Icons.lock_outline),
//         suffixIcon: IconButton(
//           icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
//           onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
//         ),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }
// }
