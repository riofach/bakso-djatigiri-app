// Repository abstrak untuk stock (domain layer)
import 'dart:io';
import '../entities/ingredient_entity.dart';

abstract class StockRepository {
  /// Mengambil semua data ingredient
  Future<List<IngredientEntity>> getIngredients();

  /// Menambahkan ingredient baru
  Future<void> addIngredient({
    required String name,
    required int stockAmount,
    required File imageFile,
  });

  /// Mengupdate ingredient yang sudah ada
  Future<void> updateIngredient({
    required String id,
    required String name,
    required int stockAmount,
    File? imageFile,
    String? currentImageUrl,
  });

  /// Menghapus ingredient berdasarkan id
  Future<void> deleteIngredient(String id);
}
