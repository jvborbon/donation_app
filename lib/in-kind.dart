import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'scheduling.dart';

class InKindDonationPage extends StatefulWidget {
  const InKindDonationPage({super.key});

  @override
  State<InKindDonationPage> createState() => _InKindDonationPageState();
}

class _InKindDonationPageState extends State<InKindDonationPage> {
  final List<Map<String, dynamic>> _donations = [];

  final List<String> _categories = [
    'Foods',
    'Clothings',
    'Medical Supplies',
    'Books',
    'Toys',
    'Others',
  ];

  DateTime? _selectedDate;

  void _addDonationForm() {
    setState(() {
      _donations.add({
        'donation': '',
        'category': _categories[0],
        'quantity': '',
        'value': '',
      });
    });
  }

  Future<void> _submitDonations() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to submit donations.')),
      );
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a schedule date.')),
      );
      return;
    }
    if (_donations.isEmpty || _donations.any((d) => d['donation'].isEmpty || d['quantity'].isEmpty || d['value'].isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all donation fields.')),
      );
      return;
    }

    // Add main donation document
    final donationRef = await FirebaseFirestore.instance
        .collection('in_kind_donations')
        .add({
      'userID': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'dateSchedule': Timestamp.fromDate(_selectedDate!),
      'status': 'pending',
    });

    // Add items as subcollection
    for (var item in _donations) {
      await donationRef.collection('items').add({
        'donation': item['donation'],
        'category': item['category'],
        'quantity': item['quantity'],
        'value': item['value'],
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Donations scheduled for ${_selectedDate!.toLocal().toString().split(' ')[0]} submitted!',
        ),
      ),
    );

    setState(() {
      _donations.clear();
      _addDonationForm();
      _selectedDate = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _addDonationForm();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 209, 14, 14),
        title: const Text('In-Kind Donation', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        color: Colors.white,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ..._donations.asMap().entries.map((entry) {
              Map<String, dynamic> donation = entry.value;
              int idx = entry.key;
              return Card(
                color: Colors.grey[50],
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Item',
                          labelStyle: TextStyle(color: theme.colorScheme.primary),
                        ),
                        onChanged: (val) => donation['donation'] = val,
                        initialValue: donation['donation'],
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Donation Category',
                          labelStyle: TextStyle(color: theme.colorScheme.primary),
                        ),
                        value: donation['category'],
                        items: _categories
                            .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                            .toList(),
                        onChanged: (val) => setState(() => donation['category'] = val),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          labelStyle: TextStyle(color: theme.colorScheme.primary),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => donation['quantity'] = val,
                        initialValue: donation['quantity'],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Value',
                          labelStyle: TextStyle(color: theme.colorScheme.primary),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => donation['value'] = val,
                        initialValue: donation['value'],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: idx == 0
                            ? const SizedBox.shrink()
                            : IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _donations.removeAt(idx);
                                  });
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 16, color: Colors.white),
                    label: const Text(
                      'Add',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 209, 14, 14),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _addDonationForm,
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 130,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 209, 14, 14),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {
                      final scheduledDate = await showDialog<DateTime>(
                        context: context,
                        builder: (_) => SchedulingDialog(initialDate: _selectedDate),
                      );
                      if (scheduledDate != null) {
                        setState(() {
                          _selectedDate = scheduledDate;
                        });
                      }
                    },
                    child: const Text(
                      'Schedule',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
              ),
              onPressed: _submitDonations,
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}