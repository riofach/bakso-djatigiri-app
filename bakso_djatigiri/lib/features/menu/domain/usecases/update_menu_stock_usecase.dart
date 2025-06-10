// Use case untuk menghitung dan mengupdate stok menu berdasarkan requirements
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../entities/menu_requirement_entity.dart';
import '../../../stock/domain/entities/ingredient_entity.dart';
import './calculate_menu_stock_usecase.dart';
import '../repositories/menu_repository.dart';

@injectable
class UpdateMenuStockUseCase {
  final MenuRepository _menuRepository;
  final CalculateMenuStockUseCase _calculateMenuStockUseCase;

  UpdateMenuStockUseCase({
    required MenuRepository menuRepository,
    required CalculateMenuStockUseCase calculateMenuStockUseCase,
  })  : _menuRepository = menuRepository,
        _calculateMenuStockUseCase = calculateMenuStockUseCase;

  Future<void> call({
    required String menuId,
    required List<MenuRequirementEntity> menuRequirements,
    required List<IngredientEntity> availableIngredients,
  }) async {
    try {
      // Hitung stok menu berdasarkan bahan yang tersedia
      final calculatedStock = _calculateMenuStockUseCase(
        menuRequirements: menuRequirements,
        availableIngredients: availableIngredients,
      );

      // Update stok menu di repository
      await _menuRepository.updateMenuStock(
        menuId: menuId,
        stock: calculatedStock,
      );

      debugPrint(
          'Stok menu berhasil diupdate: $menuId, stok: $calculatedStock');
    } catch (e) {
      debugPrint('Error updating menu stock: $e');
      throw Exception('Gagal mengupdate stok menu: $e');
    }
  }
}
