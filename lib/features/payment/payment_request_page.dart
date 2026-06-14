import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentRequestPage extends StatefulWidget {
  final String transactionId;
  final String merchantName;
  final int amount;

  const PaymentRequestPage({
    super.key,
    required this.transactionId,
    required this.merchantName,
    required this.amount,
  });

  @override
  State<PaymentRequestPage> createState() => _PaymentRequestPageState();
}

class _PaymentRequestPageState extends State<PaymentRequestPage> {
  final pinController = TextEditingController();
  bool isLoading = false;

  Future<void> processPayment() async {
    setState(() => isLoading = true);

    final user = FirebaseAuth.instance.currentUser;

    try {
      final docRef = FirebaseFirestore.instance
          .collection('wallet_users')
          .doc(user!.uid);

      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        throw Exception("Wallet tidak ditemukan");
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final balance = data['balance'] ?? 0;
      final pin = data['pin'];

      if (pinController.text != pin) {
        throw Exception("PIN salah");
      }

      if (balance < widget.amount) {
        throw Exception("Saldo tidak cukup");
      }

      await docRef.update({'balance': balance - widget.amount});

      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(widget.transactionId)
          .update({
            'status': 'success',
            'paidAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pembayaran berhasil")));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFF8C42),
        title: const Text(
          "Konfirmasi Pembayaran",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
           
            ],
          ),
        ),
      ),
    );
  }
}
