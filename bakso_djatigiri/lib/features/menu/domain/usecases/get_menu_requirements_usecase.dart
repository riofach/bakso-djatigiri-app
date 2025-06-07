// UseCase untuk mendapatkan daftar menu requirements dari Firestore
// Class ini mengimplementasikan fungsi untuk get menu requirements by menu id

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../entities/menu_requirement_entity.dart';

@injectable
class GetMenuRequirementsUseCase {
  final FirebaseFirestore _firestore;

  GetMenuRequirementsUseCase({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<MenuRequirementEntity>> call(String menuId) async {
    try {
      debugPrint(
          'GetMenuRequirementsUseCase: Fetching requirements for menu ID: $menuId');

      final snapshot = await _firestore
          .collection('menu_requirements')
          .where('menu_id', isEqualTo: menuId)
          .get();

      debugPrint(
          'GetMenuRequirementsUseCase: Found ${snapshot.docs.length} requirements');

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final entity = MenuRequirementEntity(
          id: doc.id,
          menuId: data['menu_id'] ?? '',
          ingredientId: data['ingredient_id'] ?? '',
          ingredientName: data['ingredient_name'] ?? '',
          requiredAmount: data['required_amount'] ?? 0,
        );
        debugPrint(
            'GetMenuRequirementsUseCase: Mapped requirement: ${entity.ingredientName} - ${entity.requiredAmount}');
        return entity;
      }).toList();
    } catch (e) {
      debugPrint('GetMenuRequirementsUseCase Error: $e');
      throw Exception('Gagal mendapatkan data menu requirements: $e');
    }
  }
}
