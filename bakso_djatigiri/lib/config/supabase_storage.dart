// Helper Supabase Storage Service
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    final supabase = Supabase.instance.client;
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
    final storageResponse = await supabase.storage
        .from(bucket)
        .upload(fileName, file);
    if (storageResponse.isEmpty) return null;
    // Dapatkan public URL
    final publicUrl = supabase.storage.from(bucket).getPublicUrl(fileName);
    return publicUrl;
  }
}

// Ganti YOUR_SUPABASE_URL dan YOUR_SUPABASE_ANON_KEY dengan kredensial project kamu.
