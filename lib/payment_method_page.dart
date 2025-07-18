import 'package:flutter/material.dart';

class PaymentMethodPage extends StatelessWidget {
  const PaymentMethodPage({super.key});

  void _showSelectedMethod(BuildContext context, String method) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Payment Selected"),
        content: Text("You selected: $method"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final methods = [
      {'name': 'GCash', 'icon': Icons.account_balance_wallet},
      {'name': 'PayPal', 'icon': Icons.payment},
      {'name': 'Credit/Debit Card', 'icon': Icons.credit_card},
      {'name': 'Bank Transfer', 'icon': Icons.account_balance},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Payment Method",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: methods.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final method = methods[index];
          return Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 0, 0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(
                method['icon'] as IconData,
                color: Colors.white,
              ),
              title: Text(
                method['name'] as String,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () => _showSelectedMethod(context, method['name'] as String),
            ),
          );
        },
      ),
    );
  }
}
