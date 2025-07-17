import 'package:flutter/material.dart';
import 'sample_data.dart';
import 'donation_chart.dart';
import 'donation_card.dart';


class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  int getTotalDonations() {
    return sampleDonations.fold(0, (sum, donation) => sum + donation.quantity);
  }

  int getUpcomingSchedules() {
    return sampleDonations.where((d) => d.schedule.isAfter(DateTime.now())).length;
  }

  String getTopCategory() {
    final Map<String, int> countByCategory = {};
    for (var d in sampleDonations) {
      countByCategory[d.category] = (countByCategory[d.category] ?? 0) + d.quantity;
    }
    var sorted = countByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.isNotEmpty ? sorted.first.key : "N/A";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('lasac.jpeg', height: 32),
            SizedBox(width: 10,),
            Text("Dashboard"),
          ]
        ),
      ),

      backgroundColor: Colors.grey[100],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatCard("Total Items Donated", getTotalDonations().toString()),
          const SizedBox(height: 12),
          _buildStatCard("Upcoming Schedules", getUpcomingSchedules().toString()),
          const SizedBox(height: 12),
          _buildStatCard("Top Category", getTopCategory()),
          const SizedBox(height: 24),
          const Text("Recent Donations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...sampleDonations.map((donation) => DonationCard(donation: donation)),
          const SizedBox(height: 20),
          const  DonationChart(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
