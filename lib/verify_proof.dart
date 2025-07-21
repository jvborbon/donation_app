
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class VerifyProofPage extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> donationData;

  const VerifyProofPage({
    super.key,
    required this.docId,
    required this.donationData,
  });

  @override
  Widget build(BuildContext context) {
    final proofImagesBase64 = donationData['proof_images_base64'] as List<dynamic>? ?? [];
    final List<String> base64Images = List<String>.from(proofImagesBase64);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Verify Donation Proof'),
        backgroundColor: Color.fromARGB(255, 209, 14, 14),
      ),
      body: Column(
        children: [
          Expanded(
            child: base64Images.isEmpty
                ? const Center(child: Text('No proof images available'))
                : ListView.builder(
                    itemCount: base64Images.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 4,
                          child: Column(
                            children: [
                              Image.memory(
                                base64Decode(base64Images[index]),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(child: Text('Error loading image'));
                                },
                              ),
                              const SizedBox(height: 8),
                              Text('Proof Image ${index + 1}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: const Text('Reject Proof'),
                  onPressed: () => _rejectProof(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Verify '),
                  onPressed: () => _verifyAndAddToInventory(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _rejectProof(BuildContext context) async {
    final TextEditingController reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rejection Reason'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'Enter reason for rejection',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(reasonController.text.isNotEmpty
                ? reasonController.text
                : 'Proof insufficient'),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (reason != null) {
      await FirebaseFirestore.instance
          .collection('in_kind_donations')
          .doc(docId)
          .update({
            'status': 'approved', // Reset to approved state
            'admin_notes': reason,
          });

      await FirebaseFirestore.instance.collection('notifications').add({
        'userID': donationData['userID'],
        'donationID': docId,
        'title': 'Proof Rejected',
        'message': 'Your donation proof was rejected: $reason. Please submit again.',
        'notif_timestamp': FieldValue.serverTimestamp(),
        'wasRead': false,
      });

      if (!context.mounted) return;
      Navigator.of(context).pop(false);
    }
  }

  Future<void> _verifyAndAddToInventory(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('in_kind_donations')
        .doc(docId)
        .update({
          'status': 'verified',
          'verif_timestamp': FieldValue.serverTimestamp(),
        });

    final itemsSnapshot = await FirebaseFirestore.instance
        .collection('in_kind_donations')
        .doc(docId)
        .collection('items')
        .get();

    for (final item in itemsSnapshot.docs) {
      final itemData = item.data();
      await FirebaseFirestore.instance
          .collection('donation_inventory')
          .add({
            'donation_id': docId,
            'item_name': itemData['donation'],
            'category': itemData['category'],
            'quantity': itemData['quantity'],
            'value': itemData['value'],
            'received_date': FieldValue.serverTimestamp(),
          });
    }

    await FirebaseFirestore.instance.collection('notifications').add({
      'userID': donationData['userID'],
      'donationID': docId,
      'title': 'Donation Verified',
      'message': 'Your donation has been verified and added to our inventory. Thank you!',
      'notif_timestamp': FieldValue.serverTimestamp(),
      'wasRead': false,
    });

    if (!context.mounted) return;
    Navigator.of(context).pop(true);
  }
}