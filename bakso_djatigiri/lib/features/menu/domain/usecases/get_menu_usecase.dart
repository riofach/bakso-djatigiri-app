// UseCase untuk mendapatkan detail menu dari Firestore
// Class ini mengimplementasikan fungsi untuk get menu by id

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../entities/menu_entity.dart';

@injectable
class GetMenuUseCase {
  final FirebaseFirestore _firestore;

  GetMenuUseCase({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<MenuEntity> call(String menuId) async {
    try {
      final menuDoc = await _firestore.collection('menus').doc(menuId).get();

      if (!menuDoc.exists) {
        throw Exception('Menu tidak ditemukan');
      }

      final data = menuDoc.data()!;

      return MenuEntity(
        id: menuId,
        name: data['name'] ?? '',
        price: data['price'] ?? 0,
        stock: data['stock'] ?? 0,
        imageUrl: data['image_url'] ?? '',
        createdAt:
            (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error mendapatkan menu: $e');
      throw Exception('Gagal mendapatkan data menu: $e');
    }
  }
}
