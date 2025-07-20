import 'package:flutter/material.dart';
import 'donation_opt.dart';

class ProgramsPage extends StatelessWidget {
  const ProgramsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, bottom: 12.0),
                    child: Text(
                      'Donation Programs',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
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
                    description:
                        'Donate to support education for underprivileged kids.',
                  ),
                  DonationProgramCard(
                    title: 'Build Resillient Communities',
                    description:
                        'Provide support for every community.',
                  ),
                ],
              ),
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
    return Card(
      color: Colors.grey[50],
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.volunteer_activism, color: const Color.fromARGB(255, 209, 14, 14), size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 209, 14, 14),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                elevation: 0,
              ),
              child: const Text('Donate'),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: true, // Allow tap outside to dismiss
                  builder: (context) => DonationOptionsDialog(programTitle: title),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
