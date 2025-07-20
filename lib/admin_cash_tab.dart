import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CashDonationRequestsTab extends StatelessWidget {
  const CashDonationRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('cash_donations')
          .where('status', whereIn: ['pending', 'approved', 'proof_submitted'])
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No cash donation requests.'));
        }
        final docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final docId = docs[index].id;
            final userID = data['userID'] ?? '';
            final status = data['status'] ?? '';
            final amount = data['amount'] ?? '';
            final scheduledDateTime = (data['scheduledDateTime'] as Timestamp?)?.toDate();
            final proofImages = (data['proof_images'] as List?)?.cast<String>() ?? [];

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('User: $userID', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Amount: ₱$amount'),
                    if (scheduledDateTime != null)
                      Text('Scheduled: ${scheduledDateTime.toLocal().toString().split(' ')[0]}'),
                    Text('Status: $status'),
                    if (status == 'pending')
                      Row(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('cash_donations')
                                  .doc(docId)
                                  .update({'status': 'approved'});
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Request approved!')),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.close),
                            label: const Text('Reject'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('cash_donations')
                                  .doc(docId)
                                  .update({'status': 'rejected'});
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Request rejected!')),
                              );
                            },
                          ),
                        ],
                      ),
                    if (status == 'proof_submitted' && proofImages.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          const Text('Proof of Cash Delivery:', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(
                            height: 120,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: proofImages.map((url) {
                                return Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Image.network(url, width: 100, height: 100, fit: BoxFit.cover),
                                );
                              }).toList(),
                            ),
                          ),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.check),
                                label: const Text('Verify'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('cash_donations')
                                      .doc(docId)
                                      .update({'status': 'verified'});
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Cash donation verified!')),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.close),
                                label: const Text('Reject'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('cash_donations')
                                      .doc(docId)
                                      .update({'status': 'rejected'});
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Proof rejected!')),
                                  );
                                },
                              ),
                            ],
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
  }
}