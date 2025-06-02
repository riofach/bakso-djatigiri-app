// Use case untuk menghitung stok menu berdasarkan ketersediaan bahan (domain layer)
import 'package:injectable/injectable.dart';
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
      return 0;
    }

    // Mapping ingredient untuk akses cepat
    final ingredientMap = {
      for (var ingredient in availableIngredients) ingredient.id: ingredient
    };

    // Hitung berapa banyak menu yang bisa dibuat dari setiap bahan
    List<int> possibleStocks = [];

    for (var requirement in menuRequirements) {
      final ingredient = ingredientMap[requirement.ingredientId];

      // Jika bahan tidak ditemukan atau stok bahan = 0, maka stok menu = 0
      if (ingredient == null || ingredient.stockAmount <= 0) {
        return 0;
      }

      // Hitung berapa banyak menu yang bisa dibuat dari bahan ini
      final possibleStock =
          ingredient.stockAmount ~/ requirement.requiredAmount;

      // Jika tidak bisa membuat menu dari bahan ini, stok menu = 0
      if (possibleStock <= 0) {
        return 0;
      }

      possibleStocks.add(possibleStock);
    }

    // Stok menu adalah minimum dari semua kemungkinan stok
    return possibleStocks.reduce((min, stock) => stock < min ? stock : min);
  }
}
