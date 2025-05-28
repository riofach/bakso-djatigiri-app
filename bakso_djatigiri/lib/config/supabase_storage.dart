// Helper Supabase Storage Service
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseStorageService {
  static const String bucket = 'bakso-djatigiri';

  // Inisialisasi Supabase (panggil di main.dart sebelum runApp)
  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://wwnxzbshlcrgvdoxuvge.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind3bnh6YnNobGNyZ3Zkb3h1dmdlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgzOTk3MDQsImV4cCI6MjA2Mzk3NTcwNH0.-DrpzdIjP4x8RV-RqiX3BVvNrtjHNqMvIbgdV9qN7Ic',
    );
  }

  // Upload file ke Supabase Storage
  static Future<String?> uploadFile(File file) async {
    try {
      final supabase = Supabase.instance.client;
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
      final storageResponse =
          await supabase.storage.from(bucket).upload(fileName, file);
      if (storageResponse.isEmpty) return null;
      // Dapatkan public URL
      final publicUrl = supabase.storage.from(bucket).getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint('Error saat upload file: $e');
      return null;
    }
  }

  /// Menghapus file dari Supabase Storage
  /// [fileName] adalah nama file yang akan dihapus
  static Future<bool> deleteFile(String fileName) async {
    try {
      final supabase = Supabase.instance.client;

      // Hapus file dari bucket yang sama dengan yang digunakan untuk upload
      await supabase.storage.from(bucket).remove([fileName]);

      debugPrint('Berhasil menghapus file: $fileName');
      return true;
    } catch (e) {
      debugPrint('Error saat menghapus file: $e');
      return false;
    }
  }
}

// Ganti YOUR_SUPABASE_URL dan YOUR_SUPABASE_ANON_KEY dengan kredensial project kamu.
