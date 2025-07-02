import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordFakeController = TextEditingController(text: '********');

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _refreshUser();
    _emailController.text = user.email ?? 'No email found';
  }

  // Dispose controllers when the widget is removed from the tree
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nicknameController.dispose();
    _passwordFakeController.dispose();
    _emailController.dispose(); // Dispose the email controller
    super.dispose();
  }


  Future<void> _loadProfile() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      _firstNameController.text = data['firstName'] ?? '';
      _lastNameController.text = data['lastName'] ?? '';
      _nicknameController.text = data['nickname'] ?? '';
    }
  }

  Future<void> _refreshUser() async {
    await user.reload();
    setState(() {
      // Update email controller in case user's email was changed externally
      _emailController.text = user.email ?? 'No email found';
    });
  }

  Future<void> _saveProfile() async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'nickname': _nicknameController.text.trim(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );

    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _changePassword() async {
    final newPasswordController = TextEditingController();
    final confirmController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
              ),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newPass = newPasswordController.text.trim();
                final confirmPass = confirmController.text.trim();
                if (newPass != confirmPass) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Passwords do not match')));
                  return;
                }
                try {
                  await user.updatePassword(newPass);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password changed')));
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _firstNameController,
              enabled: _isEditing,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lastNameController,
              enabled: _isEditing,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nicknameController,
              enabled: _isEditing,
              decoration: const InputDecoration(labelText: 'Nickname'),
            ),
            const SizedBox(height: 12),
            // Use the _emailController here
            TextField(
              controller: _emailController, // Assign the controller
              enabled: false, // Keep it disabled as it's read-only
              decoration: const InputDecoration(
                labelText: 'Email',
                // No need for hintText when using a controller to display value
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordFakeController,
              enabled: false,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 12),
            if (_isEditing)
              ElevatedButton.icon(
                icon: const Icon(Icons.lock_reset),
                label: const Text('Change Password'),
                onPressed: _changePassword,
              ),
          ],
        ),
      ),
    );
  }
}















// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});
//
//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }
//
// class _ProfilePageState extends State<ProfilePage> {
//   final user = FirebaseAuth.instance.currentUser!;
//   final _firstNameController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   final _nicknameController = TextEditingController();
//   bool _isEditing = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadProfile();
//   }
//
//   Future<void> _loadProfile() async {
//     final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
//     if (doc.exists) {
//       final data = doc.data()!;
//       _firstNameController.text = data['firstName'] ?? '';
//       _lastNameController.text = data['lastName'] ?? '';
//       _nicknameController.text = data['nickname'] ?? '';
//     }
//   }
//
//   Future<void> _saveProfile() async {
//     await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//       'firstName': _firstNameController.text.trim(),
//       'lastName': _lastNameController.text.trim(),
//       'nickname': _nicknameController.text.trim(),
//     }, SetOptions(merge: true));
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
//     setState(() {
//       _isEditing = false;
//     });
//   }
//
//   Future<void> _changePassword() async {
//     final newPasswordController = TextEditingController();
//     final confirmController = TextEditingController();
//
//     await showDialog(
//       context: context,
//       builder: (_) {
//         return AlertDialog(
//           title: const Text('Change Password'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: newPasswordController,
//                 obscureText: true,
//                 decoration: const InputDecoration(labelText: 'New Password'),
//               ),
//               TextField(
//                 controller: confirmController,
//                 obscureText: true,
//                 decoration: const InputDecoration(labelText: 'Confirm Password'),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 final newPass = newPasswordController.text.trim();
//                 final confirmPass = confirmController.text.trim();
//                 if (newPass != confirmPass) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Passwords do not match')));
//                   return;
//                 }
//                 try {
//                   await user.updatePassword(newPass);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Password changed')));
//                   Navigator.pop(context);
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Error: $e')));
//                 }
//               },
//               child: const Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         actions: [
//           if (!_isEditing)
//             IconButton(
//               icon: const Icon(Icons.edit),
//               onPressed: () => setState(() => _isEditing = true),
//             )
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             TextField(
//               controller: _firstNameController,
//               enabled: _isEditing,
//               decoration: const InputDecoration(labelText: 'First Name'),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _lastNameController,
//               enabled: _isEditing,
//               decoration: const InputDecoration(labelText: 'Last Name'),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _nicknameController,
//               enabled: _isEditing,
//               decoration: const InputDecoration(labelText: 'Nickname'),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               enabled: false,
//               decoration: InputDecoration(
//                 labelText: 'Email',
//                 hintText: user.email ?? '',
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               enabled: false,
//               obscureText: true,
//               decoration: const InputDecoration(
//                 labelText: 'Password',
//                 hintText: '********',
//               ),
//             ),
//             const SizedBox(height: 16),
//             if (_isEditing)
//               ElevatedButton(
//                 onPressed: _saveProfile,
//                 child: const Text('Save Profile'),
//               ),
//             const SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: _changePassword,
//               child: const Text('Change Password'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
