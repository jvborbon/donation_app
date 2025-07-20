import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please log in to view your dashboard.'));
    }

    // Queries
    final inKindRef = FirebaseFirestore.instance
        .collection('in_kind_donations')
        .where('userID', isEqualTo: user.uid);
    final cashRef = FirebaseFirestore.instance
        .collection('cash_donations')
        .where('userID', isEqualTo: user.uid);

    return FutureBuilder(
      future: Future.wait([
        inKindRef.where('status', isEqualTo: 'pending').get(),
        inKindRef.where('status', isEqualTo: 'verified').get(),
        cashRef.where('status', isEqualTo: 'pending').get(),
        cashRef.where('status', isEqualTo: 'approved').get(),
      ]),
      builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final pendingInKind = snapshot.data![0].docs.length;
        final deliveredInKind = snapshot.data![1].docs.length;
        final pendingCash = snapshot.data![2].docs.length;
        final deliveredCash = snapshot.data![3].docs.length;

        // Calculate total cash given
        double totalCash = 0;
        for (var doc in snapshot.data![3].docs) {
          totalCash += (doc['amount'] ?? 0).toDouble();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dashboardTile('Pending Donations', pendingInKind + pendingCash, Icons.hourglass_empty, Colors.orange),
            _dashboardTile('Successful Donations', deliveredInKind + deliveredCash, Icons.check_circle, Colors.green),
            // For total in-kind quantity, use a separate FutureBuilder:
            FutureBuilder<int>(
              future: _getTotalInKindQuantity(snapshot.data![1].docs),
              builder: (context, qtySnap) => _dashboardTile(
                'Total In-Kind Delivered',
                qtySnap.data ?? 0,
                Icons.card_giftcard,
                Colors.blue,
              ),
            ),
            _dashboardTile('Total Cash Given', '₱${totalCash.toStringAsFixed(2)}', Icons.attach_money, Colors.red),
          ],
        );
      },
    );
  }

  Future<int> _getTotalInKindQuantity(List<QueryDocumentSnapshot> deliveredDocs) async {
    int total = 0;
    for (var doc in deliveredDocs) {
      final items = await doc.reference.collection('items').get();
      for (var item in items.docs) {
        total += (item['quantity'] ?? 0) as int;
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