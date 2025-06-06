// Use case untuk memperbarui stok semua menu saat ada perubahan pada stok bahan (domain layer)
import 'package:injectable/injectable.dart';
import '../entities/menu_entity.dart';
import '../entities/menu_requirement_entity.dart';
import '../repositories/menu_repository.dart';
import '../../../stock/domain/entities/ingredient_entity.dart';
import 'calculate_menu_stock_usecase.dart';

@injectable
class UpdateAllMenuStocksUseCase {
  final MenuRepository _menuRepository;
  final CalculateMenuStockUseCase _calculateMenuStockUseCase;

  UpdateAllMenuStocksUseCase(
    this._menuRepository,
    this._calculateMenuStockUseCase,
  );

  /// Memperbarui stok semua menu berdasarkan ketersediaan bahan
  ///
  /// Mengembalikan jumlah menu yang berhasil diperbarui stoknya.
  Future<int> call({
    required List<IngredientEntity> availableIngredients,
  }) async {
    try {
      int updatedCount = 0;

      // Ambil semua menu
      final menus = await _menuRepository.getMenus();

      // Perbarui stok setiap menu
      for (var menu in menus) {
        // Ambil requirements untuk menu ini
        final requirements = await _menuRepository.getMenuRequirements(menu.id);

        // Hitung stok menu berdasarkan ketersediaan bahan
        final newStock = _calculateMenuStockUseCase(
          menuRequirements: requirements,
          availableIngredients: availableIngredients,
        );

        // Jika stok tidak berubah, tidak perlu update
        if (menu.stock == newStock) {
          continue;
        }

        // Update stok menu
        await _menuRepository.updateMenu(
          id: menu.id,
          name: menu.name,
          price: menu.price,
          stock: newStock,
          currentImageUrl: menu.imageUrl,
          requirements: requirements,
        );

        updatedCount++;
      }

      return updatedCount;
    } catch (e) {
      return 0;
    }
  }
}
