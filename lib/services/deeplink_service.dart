import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class DeepLinkService {
  DeepLinkService._();

  static final AppLinks _appLinks = AppLinks();

  static void init({
    required BuildContext context,
    required Function(String transactionId, String merchant, int amount)
    onPaymentRequest,
  }) {
    _appLinks.uriLinkStream.listen((uri) {
      if (uri.scheme != "wallet") return;

      if (uri.host != "payment") return;

      final transactionId = uri.queryParameters["transactionId"] ?? "";
      final merchant = uri.queryParameters["merchant"] ?? "";
      final amount = int.tryParse(uri.queryParameters["amount"] ?? "0") ?? 0;

      onPaymentRequest(transactionId, merchant, amount);
    });
  }
}
