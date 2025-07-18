import 'package:flutter/material.dart';
import 'donation_opt.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonationPage extends StatefulWidget {
  const DonationPage({super.key, required this.title});

  final String title;

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  String accountName = '';
  String accountEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        accountEmail = user.email ?? '';
      });
      // Fetch name from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('donor_accounts')
          .doc(user.uid)
          .get();
      setState(() {
        accountName = doc.data()?['Name'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 209, 14, 14),
        title: const Text('MaLASACkit App', style: TextStyle(color: Colors.white)),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Drawer Header with correct background color
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 209, 14, 14), // Fixed: header color
                ),
                accountName: Text(accountName, style: const TextStyle(color: Colors.white)),
                accountEmail: Text(accountEmail, style: const TextStyle(color: Colors.white)),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Color.fromARGB(255, 23, 23, 23)),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Color.fromARGB(255, 209, 14, 14)),
                title: const Text('Home', style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite, color: Color.fromARGB(255, 209, 14, 14)),
                title: const Text('My Donations', style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications, color: Color.fromARGB(255, 209, 14, 14)),
                title: const Text('Notifications', style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Color.fromARGB(255, 209, 14, 14)),
                title: const Text('Settings', style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Color.fromARGB(255, 209, 14, 14)),
                title: const Text('Logout', style: TextStyle(color: Colors.black)),
                onTap: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm Logout'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                  if (shouldLogout == true) {
                    await FirebaseAuth.instance.signOut();
                    if (mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: Colors.white, // Light background for better contrast
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DonationProgramCard(
              title: 'Defeat Poverty',
              description: 'Help provide daily needs to people in need.',
            ),
            DonationProgramCard(
              title: 'Clean Water Initiative',
              description: 'Support clean water projects in rural areas.',
            ),
            DonationProgramCard(
              title: 'Education for All',
              description: 'Donate to support education for underprivileged kids.',
            ),
            DonationProgramCard(
              title: 'Education for All',
              description: 'Donate to support education for underprivileged kids.',
            ),
          ],
        ),
      ),
    );
  }
}

class DonationProgramCard extends StatelessWidget {
  final String title;
  final String description;

  const DonationProgramCard({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: Colors.grey[50], // Subtle card color for contrast
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.volunteer_activism, color: theme.colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Donate'),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => DonationOptionsDialog(programTitle: title),
            );
          },
        ),
      ),
    );
  }
}
