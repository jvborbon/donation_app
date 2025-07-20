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

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dashboardTile('Total Pending Donations', pendingInKind, Icons.hourglass_empty, Colors.orange),
                  _dashboardTile('Total Successful Donations', deliveredInKind, Icons.check_circle, Colors.green),
                  FutureBuilder<int>(
                    future: _getTotalInKindQuantityFromInventory(),
                    builder: (context, qtySnap) => _dashboardTile(
                      'Total In-Kind Received',
                      qtySnap.data ?? 0,
                      Icons.card_giftcard,
                      Colors.blue,
                    ),
                  ),
                  FutureBuilder<double>(
                    future: _getTotalInKindValue(),
                    builder: (context, valueSnap) => _dashboardTile(
                      'Total Value of In-Kind Donations',
                      '₱${(valueSnap.data ?? 0).toStringAsFixed(2)}',
                      Icons.monetization_on,
                      Colors.green,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
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
      // Get items from the subcollection
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

  Widget _dashboardTile(String label, dynamic value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          '$value',
          style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}