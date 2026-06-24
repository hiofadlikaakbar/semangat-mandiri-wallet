import 'dart:math';
import 'package:otp/otp.dart';

class AuthenticatorService {
  static String generateSecret() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

    final random = Random.secure();

    return List.generate(32, (_) => chars[random.nextInt(chars.length)]).join();
  }

  static bool verifyCode({required String secret, required String code}) {
    final now = DateTime.now();

    for (int offset = -1; offset <= 1; offset++) {
      final generatedCode = OTP.generateTOTPCodeString(
        secret,
        now.add(Duration(seconds: offset * 30)).millisecondsSinceEpoch,
        interval: 30,
        algorithm: Algorithm.SHA1,
        isGoogle: true,
      );

      if (generatedCode == code) {
        return true;
      }
    }

    return false;
  }
}
