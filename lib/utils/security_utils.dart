import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Security utilities for cryptographic operations
/// This class provides secure methods for password hashing and random number generation
class SecurityUtils {
  // Private constructor to prevent instantiation
  SecurityUtils._();

  /// Generates a cryptographically secure random string
  /// Uses Random.secure() instead of Random()
  ///
  /// [length] - The desired length of the random string
  /// [charset] - Optional character set to use (defaults to alphanumeric)
  static String generateSecureRandomString(
    int length, {
    String charset =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789',
  }) {
    final random = Random.secure();
    final codeUnits = List.generate(
      length,
      (index) => charset.codeUnitAt(random.nextInt(charset.length)),
    );
    return String.fromCharCodes(codeUnits);
  }

  /// Generates a secure random integer
  /// Uses Random.secure() instead of Random()
  ///
  /// [max] - The maximum value (exclusive)
  static int generateSecureRandomInt(int max) {
    final random = Random.secure();
    return random.nextInt(max);
  }

  /// Generates a secure random double between 0.0 (inclusive) and 1.0 (exclusive)
  static double generateSecureRandomDouble() {
    final random = Random.secure();
    return random.nextDouble();
  }

  /// Generates cryptographically secure random bytes
  ///
  /// [length] - Number of random bytes to generate
  static Uint8List generateSecureRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(length, (i) => random.nextInt(256)),
    );
  }

  /// Hashes a password using SHA-256
  /// NOTE: For production, consider using a proper password hashing algorithm
  /// like bcrypt or Argon2 instead of plain SHA-256
  ///
  /// [password] - The password to hash
  /// [salt] - Optional salt to add to the password before hashing
  static String hashPassword(String password, {String? salt}) {
    final saltedPassword = salt != null ? '$password$salt' : password;
    final bytes = utf8.encode(saltedPassword);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generates a secure salt for password hashing
  ///
  /// [length] - The desired length of the salt (default: 32)
  static String generateSalt({int length = 32}) {
    return generateSecureRandomString(length);
  }

  /// Validates password strength
  /// Returns true if password meets security requirements
  ///
  /// Requirements:
  /// - Minimum 8 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one digit
  /// - At least one special character
  static bool validatePasswordStrength(String password) {
    if (password.length < 8) return false;

    // Check for uppercase
    if (!password.contains(RegExp(r'[A-Z]'))) return false;

    // Check for lowercase
    if (!password.contains(RegExp(r'[a-z]'))) return false;

    // Check for digit
    if (!password.contains(RegExp(r'[0-9]'))) return false;

    // Check for special character
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;

    return true;
  }

  /// Gets password strength description for user feedback
  static String getPasswordStrengthMessage(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < 8) return 'Password must be at least 8 characters';

    int strength = 0;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    switch (strength) {
      case 0:
      case 1:
        return 'Weak password. Add uppercase, lowercase, numbers, and special characters';
      case 2:
        return 'Fair password. Add more character variety';
      case 3:
        return 'Good password. Consider adding more special characters';
      case 4:
        return 'Strong password';
      default:
        return 'Password does not meet requirements';
    }
  }

  /// Hashes data using SHA-256 (secure, not SHA-1 or MD5)
  ///
  /// [data] - The data to hash
  static String hashSHA256(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Hashes data using SHA-512 (even more secure)
  ///
  /// [data] - The data to hash
  static String hashSHA512(String data) {
    final bytes = utf8.encode(data);
    final digest = sha512.convert(bytes);
    return digest.toString();
  }

  /// Generates a secure token for session management
  ///
  /// [length] - The desired length of the token
  static String generateSecureToken({int length = 64}) {
    return generateSecureRandomString(length);
  }

  /// Sanitizes user input to prevent injection attacks
  ///
  /// [input] - The user input to sanitize
  static String sanitizeInput(String input) {
    // Remove potentially dangerous characters
    return input.replaceAll(RegExp(r'''[<>"'/]'''), '').trim();
  }

  /// Validates email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Generates a UUID v4 (random UUID)
  static String generateUUID() {
    final random = Random.secure();
    final bytes = Uint8List(16);
    for (int i = 0; i < 16; i++) {
      bytes[i] = random.nextInt(256);
    }

    // Set version (4) and variant bits
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    return _formatUUID(bytes);
  }

  static String _formatUUID(Uint8List bytes) {
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }
}
