import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'scheduling.dart';
import 'verify_proof.dart';

Future<String> getUserName(String userId) async {
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

Future<List<Map<String, dynamic>>> getDonationItems(DocumentReference docRef) async {
  final itemsSnapshot = await docRef.collection('items').get();
  return itemsSnapshot.docs
      .map((itemDoc) => itemDoc.data())
      .toList();
}

class InKindDonationRequestsTab extends StatelessWidget {
  const InKindDonationRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('in_kind_donations')
          .where('status', whereIn: ['pending', 'proof_submitted'])
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
              future: getUserName(userId),
              builder: (context, userSnapshot) {
                final userName = userSnapshot.data ?? userId;
                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: getDonationItems(docRef),
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
                                if (status == 'pending') ...[
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(40, 40),
                                      shape: const CircleBorder(),
                                    ),
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('in_kind_donations')
                                          .doc(docId)
                                          .update({'status': 'approved'});
                                      await FirebaseFirestore.instance.collection('notifications').add({
                                        'userID': userId,
                                        'donationID': docId,
                                        'title': 'Donation Approved',
                                        'message': 'Your donation request has been approved!',
                                        'notif_timestamp': FieldValue.serverTimestamp(),
                                        'wasRead': false,
                                      });
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Request approved!')),
                                      );
                                    },
                                    child: const Icon(Icons.check, size: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(40, 40),
                                      shape: const CircleBorder(),
                                    ),
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('in_kind_donations')
                                          .doc(docId)
                                          .update({'status': 'rejected'});
                                      await FirebaseFirestore.instance.collection('notifications').add({
                                        'userID': userId,
                                        'donationID': docId,
                                        'title': 'Donation Rejected',
                                        'message': 'Your donation request has been rejected. Please check the details.',
                                        'notif_timestamp': FieldValue.serverTimestamp(),
                                        'wasRead': false,
                                      });
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Request rejected!')),
                                      );
                                    },
                                    child: const Icon(Icons.close, size: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(40, 40),
                                      shape: const CircleBorder(),
                                    ),
                                    onPressed: () async {
                                      final newDateTime = await showDialog<DateTime>(
                                        context: context,
                                        builder: (_) => SchedulingDialog(initialDate: dateSchedule),
                                      );
                                      if (!context.mounted) return;
                                      if (newDateTime != null) {
                                        await FirebaseFirestore.instance
                                            .collection('in_kind_donations')
                                            .doc(docId)
                                            .update({'dateSchedule': Timestamp.fromDate(newDateTime)});
                                        await FirebaseFirestore.instance.collection('notifications').add({
                                          'userID': userId,
                                          'donationID': docId,
                                          'title': 'Changed Schedule',
                                          'message': 'Your donation request has been rescheduled to ${newDateTime.toLocal().toString().split(' ')[0]} at ${TimeOfDay.fromDateTime(newDateTime).format(context)}.',
                                          'notif_timestamp': FieldValue.serverTimestamp(),
                                          'wasRead': false,
                                        });
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Schedule updated!')),
                                        );
                                      }
                                    },
                                    child: const Icon(Icons.edit_calendar, size: 18),
                                  ),
                                ],
                                if (status == 'proof_submitted') ...[
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(40, 40),
                                      shape: const CircleBorder(),
                                    ),
                                    onPressed: () async {
                                      // View and verify proof
                                      final result = await Navigator.push<bool>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => VerifyProofPage(
                                            docId: docId,
                                            donationData: data,
                                          ),
                                        ),
                                      );

                                      if (!context.mounted) return;

                                      if (result == true) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Donation verified and added to inventory')),
                                        );
                                      }
                                    },
                                    child: const Icon(Icons.verified, size: 18),
                                  ),
                                ],
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