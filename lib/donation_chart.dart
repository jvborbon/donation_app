import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'sample_data.dart';

class DonationChart extends StatelessWidget {
  const DonationChart({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> categoryTotals = {};

    for (var donation in sampleDonations) {
      categoryTotals[donation.category] =
          (categoryTotals[donation.category] ?? 0) + donation.quantity;
    }

    final List<String> categories = categoryTotals.keys.toList();
    final List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final value = categoryTotals[category]!;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              color: _getCategoryColor(category),
              width: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Donations by Category",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: categoryTotals.values.reduce((a, b) => a > b ? a : b) + 5,
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString(),
                              style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < categories.length) {
                            return Text(
                              categories[index],
                              style: const TextStyle(fontSize: 12),
                            );
                          } else {
                            return const SizedBox();
                          }
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Clothing':
        return Colors.blueAccent;
      case 'Food':
        return Colors.orangeAccent;
      case 'Education':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
