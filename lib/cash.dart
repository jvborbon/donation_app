import 'package:flutter/material.dart';

class CashDonationPage extends StatelessWidget {
  const CashDonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 209, 14, 14),
        title: const Text('In-Kind Donation', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Text('Cash Donation Page Content Here',),
      ),
    );
  }
} 