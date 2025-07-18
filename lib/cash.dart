import 'package:flutter/material.dart';
import 'payment_method_page.dart'; // Adjust path if needed

class CashDonationPage extends StatefulWidget {
  const CashDonationPage({super.key});

  @override
  State<CashDonationPage> createState() => _CashDonationPageState();
}

class _CashDonationPageState extends State<CashDonationPage> {
  int? selectedAmount;
  final List<int> amounts = [10, 50, 100, 250, 500];
  final TextEditingController otherAmountController = TextEditingController();
  final FocusNode otherAmountFocusNode = FocusNode();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 🌟 Set background color to white
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

            const Spacer(),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PaymentMethodPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Center(
                child: Text(
                  "Select Payment Method",
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
