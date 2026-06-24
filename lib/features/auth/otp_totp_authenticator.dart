import 'package:flutter/material.dart';
import '../../services/authenticator_service.dart';

class AuthVerificationScreen extends StatefulWidget {
  final String secret;

  const AuthVerificationScreen({super.key, required this.secret});

  @override
  State<AuthVerificationScreen> createState() => _AuthVerificationScreenState();
}

class _AuthVerificationScreenState extends State<AuthVerificationScreen> {
  final pinController = TextEditingController();

  bool loading = false;

  Future<void> verify() async {
    setState(() => loading = true);

    try {
      final valid = AuthenticatorService.verifyCode(
        secret: widget.secret,
        code: pinController.text.trim(),
      );

      if (valid) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kode Google Authenticator salah")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Google Authenticator")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text("Masukkan kode 6 digit dari Google Authenticator"),

            const SizedBox(height: 20),

            TextField(
              controller: pinController,
              maxLength: 6,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : verify,
              child: const Text("VERIFY"),
            ),
          ],
        ),
      ),
    );
  }
}
