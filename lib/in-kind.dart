import 'package:flutter/material.dart';



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

  @override
  void initState() {
    super.initState();
    _addDonationForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 209, 14, 14),
        title: const Text('In-Kind Donation', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._donations.asMap().entries.map((entry) {
            Map<String, dynamic> donation = entry.value;
            int idx = entry.key;
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Donation'),
                      onChanged: (val) => donation['donation'] = val,
                      initialValue: donation['donation'],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Donation Category'),
                      value: donation['category'],
                      items: _categories
                          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                          .toList(),
                      onChanged: (val) => setState(() => donation['category'] = val),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => donation['quantity'] = val,
                      initialValue: donation['quantity'],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Value'),
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
            Align(
              alignment: Alignment.center, // Optional: change to centerRight or center
              child: SizedBox(
                width: 140, // or any width you prefer (e.g., 120)
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  label: const Text(
                    'Add Donation',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 209, 14, 14),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: _addDonationForm,
                ),
              ),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 209, 14, 14),
              ),
              onPressed: () {
                // Handle submit logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Donations submitted!')),
                );
              },
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}