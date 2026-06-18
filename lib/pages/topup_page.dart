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

  final List<int> quickAmounts = [10000, 20000, 50000, 100000, 200000, 500000];

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

    setState(() => isLoading = true);

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

    setState(() => isLoading = false);
  }

  void setAmount(int value) {
    amountController.text = value.toString();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFF8C42),
        elevation: 0,
        title: const Text(
          "Top Up Saldo",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB347), Color(0xFFFF8C42)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Icon(Icons.wallet, size: 60, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    "Isi Saldo E-Money",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Pilih nominal atau masukkan sendiri",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Contoh: 50000",
                prefixIcon: const Icon(Icons.payments),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Nominal Cepat",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: quickAmounts.map((value) {
                return GestureDetector(
                  onTap: () => setAmount(value),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8C42).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFF8C42)),
                    ),
                    child: Text(
                      "Rp $value",
                      style: const TextStyle(
                        color: Color(0xFFFF8C42),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : topup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Top Up Sekarang",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
