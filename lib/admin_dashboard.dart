import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final inKindRef = FirebaseFirestore.instance.collection('in_kind_donations');
    final cashRef = FirebaseFirestore.instance.collection('cash_donations');

    return FutureBuilder(
      future: Future.wait([
        inKindRef.where('status', isEqualTo: 'pending').get(),
        inKindRef.where('status', isEqualTo: 'verified').get(),
        cashRef.where('status', isEqualTo: 'pending').get(),
        cashRef.where('status', isEqualTo: 'verified').get(),
      ]),
      builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final pendingInKind = snapshot.data![0].docs.length;
        final deliveredInKind = snapshot.data![1].docs.length;
        final pendingCash = snapshot.data![2].docs.length;
        final deliveredCash = snapshot.data![3].docs.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dashboardTile('Total Pending Donations', pendingInKind + pendingCash, Icons.hourglass_empty, Colors.orange),
            _dashboardTile('Total Successful Donations', deliveredInKind + deliveredCash, Icons.check_circle, Colors.green),
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
              future: _getTotalVerifiedCash(),
              builder: (context, cashSnap) => _dashboardTile(
                'Total Cash Received',
                '₱${(cashSnap.data ?? 0).toStringAsFixed(2)}',
                Icons.attach_money,
                Colors.red,
              ),
            ),
          ],
        );
      },
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

  Future<double> _getTotalVerifiedCash() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('cash_donations')
        .where('status', isEqualTo: 'verified')
        .get();
    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc['amount'] ?? 0).toDouble();
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