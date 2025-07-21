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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'My Donation Summary',
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
              final successfulInKind = snapshot.data![1].docs.length;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Pending Donations
                    _dashboardListItem(
                      'Pending Donations',
                      pendingInKind.toString(),
                      Icons.hourglass_empty,
                      Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    
                    // Successful Donations
                    _dashboardListItem(
                      'Successful Donations',
                      successfulInKind.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                    const SizedBox(height: 12),
                    
                    // Total Items Donated
                    FutureBuilder<int>(
                      future: _getTotalInKindQuantity(snapshot.data![1].docs),
                      builder: (context, qtySnap) => _dashboardListItem(
                        'Total Items Donated',
                        (qtySnap.data ?? 0).toString(),
                        Icons.inventory,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Total Value Donated
                    FutureBuilder<double>(
                      future: _getTotalInKindValue(snapshot.data![1].docs),
                      builder: (context, valueSnap) => _dashboardListItem(
                        'Total Value Donated',
                        '₱${_formatNumber(valueSnap.data ?? 0)}',
                        Icons.monetization_on,
                        Colors.purple,
                      ),
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

  Future<int> _getTotalInKindQuantity(List<QueryDocumentSnapshot> deliveredDocs) async {
    int total = 0;
    for (var doc in deliveredDocs) {
      final items = await doc.reference.collection('items').get();
      for (var item in items.docs) {
        final itemData = item.data();
        // Fix: Make sure we're getting the quantity correctly
        final quantity = itemData['quantity'];
        if (quantity != null) {
          // Handle both int and string quantities
          if (quantity is int) {
            total += quantity;
          } else if (quantity is String) {
            total += int.tryParse(quantity) ?? 0;
          } else {
            // Try to convert any other type to int
            total += int.tryParse(quantity.toString()) ?? 0;
          }
        }
      }
    }
    return total;
  }

  Future<double> _getTotalInKindValue(List<QueryDocumentSnapshot> deliveredDocs) async {
    double total = 0;
    for (var doc in deliveredDocs) {
      final items = await doc.reference.collection('items').get();
      for (var item in items.docs) {
        final itemData = item.data();
        final value = double.tryParse(itemData['value'].toString()) ?? 0;
        total += value;
      }
    }
    return total;
  }

  Widget _dashboardListItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // Title
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Value
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}