import 'package:flutter/material.dart';
import 'admin_in_kind.dart';

class DonationRequestsPage extends StatelessWidget {
  const DonationRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Donation Requests',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 209, 14, 14),
            ),
          ),
        ),
        const Expanded(
          child: InKindDonationRequestsTab(),
        ),
      ],
    );
  }
}