// Use case untuk memperbarui stok menu berdasarkan ketersediaan bahan (domain layer)
import 'package:injectable/injectable.dart';
import '../entities/menu_entity.dart';
import '../entities/menu_requirement_entity.dart';
import '../repositories/menu_repository.dart';
import '../../../stock/domain/entities/ingredient_entity.dart';
import 'calculate_menu_stock_usecase.dart';

@injectable
class UpdateMenuStockUseCase {
  final MenuRepository _menuRepository;
  final CalculateMenuStockUseCase _calculateMenuStockUseCase;

  UpdateMenuStockUseCase(this._menuRepository, this._calculateMenuStockUseCase);

  /// Memperbarui stok menu berdasarkan ketersediaan bahan
  ///
  /// Mengembalikan true jika berhasil memperbarui stok menu, false jika gagal.
  Future<bool> call({
    required MenuEntity menu,
    required List<MenuRequirementEntity> menuRequirements,
    required List<IngredientEntity> availableIngredients,
  }) async {
    try {
      // Hitung stok menu berdasarkan ketersediaan bahan
      final newStock = _calculateMenuStockUseCase(
        menuRequirements: menuRequirements,
        availableIngredients: availableIngredients,
      );

      // Jika stok tidak berubah, tidak perlu update
      if (menu.stock == newStock) {
        return false;
      }

      // Update stok menu
      await _menuRepository.updateMenu(
        id: menu.id,
        name: menu.name,
        price: menu.price,
        stock: newStock,
        currentImageUrl: menu.imageUrl,
        requirements: menuRequirements,
      );

      return true;
    } catch (e) {
      return false;
    }
  }
}
