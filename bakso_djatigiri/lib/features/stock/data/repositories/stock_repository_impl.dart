// Implementasi repository untuk stock (data layer)
import 'dart:io';
import 'package:injectable/injectable.dart';
import '../../domain/entities/ingredient_entity.dart';
import '../../domain/repositories/stock_repository.dart';
import '../datasources/stock_data_source.dart';
import '../models/ingredient_model.dart';

@Injectable(as: StockRepository)
class StockRepositoryImpl implements StockRepository {
  final StockDataSource dataSource;

  StockRepositoryImpl(this.dataSource);

  @override
  Future<List<IngredientEntity>> getIngredients() async {
    try {
      final ingredients = await dataSource.getIngredients();
      return ingredients;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addIngredient({
    required String name,
    required int stockAmount,
    required File imageFile,
  }) async {
    try {
      // Upload gambar terlebih dahulu
      final imageUrl = await dataSource.uploadImage(imageFile);

      // Simpan data ingredient ke Firestore
      await dataSource.addIngredient(name, stockAmount, imageUrl);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateIngredient({
    required String id,
    required String name,
    required int stockAmount,
    File? imageFile,
    String? currentImageUrl,
  }) async {
    try {
      String imageUrl = currentImageUrl ?? '';

      // Jika ada file gambar baru, upload dan hapus yang lama
      if (imageFile != null) {
        // Hapus gambar lama jika ada
        if (currentImageUrl != null && currentImageUrl.isNotEmpty) {
          await dataSource.deleteImage(currentImageUrl);
        }

        // Upload gambar baru
        imageUrl = await dataSource.uploadImage(imageFile);
      }

      // Update data ingredient di Firestore
      await dataSource.updateIngredient(id, name, stockAmount, imageUrl);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteIngredient(String id) async {
    try {
      // Ambil data ingredient untuk mendapatkan URL gambar
      final ingredients = await dataSource.getIngredients();
      final ingredient = ingredients.firstWhere(
        (element) => element.id == id,
        orElse: () => IngredientModel(
          id: '',
          name: '',
          stockAmount: 0,
          imageUrl: '',
          createdAt: DateTime.now(),
        ),
      );

      // Hapus gambar jika ada
      if (ingredient.imageUrl.isNotEmpty) {
        await dataSource.deleteImage(ingredient.imageUrl);
      }

      // Hapus data ingredient dari Firestore
      await dataSource.deleteIngredient(id);
    } catch (e) {
      rethrow;
    }
  }
}
