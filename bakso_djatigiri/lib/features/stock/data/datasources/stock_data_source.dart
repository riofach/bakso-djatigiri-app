// Data source untuk stock (data layer)
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../../../config/supabase_storage.dart';
import '../../../../core/utils/image_compressor.dart';
import '../../../../core/utils/storage_helper.dart';
import '../models/ingredient_model.dart';

abstract class StockDataSource {
  Future<List<IngredientModel>> getIngredients();
  Future<String> uploadImage(File file);
  Future<bool> deleteImage(String imageUrl);
  Future<void> addIngredient(String name, int stockAmount, String imageUrl);
  Future<void> updateIngredient(
      String id, String name, int stockAmount, String imageUrl);
  Future<void> deleteIngredient(String id);
}

@Injectable(as: StockDataSource)
class StockDataSourceImpl implements StockDataSource {
  final FirebaseFirestore _firestore;

  StockDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<IngredientModel>> getIngredients() async {
    try {
      final snapshot = await _firestore
          .collection('ingredients')
          .orderBy('created_at', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => IngredientModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting ingredients: $e');
      throw Exception('Gagal memuat data stock: $e');
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
  Future<void> addIngredient(
      String name, int stockAmount, String imageUrl) async {
    try {
      await _firestore.collection('ingredients').add({
        'name': name,
        'stock_amount': stockAmount,
        'image_url': imageUrl,
        'created_at': DateTime.now(),
      });
    } catch (e) {
      debugPrint('Error adding ingredient: $e');
      throw Exception('Gagal menambahkan bahan: $e');
    }
  }

  @override
  Future<void> updateIngredient(
      String id, String name, int stockAmount, String imageUrl) async {
    try {
      await _firestore.collection('ingredients').doc(id).update({
        'name': name,
        'stock_amount': stockAmount,
        'image_url': imageUrl,
      });
    } catch (e) {
      debugPrint('Error updating ingredient: $e');
      throw Exception('Gagal mengupdate bahan: $e');
    }
  }

  @override
  Future<void> deleteIngredient(String id) async {
    try {
      await _firestore.collection('ingredients').doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting ingredient: $e');
      throw Exception('Gagal menghapus bahan: $e');
    }
  }
}
