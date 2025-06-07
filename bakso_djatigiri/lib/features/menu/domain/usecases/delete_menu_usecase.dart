// UseCase untuk menghapus menu dari Firestore dan gambar dari storage
// Class ini mengimplementasikan fungsi untuk delete menu

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/storage_helper.dart';

@injectable
class DeleteMenuUseCase {
  final FirebaseFirestore _firestore;

  DeleteMenuUseCase({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> call(String menuId) async {
    try {
      // 1. Ambil data menu untuk mendapatkan URL gambar
      final menuDoc = await _firestore.collection('menus').doc(menuId).get();

      if (!menuDoc.exists) {
        throw Exception('Menu tidak ditemukan');
      }

      final menuData = menuDoc.data();
      final imageUrl = menuData?['image_url'] as String?;

      // 2. Hapus gambar dari storage jika ada
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await StorageHelper.deleteFileFromUrl(imageUrl);
      }

      // 3. Hapus semua menu requirements terkait
      final requirementsSnapshot = await _firestore
          .collection('menu_requirements')
          .where('menu_id', isEqualTo: menuId)
          .get();

      final batch = _firestore.batch();
      for (var doc in requirementsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // 4. Hapus menu dari Firestore
      batch.delete(_firestore.collection('menus').doc(menuId));

      // Eksekusi batch operation
      await batch.commit();

      debugPrint('Menu berhasil dihapus: $menuId');
    } catch (e) {
      debugPrint('Error menghapus menu: $e');
      throw Exception('Gagal menghapus menu: $e');
    }
  }
}
