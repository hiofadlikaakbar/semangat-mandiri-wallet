import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QrPage extends StatelessWidget {
  const QrPage({super.key});

  Future<Map<String, dynamic>?> getWalletData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('wallet_users')
        .doc(user.uid)
        .get();

    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("User belum login")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Wallet"),
        backgroundColor: const Color(0xFFFF8C42),
      ),
      body: FutureBuilder(
        future: getWalletData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final qrData = {
            "uid": user.uid,
            "email": data['email'],
            "balance": data['balance'],
          };

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                QrImageView(
                  data: qrData.toString(),
                  version: QrVersions.auto,
                  size: 220,
                ),

                const SizedBox(height: 20),

                Text(data['email'] ?? '', style: const TextStyle(fontSize: 16)),

                const SizedBox(height: 10),

                Text(
                  "Balance: Rp ${data['balance']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFFFF8C42),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
