import 'package:flutter/material.dart';
import 'donation_model.dart';
import 'package:intl/intl.dart';

class DonationCard extends StatelessWidget {
  final Donation donation;

  const DonationCard({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM d, yyyy').format(donation.schedule);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(donation.item),
        subtitle: Text("Category: ${donation.category}\nScheduled on: $formattedDate"),
        trailing: Text("x${donation.quantity}"),
      ),
    );
  }
}
