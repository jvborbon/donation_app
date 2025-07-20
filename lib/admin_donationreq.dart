import 'package:flutter/material.dart';
import 'admin_cash_tab.dart';
import 'admin_in_kind.dart';

class DonationRequestsPage extends StatelessWidget {
  const DonationRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.card_giftcard), text: 'In-Kind'),
              Tab(icon: Icon(Icons.attach_money), text: 'Cash'),
            ],
            labelColor: Color.fromARGB(255, 209, 14, 14),
            indicatorColor: Color.fromARGB(255, 209, 14, 14),
          ),
          Expanded(
            child: TabBarView(
              children: [
                InKindDonationRequestsTab(),
                CashDonationRequestsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}