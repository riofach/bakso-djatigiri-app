// Helper untuk kompresi gambar sebelum upload ke Supabase Storage
// File ini berisi fungsi untuk mengkompresi gambar agar ukuran maksimal 500KB
// ignore_for_file: unused_import

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageCompressor {
  /// Ukuran maksimal file dalam bytes (500KB)
  static const int maxSizeBytes = 500 * 1024;

  /// Mengkompresi gambar hingga ukurannya di bawah 500KB
  ///
  /// [file] adalah File gambar yang akan dikompresi
  /// Returns File yang sudah dikompresi atau null jika gagal
  static Future<File?> compressImage(File file) async {
    try {
      // Cek ukuran file
      final fileSize = await file.length();

      // Jika sudah di bawah 500KB, tidak perlu kompresi
      if (fileSize <= maxSizeBytes) {
        debugPrint('Ukuran gambar sudah di bawah 500KB: ${fileSize / 1024} KB');
        return file;
      }

      // Dapatkan ekstensi file
      final extension = path.extension(file.path).toLowerCase();
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}$extension';

      // Hitung quality berdasarkan ukuran file
      int quality = 90;
      if (fileSize > maxSizeBytes * 4) {
        quality = 60; // Untuk file yang sangat besar
      } else if (fileSize > maxSizeBytes * 2) {
        quality = 70; // Untuk file besar
      } else {
        quality = 80; // Untuk file yang sedikit di atas batas
      }

      // Kompresi gambar
      File? result;

      if (extension == '.jpg' || extension == '.jpeg' || extension == '.png') {
        final compressedData = await FlutterImageCompress.compressWithFile(
          file.path,
          quality: quality,
          minWidth: 1024, // Batasi ukuran maksimal
          minHeight: 1024,
        );

        if (compressedData != null) {
          final compressedFile = File(targetPath);
          await compressedFile.writeAsBytes(compressedData);
          result = compressedFile;
        }
      } else {
        // Format tidak didukung, gunakan file asli
        debugPrint('Format file tidak didukung untuk kompresi: $extension');
        return file;
      }

      // Cek hasil kompresi
      if (result != null) {
        final compressedSize = await result.length();
        debugPrint('Ukuran sebelum kompresi: ${fileSize / 1024} KB');
        debugPrint('Ukuran setelah kompresi: ${compressedSize / 1024} KB');

        // Jika masih di atas batas, coba kompresi lagi dengan quality lebih rendah
        if (compressedSize > maxSizeBytes) {
          return await _recompressUntilSizeReached(result, 50);
        }

        return result;
      }

      return file;
    } catch (e) {
      debugPrint('Error saat kompresi gambar: $e');
      return null;
    }
  }

  /// Melakukan kompresi berulang hingga ukuran file di bawah batas
  static Future<File?> _recompressUntilSizeReached(
    File file,
    int quality,
  ) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final extension = path.extension(file.path).toLowerCase();
      final targetPath =
          '${tempDir.path}/recompressed_${DateTime.now().millisecondsSinceEpoch}$extension';

      final compressedData = await FlutterImageCompress.compressWithFile(
        file.path,
        quality: quality,
        minWidth: 800, // Lebih kecil dari sebelumnya
        minHeight: 800,
      );

      if (compressedData != null) {
        final compressedFile = File(targetPath);
        await compressedFile.writeAsBytes(compressedData);

        final compressedSize = await compressedFile.length();
        debugPrint(
          'Rekompresi dengan quality $quality: ${compressedSize / 1024} KB',
        );

        if (compressedSize <= maxSizeBytes || quality <= 30) {
          return compressedFile;
        } else {
          // Coba lagi dengan quality lebih rendah
          return await _recompressUntilSizeReached(
            compressedFile,
            quality - 10,
          );
        }
      }

      return file;
    } catch (e) {
      debugPrint('Error saat rekompresi gambar: $e');
      return file;
    }
  }
}
