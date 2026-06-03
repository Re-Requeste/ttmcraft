import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic>? patient;
  final VoidCallback onLogout;

  const ProfileScreen({super.key, this.patient, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    if (patient == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile'), backgroundColor: const Color(0xFF13B6A5)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final String name = patient!['name']?.toString() ?? 'N/A';
    final String email = patient!['email']?.toString() ?? 'N/A';
    final String treatment = patient!['treatment_type']?.toString() ?? 'N/A';
    final String status = patient!['status']?.toString() ?? 'N/A';
    final String progress = '${patient!['progress'] ?? 0}%';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF13B6A5),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF13B6A5),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          _infoCard('Full Name', name, Icons.person),
          _infoCard('Email', email, Icons.email),
          _infoCard('Treatment', treatment, Icons.medical_services),
          _infoCard('Status', status, Icons.info),
          _infoCard('Progress', progress, Icons.percent),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onLogout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF13B6A5)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(value),
      ),
    );
  }
}