import 'package:flutter/material.dart';
import 'in_kind.dart';
import 'cash.dart';


class DonationOptionsDialog extends StatelessWidget {
  final String programTitle;

  const DonationOptionsDialog({super.key, required this.programTitle});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      child: Container(
        width: 400, 
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Donate to "$programTitle"', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.attach_money, color: Color.fromARGB(255, 209, 14, 14)),
              title: const Text('Cash Donation'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CashDonationPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.card_giftcard, color: Color.fromARGB(255, 209, 14, 14)),
              title: const Text('In-Kind Donation'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InKindDonationPage()),
                );
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                child: const Text('Cancel', style: TextStyle(color: Color.fromARGB(255, 209, 14, 14))),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}