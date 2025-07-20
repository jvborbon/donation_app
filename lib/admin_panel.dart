import 'package:donation_app_final/admin_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'admin_donationreq.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  int _selectedIndex = 0;
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

  final List<Widget> _pages = [
    AdminDashboard(),
    DonationRequestsPage(),
  ];

  void _onMenuTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 209, 14, 14),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Admin Panel', style: TextStyle(color: Colors.white)),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              color: const Color.fromARGB(255, 209, 14, 14),
              child: UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                accountName: Text(
                  accountName,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(
                  accountEmail,
                  style: const TextStyle(color: Colors.black54),
                ),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.admin_panel_settings, size: 40, color: Color.fromARGB(255, 23, 23, 23)),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard, color: theme.colorScheme.primary),
              title: const Text('Dashboard'),
              onTap: () => _onMenuTap(0),
            ),
            ListTile(
              leading: Icon(Icons.assignment, color: theme.colorScheme.primary),
              title: const Text('Donation Requests'),
              onTap: () => _onMenuTap(1),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: theme.colorScheme.primary),
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
      body: Container(
        color: Colors.white,
        child: _pages[_selectedIndex],
      ),
    );
  }
}