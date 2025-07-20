import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'scheduling.dart';

class CashDonationPage extends StatefulWidget {
  const CashDonationPage({super.key});

  @override
  State<CashDonationPage> createState() => _CashDonationPageState();
}

class _CashDonationPageState extends State<CashDonationPage> {
  int? selectedAmount;
  final List<int> amounts = [500, 1000, 1250, 1500, 2000];
  final TextEditingController otherAmountController = TextEditingController();
  final FocusNode otherAmountFocusNode = FocusNode();

  DateTime? _scheduledDateTime;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    otherAmountController.addListener(_handleManualInput);
  }

  @override
  void dispose() {
    otherAmountController.removeListener(_handleManualInput);
    otherAmountController.dispose();
    otherAmountFocusNode.dispose();
    super.dispose();
  }

  void _onAmountSelected(int amount) {
    setState(() {
      selectedAmount = amount;
      otherAmountController.text = amount.toString();
    });
    FocusScope.of(context).requestFocus(otherAmountFocusNode);
  }

  void _handleManualInput() {
    final input = int.tryParse(otherAmountController.text);
    if (!amounts.contains(input)) {
      setState(() => selectedAmount = null);
    }
  }

  Future<void> _submitDonation() async {
    final amount = int.tryParse(otherAmountController.text) ?? selectedAmount;
    if (amount == null || amount < 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount of at least ₱500.')),
      );
      return;
    }
    if (_scheduledDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set a schedule.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in.");

      await FirebaseFirestore.instance.collection('cash_donations').add({
        'userID': user.uid,
        'amount': amount,
        'scheduledDateTime': Timestamp.fromDate(_scheduledDateTime!),
        'method': 'in_person',
        'status': 'pending',
        'adminRemarks': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isSubmitting = false;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cash-on-Delivery'),
          content: Text(
            'Thank you for pledging ₱$amount.\n\n'
            'Schedule: ${_scheduledDateTime!.toLocal().toString().substring(0, 16)}\n\n'
            'Please prepare your cash donation. Our team will collect it in person.\n\n'
            'You will be notified once your pledge is approved or rescheduled by the admin.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                Navigator.of(context).pop(); // go back to previous page
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit donation: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const CloseButton(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
        elevation: 0,
        title: const Text(
          "Donate Now",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Donation Amount", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: amounts.map((amount) {
                  return GestureDetector(
                    onTap: () => _onAmountSelected(amount),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        color: selectedAmount == amount
                            ? const Color.fromARGB(255, 255, 0, 0)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text("₱$amount", style: const TextStyle(fontSize: 16)),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            const Text("Other Amount"),
            TextField(
              controller: otherAmountController,
              focusNode: otherAmountFocusNode,
              decoration: const InputDecoration(
                prefixText: "₱ ",
                hintText: "Enter your donation amount",
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),

            // Scheduling Section
            Row(
              children: [
                const Icon(Icons.schedule, color: Colors.black54, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _scheduledDateTime == null
                        ? "No schedule set"
                        : "Scheduled: ${_scheduledDateTime!.toLocal().toString().substring(0, 16)}",
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final result = await showDialog<DateTime>(
                      context: context,
                      builder: (context) => const SchedulingDialog(),
                    );
                    if (result != null) {
                      setState(() {
                        _scheduledDateTime = result;
                      });
                    }
                  },
                  child: const Text("Set Schedule"),
                ),
              ],
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        final amount = int.tryParse(otherAmountController.text) ?? selectedAmount;
                        if (amount == null || amount < 500) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter an amount of at least ₱500.')),
                          );
                          return;
                        }
                        if (_scheduledDateTime == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please set a schedule.')),
                          );
                          return;
                        }
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Cash Donation'),
                            content: Text(
                              'Are you sure you want to pledge ₱$amount?\n'
                              'Schedule: ${_scheduledDateTime!.toLocal().toString().substring(0, 16)}\n\n'
                              'This request will be sent for admin approval.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                ),
                                child: const Text('Confirm'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          _submitDonation();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Confirm Cash Donation",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
