// Use case untuk menghitung stok menu berdasarkan ketersediaan bahan (domain layer)
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import '../../../stock/domain/entities/ingredient_entity.dart';
import '../entities/menu_requirement_entity.dart';

@injectable
class CalculateMenuStockUseCase {
  const CalculateMenuStockUseCase();

  /// Menghitung stok menu berdasarkan ketersediaan bahan
  ///
  /// Mengembalikan jumlah stok menu yang dapat dibuat berdasarkan bahan yang tersedia.
  /// Jika salah satu bahan tidak mencukupi, maka stok menu = 0.
  /// Jika semua bahan tersedia, maka stok menu dihitung berdasarkan bahan yang paling sedikit (bottleneck).
  int call({
    required List<MenuRequirementEntity> menuRequirements,
    required List<IngredientEntity> availableIngredients,
  }) {
    // Jika tidak ada requirements, stok = 0
    if (menuRequirements.isEmpty) {
      debugPrint('CalculateMenuStockUseCase: Tidak ada requirements, stok = 0');
      return 0;
    }

    debugPrint(
        'CalculateMenuStockUseCase: Menghitung stok berdasarkan ${menuRequirements.length} requirements dan ${availableIngredients.length} ingredients');

    // Mapping ingredient untuk akses cepat
    final ingredientMap = {
      for (var ingredient in availableIngredients) ingredient.id: ingredient
    };

    // Hitung berapa banyak menu yang bisa dibuat dari setiap bahan
    List<int> possibleStocks = [];

    for (var requirement in menuRequirements) {
      final ingredient = ingredientMap[requirement.ingredientId];

      // Jika bahan tidak ditemukan, maka stok menu = 0
      if (ingredient == null) {
        debugPrint(
            'CalculateMenuStockUseCase: Ingredient ${requirement.ingredientName} (${requirement.ingredientId}) tidak ditemukan, stok = 0');
        return 0;
      }

      // Jika stok bahan = 0, maka stok menu = 0
      if (ingredient.stockAmount <= 0) {
        debugPrint(
            'CalculateMenuStockUseCase: Stok ${ingredient.name} = 0, stok menu = 0');
        return 0;
      }

      // Cek required amount untuk menghindari division by zero
      final requiredAmount =
          requirement.requiredAmount > 0 ? requirement.requiredAmount : 1;

      // Hitung berapa banyak menu yang bisa dibuat dari bahan ini
      final possibleStock = ingredient.stockAmount ~/ requiredAmount;

      debugPrint(
          'CalculateMenuStockUseCase: ${ingredient.name} (ID: ${ingredient.id}) - stok ${ingredient.stockAmount} / kebutuhan $requiredAmount = $possibleStock menu');

      // Jika tidak bisa membuat menu dari bahan ini, stok menu = 0
      if (possibleStock <= 0) {
        debugPrint(
            'CalculateMenuStockUseCase: Tidak bisa membuat menu dari ${ingredient.name}, stok = 0');
        return 0;
      }

      possibleStocks.add(possibleStock);
    }

    // Jika tidak ada stok yang bisa dihitung, stok = 0
    if (possibleStocks.isEmpty) {
      debugPrint(
          'CalculateMenuStockUseCase: Tidak ada stok yang bisa dihitung, stok = 0');
      return 0;
    }

    // Stok menu adalah minimum dari semua kemungkinan stok
    final result =
        possibleStocks.reduce((min, stock) => stock < min ? stock : min);
    debugPrint(
        'CalculateMenuStockUseCase: Stok final = $result menu (dari kemungkinan: $possibleStocks)');
    return result;
  }
}
