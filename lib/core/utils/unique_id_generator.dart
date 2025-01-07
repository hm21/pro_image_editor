// Dart imports:
import 'dart:math';

/// Generates a unique ID based on the current time.
String generateUniqueId() {
  const String characters =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

  final Random random = Random();
  final String timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
      .toRadixString(36)
      .padLeft(8, '0');

  String randomPart = '';
  for (int i = 0; i < 20; i++) {
    randomPart += characters[random.nextInt(characters.length)];
  }

  return '$timestamp$randomPart';
}
