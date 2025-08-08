import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../viewmodels/auth_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return "👤";
    final names = name.trim().split(" ");
    if (names.length == 1) return names.first[0].toUpperCase();
    return (names[0][0] + names[1][0]).toUpperCase();
  }

  Future<String> _getPhoneNumber(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data()?['phone'] ?? 'Not available';
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8DC), // Pale yellow
      appBar: AppBar(
        title: const Text('Your Profile'),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFEBA1),
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: user == null
          ? const Center(child: Text('No user logged in'))
          : FutureBuilder<String>(
              future: _getPhoneNumber(user.uid),
              builder: (context, snapshot) {
                final phone = snapshot.data ?? "Loading...";

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Profile Avatar
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFFFFEBA1),
                        child: Text(
                          _getInitials(user.displayName),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Profile Info Card
                      Card(
                        color: const Color(0xFFFFF2B2),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _profileRow("👤 Name", user.displayName ?? "Not available"),
                              const Divider(),
                              _profileRow("📧 Email", user.email ?? "Not available"),
                              const Divider(),
                              _profileRow(
                                  "📞 Phone",
                                  snapshot.connectionState == ConnectionState.waiting
                                      ? "Loading..."
                                      : phone),
                              const Divider(),
                              _profileRow("🪪 User ID", user.uid),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.logout, color: Colors.black87),
                          label: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.black87),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFEBA1),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            elevation: 3,
                          ),
                          onPressed: () async {
                            await Provider.of<AuthViewModel>(context, listen: false).logout();
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // Info row builder
  Widget _profileRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
