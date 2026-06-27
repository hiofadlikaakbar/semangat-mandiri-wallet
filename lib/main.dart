import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'features/auth/login_page.dart';
import 'features/payment/payment_request_page.dart';
import 'qr/qr_page.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks appLinks;
  StreamSubscription<Uri>? sub;

  @override
  void initState() {
    super.initState();

    appLinks = AppLinks();

    _initDeepLink();
  }

  Future<void> _initDeepLink() async {
    final initial = await appLinks.getInitialLink();

    if (initial != null) {
      _handleUri(initial);
    }

    sub = appLinks.uriLinkStream.listen(_handleUri);
  }

  void _handleUri(Uri uri) {
    if (uri.scheme != "smwallet") return;
    if (uri.host != "pay") return;

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => PaymentRequestPage(
          transactionId: uri.queryParameters["orderId"] ?? "",
          merchantName: uri.queryParameters["merchant"] ?? "",
          amount: int.parse(uri.queryParameters["amount"] ?? "0"),
        ),
      ),
    );
  }

  @override
  void dispose() {
    sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: "Semangat Mandiri Wallet",
      home: const LoginPage(),
      routes: {
        "/login": (_) => const LoginPage(),
        "/qr": (_) => const QrPage(),
      },
    );
  }
}
