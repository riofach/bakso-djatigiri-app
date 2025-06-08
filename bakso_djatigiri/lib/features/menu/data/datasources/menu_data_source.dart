// Data source untuk menu (data layer)
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../../../config/supabase_storage.dart';
import '../../../../core/utils/image_compressor.dart';
import '../../../../core/utils/storage_helper.dart';
import '../models/menu_model.dart';
import '../models/menu_requirement_model.dart';

abstract class MenuDataSource {
  Future<List<MenuModel>> getMenus();
  Future<List<MenuRequirementModel>> getMenuRequirements(String menuId);
  Future<String> uploadImage(File file);
  Future<bool> deleteImage(String imageUrl);
  Future<String> addMenu(String name, int price, int stock, String imageUrl);
  Future<void> addMenuRequirement(String menuId, String ingredientId,
      String ingredientName, int requiredAmount);
  Future<void> updateMenu(
      String id, String name, int price, int stock, String imageUrl);
  Future<void> updateMenuStock(String menuId, int stock);
  Future<void> deleteMenuRequirements(String menuId);
  Future<void> deleteMenu(String id);
}

@Injectable(as: MenuDataSource)
class MenuDataSourceImpl implements MenuDataSource {
  final FirebaseFirestore _firestore;

  MenuDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<MenuModel>> getMenus() async {
    try {
      final snapshot = await _firestore
          .collection('menus')
          .orderBy('created_at', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => MenuModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting menus: $e');
      throw Exception('Gagal memuat data menu: $e');
    }
  }

  @override
  Future<List<MenuRequirementModel>> getMenuRequirements(String menuId) async {
    try {
      final snapshot = await _firestore
          .collection('menu_requirements')
          .where('menu_id', isEqualTo: menuId)
          .get();

      return snapshot.docs
          .map((doc) => MenuRequirementModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting menu requirements: $e');
      throw Exception('Gagal memuat data kebutuhan menu: $e');
    }
  }

  @override
  Future<String> uploadImage(File file) async {
    try {
      // Kompresi gambar terlebih dahulu
      final compressedFile = await ImageCompressor.compressImage(file);
      if (compressedFile == null) {
        throw Exception('Gagal mengkompresi gambar');
      }

      // Upload ke Supabase Storage
      final imageUrl = await SupabaseStorageService.uploadFile(compressedFile);
      if (imageUrl == null) {
        throw Exception('Gagal upload gambar ke Supabase Storage');
      }

      return imageUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      throw Exception('Gagal upload gambar: $e');
    }
  }

  @override
  Future<bool> deleteImage(String imageUrl) async {
    try {
      return await StorageHelper.deleteFileFromUrl(imageUrl);
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  @override
  Future<String> addMenu(
      String name, int price, int stock, String imageUrl) async {
    try {
      final docRef = await _firestore.collection('menus').add({
        'name': name,
        'price': price,
        'stock': stock,
        'image_url': imageUrl,
        'created_at': DateTime.now(),
      });
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding menu: $e');
      throw Exception('Gagal menambahkan menu: $e');
    }
  }

  @override
  Future<void> addMenuRequirement(String menuId, String ingredientId,
      String ingredientName, int requiredAmount) async {
    try {
      await _firestore.collection('menu_requirements').add({
        'menu_id': menuId,
        'ingredient_id': ingredientId,
        'ingredient_name': ingredientName,
        'required_amount': requiredAmount,
      });
    } catch (e) {
      debugPrint('Error adding menu requirement: $e');
      throw Exception('Gagal menambahkan kebutuhan menu: $e');
    }
  }

  @override
  Future<void> updateMenu(
      String id, String name, int price, int stock, String imageUrl) async {
    try {
      await _firestore.collection('menus').doc(id).update({
        'name': name,
        'price': price,
        'stock': stock,
        'image_url': imageUrl,
      });
    } catch (e) {
      debugPrint('Error updating menu: $e');
      throw Exception('Gagal mengupdate menu: $e');
    }
  }

  @override
  Future<void> updateMenuStock(String menuId, int stock) async {
    try {
      await _firestore.collection('menus').doc(menuId).update({
        'stock': stock,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating menu stock: $e');
      throw Exception('Gagal mengupdate stok menu: $e');
    }
  }

  @override
  Future<void> deleteMenuRequirements(String menuId) async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection('menu_requirements')
          .where('menu_id', isEqualTo: menuId)
          .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error deleting menu requirements: $e');
      throw Exception('Gagal menghapus kebutuhan menu: $e');
    }
  }

  @override
  Future<void> deleteMenu(String id) async {
    try {
      await _firestore.collection('menus').doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting menu: $e');
      throw Exception('Gagal menghapus menu: $e');
    }
  }
}
