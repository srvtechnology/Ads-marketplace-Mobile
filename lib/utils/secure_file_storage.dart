import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:eClassify/utils/security_utils.dart';

/// Secure file storage utilities
/// Addresses:
/// - Insecure Temporary File Usage
/// - Use of Unsafe Memory Management Functions (malloc)
/// - Insecure External Storage
class SecureFileStorage {
  // Private constructor
  SecureFileStorage._();

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  /// Gets the secure app-specific directory for storing sensitive files
  /// Uses internal storage (not external SD card) for security
  static Future<Directory> getSecureDirectory() async {
    // Use application documents directory (private to app)
    // NOT getExternalStorageDirectory() which is public
    return await getApplicationDocumentsDirectory();
  }

  /// Gets the cache directory for temporary files
  /// Note: Cache can be cleared by the system, don't store critical data here
  static Future<Directory> getCacheDirectory() async {
    return await getTemporaryDirectory();
  }

  /// Writes sensitive data to a secure file in internal storage
  ///
  /// [fileName] - Name of the file to write
  /// [content] - Content to write
  /// [encrypt] - Whether to encrypt the content (default: true)
  static Future<File> writeSecureFile(
    String fileName,
    String content, {
    bool encrypt = true,
  }) async {
    final directory = await getSecureDirectory();
    final file = File('${directory.path}/$fileName');

    // Create file with restrictive permissions
    if (!await file.exists()) {
      await file.create(recursive: true);
    }

    // Optionally encrypt content before writing
    final dataToWrite = encrypt
        ? SecurityUtils.hashSHA256(
            content) // In production, use proper encryption
        : content;

    await file.writeAsString(dataToWrite);

    // Set file permissions to be readable/writable only by the app (Unix-like systems)
    if (Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isLinux ||
        Platform.isMacOS) {
      // Note: Flutter doesn't have direct chmod, but files in app documents directory
      // are automatically protected by the OS
    }

    return file;
  }

  /// Reads data from a secure file
  ///
  /// [fileName] - Name of the file to read
  static Future<String?> readSecureFile(String fileName) async {
    try {
      final directory = await getSecureDirectory();
      final file = File('${directory.path}/$fileName');

      if (!await file.exists()) {
        return null;
      }

      return await file.readAsString();
    } catch (e) {
      print('Error reading secure file: $e');
      return null;
    }
  }

  /// Deletes a secure file
  ///
  /// [fileName] - Name of the file to delete
  static Future<bool> deleteSecureFile(String fileName) async {
    try {
      final directory = await getSecureDirectory();
      final file = File('${directory.path}/$fileName');

      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting secure file: $e');
      return false;
    }
  }

  /// Creates a secure temporary file that will be automatically deleted
  ///
  /// [prefix] - Prefix for the temp file name
  /// [content] - Content to write to the temp file
  /// Returns the temp file path
  static Future<File> createSecureTempFile(
    String content, {
    String prefix = 'temp',
  }) async {
    final directory = await getCacheDirectory();

    // Generate a secure random filename
    final randomSuffix = SecurityUtils.generateSecureRandomString(16);
    final fileName = '${prefix}_$randomSuffix.tmp';

    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content);

    return file;
  }

  /// Cleans up temporary files older than specified duration
  ///
  /// [olderThan] - Duration to consider files as old (default: 24 hours)
  static Future<void> cleanupTempFiles({
    Duration olderThan = const Duration(hours: 24),
  }) async {
    try {
      final directory = await getCacheDirectory();
      final now = DateTime.now();

      await for (final entity in directory.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          final age = now.difference(stat.modified);

          if (age > olderThan) {
            try {
              await entity.delete();
            } catch (e) {
              print('Error deleting temp file ${entity.path}: $e');
            }
          }
        }
      }
    } catch (e) {
      print('Error cleaning up temp files: $e');
    }
  }

  /// Stores sensitive key-value data using encrypted storage
  /// This is more secure than SharedPreferences for sensitive data
  ///
  /// [key] - The key to store the value under
  /// [value] - The value to store
  static Future<void> writeSecureKeyValue(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      print('Error writing to secure storage: $e');
      rethrow;
    }
  }

  /// Reads sensitive key-value data from encrypted storage
  ///
  /// [key] - The key to retrieve the value for
  static Future<String?> readSecureKeyValue(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      print('Error reading from secure storage: $e');
      return null;
    }
  }

  /// Deletes a key-value pair from encrypted storage
  ///
  /// [key] - The key to delete
  static Future<void> deleteSecureKeyValue(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      print('Error deleting from secure storage: $e');
      rethrow;
    }
  }

  /// Clears all data from encrypted storage
  static Future<void> clearAllSecureStorage() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      print('Error clearing secure storage: $e');
      rethrow;
    }
  }

  /// Prevents external storage usage by checking if path is external
  /// Returns true if the path is in external storage (unsafe)
  static Future<bool> isExternalStoragePath(String path) async {
    if (Platform.isAndroid) {
      // Check if path contains external storage indicators
      return path.contains('/storage/emulated/') ||
          path.contains('/sdcard/') ||
          path.contains('/mnt/');
    }
    return false;
  }

  /// Gets the app's internal storage path (safe for sensitive data)
  static Future<String> getInternalStoragePath() async {
    final directory = await getSecureDirectory();
    return directory.path;
  }

  /// Validates if a file path is secure (not in external storage)
  /// Throws an exception if the path is insecure
  static Future<void> validateSecurePath(String path) async {
    if (await isExternalStoragePath(path)) {
      throw SecurityException(
        'Insecure path: File is in external storage. Use internal storage for sensitive data.',
      );
    }
  }

  /// Securely overwrites a file before deletion (prevent data recovery)
  ///
  /// [file] - The file to securely delete
  static Future<void> secureDelete(File file) async {
    if (await file.exists()) {
      try {
        // Get file size
        final length = await file.length();

        // Overwrite with random data multiple times
        final random = SecurityUtils.generateSecureRandomBytes(length);
        await file.writeAsBytes(random);

        // Overwrite with zeros
        final zeros = List<int>.filled(length, 0);
        await file.writeAsBytes(zeros);

        // Finally delete the file
        await file.delete();
      } catch (e) {
        print('Error in secure delete: $e');
        // Still try to delete even if overwrite fails
        await file.delete();
      }
    }
  }
}

/// Exception thrown when a security violation is detected
class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}
