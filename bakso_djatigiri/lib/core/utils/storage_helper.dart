// Helper untuk operasi storage (delete file, extract filename, dll)
// File ini berisi fungsi-fungsi utility untuk menangani operasi storage
import 'package:flutter/material.dart';
import '../../config/supabase_storage.dart';

class StorageHelper {
  /// Mengekstrak nama file dari URL Supabase
  /// Returns nama file atau null jika gagal
  static String? extractFilenameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      // Format URL Supabase biasanya: .../storage/v1/object/public/bucket_name/file_name
      if (pathSegments.length >= 2) {
        return pathSegments.last;
      }

      debugPrint('Format URL tidak valid untuk ekstraksi nama file: $url');
      return null;
    } catch (e) {
      debugPrint('Error saat ekstraksi nama file: $e');
      return null;
    }
  }

  /// Menghapus file dari Supabase Storage berdasarkan URL
  /// Returns true jika berhasil, false jika gagal
  static Future<bool> deleteFileFromUrl(String url) async {
    try {
      final fileName = extractFilenameFromUrl(url);
      if (fileName == null) {
        return false;
      }

      final result = await SupabaseStorageService.deleteFile(fileName);
      if (result) {
        debugPrint('Berhasil menghapus file: $fileName');
      } else {
        debugPrint('Gagal menghapus file: $fileName');
      }

      return result;
    } catch (e) {
      debugPrint('Error saat menghapus file: $e');
      return false;
    }
  }
}
