// Use case untuk memperbarui stok semua menu saat ada perubahan pada stok bahan (domain layer)
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
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
  /// Parameter excludeMenuIds digunakan untuk mengecualikan menu tertentu dari update.
  Future<int> call({
    required List<IngredientEntity> availableIngredients,
    List<String>? excludeMenuIds,
  }) async {
    try {
      debugPrint('UpdateAllMenuStocksUseCase: Memulai update stok menu...');

      // Filter ingredients yang akan ditampilkan di log
      final ingredientsToLog = availableIngredients.take(5).toList();
      debugPrint(
          'UpdateAllMenuStocksUseCase: Total ingredients: ${availableIngredients.length}');
      debugPrint('UpdateAllMenuStocksUseCase: Contoh ingredients (max 5):');

      // Log detail ingredients (hanya beberapa contoh)
      for (var ingredient in ingredientsToLog) {
        debugPrint(
            'UpdateAllMenuStocksUseCase: - ${ingredient.name} (ID: ${ingredient.id}) - Stok: ${ingredient.stockAmount}');
      }

      if (excludeMenuIds != null && excludeMenuIds.isNotEmpty) {
        debugPrint(
            'UpdateAllMenuStocksUseCase: Mengecualikan ${excludeMenuIds.length} menu dari update');
      }

      int updatedCount = 0;

      // Ambil semua menu
      final allMenus = await _menuRepository.getMenus();

      // Filter menu yang akan diupdate (exclude menu yang sudah diupdate secara manual)
      final menus = excludeMenuIds != null && excludeMenuIds.isNotEmpty
          ? allMenus.where((menu) => !excludeMenuIds.contains(menu.id)).toList()
          : allMenus;

      debugPrint(
          'UpdateAllMenuStocksUseCase: Total menu yang akan diupdate: ${menus.length}');

      // Perbarui stok setiap menu
      for (var menu in menus) {
        debugPrint(
            'UpdateAllMenuStocksUseCase: Memproses menu: ${menu.name} (ID: ${menu.id}) - Stok saat ini: ${menu.stock}');

        // Ambil requirements untuk menu ini
        final requirements = await _menuRepository.getMenuRequirements(menu.id);

        if (requirements.isEmpty) {
          debugPrint(
              'UpdateAllMenuStocksUseCase: Menu ${menu.name} tidak memiliki requirements, set stok = 0');

          // Jika menu tidak memiliki requirements, set stok = 0
          if (menu.stock != 0) {
            await _menuRepository.updateMenu(
              id: menu.id,
              name: menu.name,
              price: menu.price,
              stock: 0,
              currentImageUrl: menu.imageUrl,
              requirements: requirements,
            );
            updatedCount++;
            debugPrint(
                'UpdateAllMenuStocksUseCase: Menu ${menu.name} updated: stok ${menu.stock} -> 0');
          }
          continue;
        }

        // Log requirements (hanya beberapa contoh)
        final reqToLog = requirements.take(3).toList();
        debugPrint(
            'UpdateAllMenuStocksUseCase: Menu ${menu.name} memiliki ${requirements.length} requirements');
        for (var req in reqToLog) {
          debugPrint(
              'UpdateAllMenuStocksUseCase: - ${req.ingredientName}: ${req.requiredAmount} unit');
        }
        if (requirements.length > 3) {
          debugPrint(
              'UpdateAllMenuStocksUseCase: ... dan ${requirements.length - 3} bahan lainnya');
        }

        // Hitung stok menu berdasarkan ketersediaan bahan
        final newStock = _calculateMenuStockUseCase(
          menuRequirements: requirements,
          availableIngredients: availableIngredients,
        );

        debugPrint(
            'UpdateAllMenuStocksUseCase: Menu ${menu.name} - stok lama: ${menu.stock}, stok baru: $newStock');

        // Jika stok tidak berubah, tidak perlu update
        if (menu.stock == newStock) {
          debugPrint(
              'UpdateAllMenuStocksUseCase: Menu ${menu.name} - stok tidak berubah, dilewati');
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
        debugPrint(
            'UpdateAllMenuStocksUseCase: Menu ${menu.name} updated: stok ${menu.stock} -> $newStock');
      }

      debugPrint(
          'UpdateAllMenuStocksUseCase: Total menu yang diupdate: $updatedCount');
      return updatedCount;
    } catch (e) {
      debugPrint('UpdateAllMenuStocksUseCase: Error updating menu stocks: $e');
      return 0;
    }
  }
}
