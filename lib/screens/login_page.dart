import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    }
  }

  void _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email first.")),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset email sent.")),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primary = colorScheme.primary;
    final background = theme.scaffoldBackgroundColor;

    // Determine appropriate brightness
    final bool isDark = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light // white status bar icons for dark background
          : SystemUiOverlayStyle.dark, // dark status bar icons for light background
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
                    "Log In",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Login to Todo App",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildTextField(_emailController, "Email", Icons.email_outlined),
                  const SizedBox(height: 16),
                  _buildPasswordField(_passwordController, "Password"),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _resetPassword,
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(color: primary),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _login,
                      child: const Text(
                        "Log In",
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
                          MaterialPageRoute(builder: (_) => const SignUpPage()),
                        );
                      },
                      child: Text.rich(
                        TextSpan(
                          text: "Don't have an account? ",
                          children: [
                            TextSpan(
                              text: "Sign Up",
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
  //                 "Log In",
  //                 style: TextStyle(
  //                   fontSize: 32,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               const SizedBox(height: 8),
  //               Text(
  //                 "Login to Todo App",
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
  //
  //               Align(
  //                 alignment: Alignment.centerRight,
  //                 child: TextButton(
  //                   onPressed: _resetPassword,
  //                   child: Text(
  //                     "Forgot Password?",
  //                     style: TextStyle(color: primary),
  //                   ),
  //                 ),
  //               ),
  //
  //               const SizedBox(height: 24),
  //               SizedBox(
  //                 width: double.infinity,
  //                 height: 50,
  //                 child: ElevatedButton(
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: primary,
  //                     foregroundColor: Theme.of(context).colorScheme.onPrimary,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                   ),
  //                   onPressed: _login,
  //                   child: const Text(
  //                     "Log In",
  //                     style: TextStyle(fontSize: 16),
  //                   ),
  //                 ),
  //               ),
  //
  //               const SizedBox(height: 12),
  //               Center(
  //                 child: GestureDetector(
  //                   onTap: () {
  //                     Navigator.pushReplacement(
  //                       context,
  //                       MaterialPageRoute(builder: (_) => const SignUpPage()),
  //                     );
  //                   },
  //                   child: Text.rich(
  //                     TextSpan(
  //                       text: "Don't have an account? ",
  //                       children: [
  //                         TextSpan(
  //                           text: "Sign Up",
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
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
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
