import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'upload_proof.dart';

class InKindDonationsTab extends StatelessWidget {
  const InKindDonationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please log in to view your donation history.'));
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('in_kind_donations')
          .where('userID', isEqualTo: user.uid)
          .where('status', whereIn: ['pending', 'approved'])
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No in-kind donation requests found.'));
        }
        final docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final docId = docs[index].id;
            final status = data['status'] ?? '';
            final dateSchedule = (data['dateSchedule'] as Timestamp?)?.toDate();
            final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
            
            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('in_kind_donations')
                  .doc(docId)
                  .collection('items')
                  .get(),
              builder: (context, itemsSnapshot) {
                List<Map<String, dynamic>> items = [];
                if (itemsSnapshot.hasData) {
                  items = itemsSnapshot.data!.docs
                      .map((doc) => doc.data() as Map<String, dynamic>)
                      .toList();
                }
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Colors.grey[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with title and status badge
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                status == 'pending'
                                    ? 'Pending In-Kind Donation'
                                    : 'Approved In-Kind Donation',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: status == 'approved'
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: status == 'approved' ? Colors.green : Colors.orange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Date information
                        if (dateSchedule != null)
                          Text('Scheduled: ${dateSchedule.toLocal().toString().split(' ')[0]}'),
                        if (createdAt != null)
                          Text('Requested: ${createdAt.toLocal().toString().split(' ')[0]}'),
                        
                        // Items list
                        if (items.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Items:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          ...items.map((item) => Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 2),
                            child: Text(
                              '• ${item['donation'] ?? 'Unknown'} - Qty: ${item['quantity'] ?? 'N/A'}, Value: ₱${item['value'] ?? 'N/A'}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          )),
                        ],
                        
                        // Action buttons based on status
                        if (status == 'pending') ...[
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () => _cancelDonation(context, docId),
                              child: const Text('Cancel Request'),
                            ),
                          ),
                        ],
                        
                        if (status == 'approved') ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () => _uploadProof(context, docId),
                                child: const Text('Upload Proof'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () => _cancelDonation(context, docId),
                                child: const Text('Cancel'),
                              ),
                            ],
                          ),
                        ],
                        
                        // Status messages
                        if (status == 'proof_submitted') ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Proof submitted. Waiting for verification.',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                        
                        if (status == 'verified') ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Donation verified and completed. Thank you!',
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
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
  }
  
  // Cancel donation method
  Future<void> _cancelDonation(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Cancellation'),
        content: const Text('Are you sure you want to cancel this donation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('in_kind_donations')
          .doc(docId)
          .update({
            'status': 'cancelled',
            'cancellation_reason': 'Cancelled by donor'
          });
          
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation request cancelled')),
      );
    }
  }

  Future<void> _uploadProof(BuildContext context, String docId, {String collection = 'in_kind_donations'}) async {
    final result = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) => UploadProofPage(donationId: docId, collection: collection),
      ),
    );

    if (result != null && result.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(docId)
          .update({
            'proof_images': result,
            'status': 'proof_submitted',
            'proof_submittedAt': FieldValue.serverTimestamp(),
          });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proof submitted successfully')),
      );
    }
  }
}