import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final inKindRef = FirebaseFirestore.instance.collection('in_kind_donations');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Dashboard Overview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 209, 14, 14),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: Future.wait([
              inKindRef.where('status', isEqualTo: 'pending').get(),
              inKindRef.where('status', isEqualTo: 'verified').get(),
            ]),
            builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final pendingInKind = snapshot.data![0].docs.length;
              final deliveredInKind = snapshot.data![1].docs.length;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // First Row
                    Row(
                      children: [
                        Expanded(
                          child: _dashboardCard(
                            'Pending\nDonations', 
                            pendingInKind.toString(), 
                            Icons.hourglass_empty, 
                            Colors.orange
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _dashboardCard(
                            'Successful\nDonations', 
                            deliveredInKind.toString(), 
                            Icons.check_circle, 
                            Colors.green
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Second Row
                    Row(
                      children: [
                        Expanded(
                          child: FutureBuilder<int>(
                            future: _getTotalInKindQuantityFromInventory(),
                            builder: (context, qtySnap) => _dashboardCard(
                              'Items\nReceived',
                              (qtySnap.data ?? 0).toString(),
                              Icons.inventory,
                              Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FutureBuilder<double>(
                            future: _getTotalInKindValue(),
                            builder: (context, valueSnap) => _dashboardCard(
                              'Total\nValue',
                              '₱${_formatNumber(valueSnap.data ?? 0)}',
                              Icons.monetization_on,
                              Colors.purple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }

  Future<int> _getTotalInKindQuantityFromInventory() async {
    final snapshot = await FirebaseFirestore.instance.collection('donation_inventory').get();
    int total = 0;
    for (var doc in snapshot.docs) {
      final qty = int.tryParse(doc['quantity'].toString()) ?? 0;
      total += qty;
    }
    return total;
  }

  Future<double> _getTotalInKindValue() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('in_kind_donations')
        .where('status', isEqualTo: 'verified')
        .get();
    
    double total = 0;
    
    for (var doc in snapshot.docs) {
      final itemsSnapshot = await FirebaseFirestore.instance
          .collection('in_kind_donations')
          .doc(doc.id)
          .collection('items')
          .get();
      
      for (var itemDoc in itemsSnapshot.docs) {
        final value = double.tryParse(itemDoc['value'].toString()) ?? 0;
        total += value;
      }
    }
    
    return total;
  }

  Widget _dashboardCard(String label, String value, IconData icon, Color color) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with icon and live indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Value
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}