// UseCase untuk mengupdate menu di Firestore
// Class ini mengimplementasikan fungsi untuk update menu

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../../../../config/supabase_storage.dart';
import '../../../../core/utils/image_compressor.dart';
import '../../../../core/utils/storage_helper.dart';

@injectable
class UpdateMenuUseCase {
  final FirebaseFirestore _firestore;

  UpdateMenuUseCase({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> call({
    required String id,
    required String name,
    required int price,
    File? imageFile,
    required String currentImageUrl,
  }) async {
    try {
      final menuRef = _firestore.collection('menus').doc(id);

      // Jika ada file gambar baru, upload dan update URL
      String imageUrl = currentImageUrl;

      if (imageFile != null) {
        // Hapus gambar lama dari storage
        if (currentImageUrl.isNotEmpty) {
          await StorageHelper.deleteFileFromUrl(currentImageUrl);
        }

        // Kompres gambar
        final compressedImage = await ImageCompressor.compressImage(imageFile);

        if (compressedImage != null) {
          // Upload ke Supabase Storage
          final newImageUrl =
              await SupabaseStorageService.uploadFile(compressedImage);

          if (newImageUrl != null) {
            imageUrl = newImageUrl;
          } else {
            throw Exception('Gagal mengupload gambar');
          }
        }
      }

      // Update data di Firestore
      await menuRef.update({
        'name': name,
        'price': price,
        'image_url': imageUrl,
        'updated_at': FieldValue.serverTimestamp(),
      });

      debugPrint('Menu berhasil diupdate: $id');
    } catch (e) {
      debugPrint('Error updating menu: $e');
      throw Exception('Gagal mengupdate menu: $e');
    }
  }
}
