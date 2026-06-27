import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/otp_totp_authenticator.dart';

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
          child: Column(
            children: [
              // MERCHANT CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB347), Color(0xFFFF8C42)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.store, size: 60, color: Colors.white),

                    const SizedBox(height: 12),

                    const Text(
                      "Merchant",
                      style: TextStyle(color: Colors.white70),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      widget.merchantName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Total Pembayaran",
                      style: TextStyle(color: Colors.white70),
                    ),

                    Text(
                      "Rp ${widget.amount}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // PIN CARD
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Masukkan PIN",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;

                    if (user == null) return;

                    try {
                      // 1. Ambil data secret dari Firestore
                      final doc = await FirebaseFirestore.instance
                          .collection(
                            "wallet_users",
                          ) // Pastikan nama koleksi ini sudah sesuai
                          .doc(user.uid)
                          .get();

                      // Cek jika dokumen tidak ada atau field tidak ditemukan agar tidak crash
                      if (!doc.exists ||
                          doc.data() == null ||
                          !doc.data()!.containsKey('authSecret')) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Data verifikasi tidak ditemukan."),
                            ),
                          );
                        }
                        return;
                      }

                      final secret = doc["authSecret"];

                      // 2. Validasi BuildContext sebelum melakukan Navigasi (Async Gap)
                      if (!context.mounted) return;

                      final verified = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AuthVerificationScreen(secret: secret),
                        ),
                      );

                      // 3. Proses pembayaran jika hasil verifikasi sukses berstatus true
                      if (verified == true && context.mounted) {
                        await processPayment();
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Terjadi kesalahan: $e")),
                        );
                      }
                    }
                  },
                  // Menambahkan text di dalam tombol yang sebelumnya hilang
                  child: const Text(
                    "Bayar Sekarang",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Transaksi aman & terenkripsi",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
