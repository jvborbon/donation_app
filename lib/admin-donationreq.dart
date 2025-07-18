import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonationRequestsPage extends StatelessWidget {
  const DonationRequestsPage({super.key});

  Future<String> _getUserName(String userId) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('donor_accounts')
        .doc(userId)
        .get();
    if (userDoc.exists) {
      final data = userDoc.data();
      return data?['Name'] ?? userId;
    }
    return userId;
  }

  Future<List<Map<String, dynamic>>> _getDonationItems(DocumentReference docRef) async {
    final itemsSnapshot = await docRef.collection('items').get();
    return itemsSnapshot.docs
        .map((itemDoc) => itemDoc.data())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('in_kind_donations')
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No pending donation requests.'));
        }
        final docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final docId = docs[index].id;
            final userId = data['userID'] ?? '';
            final status = data['status'] ?? '';
            final dateSchedule = (data['dateSchedule'] as Timestamp?)?.toDate();
            final docRef = docs[index].reference;

            return FutureBuilder<String>(
              future: _getUserName(userId),
              builder: (context, userSnapshot) {
                final userName = userSnapshot.data ?? userId;
                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: _getDonationItems(docRef),
                  builder: (context, itemsSnapshot) {
                    final items = itemsSnapshot.data ?? [];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person, color: Colors.red, size: 28),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    status.toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: status == 'Pending'
                                      ? Colors.orange
                                      : status == 'Approved'
                                          ? Colors.green
                                          : Colors.red,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(
                                  dateSchedule != null
                                      ? 'Scheduled: ${dateSchedule.toLocal().toString().split(' ')[0]}'
                                      : 'No schedule set',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                            const Divider(height: 24, thickness: 1),
                            Text(
                              'Donation Items',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            ...items.map((item) => Container(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['donation'] ?? '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                            Text(
                                              'Category: ${item['category'] ?? ''}',
                                              style: const TextStyle(fontSize: 13, color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text('Qty: ${item['quantity']}', style: const TextStyle(fontSize: 13)),
                                          Text('Value: ₱${item['value']}', style: const TextStyle(fontSize: 13)),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.check, size: 18),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  label: const Text('Approve'),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('in_kind_donations')
                                        .doc(docId)
                                        .update({'status': 'approved'});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Request approved!')),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.close, size: 18),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  label: const Text('Reject'),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('in_kind_donations')
                                        .doc(docId)
                                        .update({'status': 'rejected'});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Request rejected!')),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.edit_calendar, size: 18),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                  ),
                                  label: const Text('Change Schedule'),
                                  onPressed: () async {
                                    final newDate = await showDatePicker(
                                      context: context,
                                      initialDate: dateSchedule ?? DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(const Duration(days: 365)),
                                    );
                                    if (newDate != null) {
                                      await FirebaseFirestore.instance
                                          .collection('in_kind_donations')
                                          .doc(docId)
                                          .update({'dateSchedule': Timestamp.fromDate(newDate)});
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Schedule updated!')),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}