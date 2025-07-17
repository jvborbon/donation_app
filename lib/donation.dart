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
        title: Text('Home', style: TextStyle(color: Color.fromARGB(255, 236, 231, 231))),
      ),
      drawer: Drawer(
        child: Container(
          color: const Color.fromARGB(255, 209, 14, 14),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                color: Colors.white,
                child: UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  accountName: Text(accountName, style: const TextStyle(color: Colors.black)),
                  accountEmail: Text(accountEmail, style: const TextStyle(color: Colors.black54)),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Color.fromARGB(255, 23, 23, 23)),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.white),
                title: const Text('Home', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite, color: Colors.white),
                title: const Text('My Donations', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.white),
                title: const Text('Settings', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text('Logout', style: TextStyle(color: Colors.white)),
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
                      ); // Route to your login page
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: ListView(
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
        ],
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.volunteer_activism, color: const Color.fromARGB(255, 209, 14, 14)),
        title: Text(title),
        subtitle: Text(description),
        trailing: ElevatedButton(
          child: Text('Donate'),
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
