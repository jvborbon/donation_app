import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            "Notifications",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 209, 14, 14),
            ),
          ),
        ),
        Expanded(
          child: Builder(
            builder: (context) {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                return const Center(child: Text('Please log in to view notifications.'));
              }

              return Scaffold(
                backgroundColor: Colors.white,
                body: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('notifications')
                      .where('userID', isEqualTo: user.uid)
                      .orderBy('notif_timestamp', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No notifications.'));
                    }
                    final docs = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final title = data['title'] ?? '';
                        final message = data['message'] ?? '';
                        final timestamp = (data['notif_timestamp'] as Timestamp?)?.toDate();
                        final wasRead = data['wasRead'] == true;

                        return ListTile(
                          leading: Icon(
                            wasRead ? Icons.notifications_none : Icons.notifications_active,
                            color: wasRead
                                ? Colors.grey
                                : const Color.fromARGB(255, 209, 14, 14),
                          ),
                          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(message),
                              if (timestamp != null)
                                Text(
                                  '${timestamp.toLocal()}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                            ],
                          ),
                          trailing: wasRead
                              ? null
                              : Icon(Icons.circle, color: Colors.red, size: 10),
                          onTap: () async {
                            // Mark as read when tapped
                            await docs[index].reference.update({'wasRead': true});
                          },
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}