// UseCase untuk memperbarui menu requirements di Firestore
// Class ini mengimplementasikan fungsi untuk update menu requirements

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../entities/menu_requirement_entity.dart';

@injectable
class UpdateMenuRequirementsUseCase {
  final FirebaseFirestore _firestore;

  UpdateMenuRequirementsUseCase({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> call({
    required String menuId,
    required List<MenuRequirementEntity> requirements,
  }) async {
    try {
      // 1. Ambil requirements yang ada saat ini
      final snapshot = await _firestore
          .collection('menu_requirements')
          .where('menu_id', isEqualTo: menuId)
          .get();

      // 2. Siapkan batch operation
      final batch = _firestore.batch();

      // 3. Hapus semua requirements saat ini
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      // 4. Tambahkan requirements baru
      for (var req in requirements) {
        final docRef = _firestore.collection('menu_requirements').doc();
        batch.set(docRef, {
          'menu_id': menuId,
          'ingredient_id': req.ingredientId,
          'ingredient_name': req.ingredientName,
          'required_amount': req.requiredAmount,
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      // 5. Eksekusi batch operation
      await batch.commit();

      debugPrint('Menu requirements berhasil diupdate: $menuId');
    } catch (e) {
      debugPrint('Error updating menu requirements: $e');
      throw Exception('Gagal mengupdate menu requirements: $e');
    }
  }
}
