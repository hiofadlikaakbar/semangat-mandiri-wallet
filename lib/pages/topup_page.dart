import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TopupPage extends StatefulWidget {
  const TopupPage({super.key});

  @override
  State<TopupPage> createState() => _TopupPageState();
}

class _TopupPageState extends State<TopupPage> {
  final amountController = TextEditingController();

  bool isLoading = false;

  Future<void> topup() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final amount = int.tryParse(amountController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Masukkan nominal yang valid")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final walletRef = FirebaseFirestore.instance
          .collection('wallet_users')
          .doc(user.uid);

      final walletSnap = await walletRef.get();

      if (!walletSnap.exists) {
        throw "Wallet tidak ditemukan";
      }

      final data = walletSnap.data()!;
      final balance = data['balance'] ?? 0;

      await walletRef.update({'balance': balance + amount});

      await FirebaseFirestore.instance.collection('transactions').add({
        'userId': user.uid,
        'amount': amount,
        'status': 'success',
        'type': 'topup',
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Top Up berhasil")));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFF8C42),
        title: const Text(
          "Top Up Saldo",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
    );
  }
}
