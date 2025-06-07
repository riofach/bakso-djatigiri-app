// Use case untuk mengambil data ingredients (domain layer)
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../../../stock/domain/entities/ingredient_entity.dart';
import '../../../stock/domain/repositories/stock_repository.dart';

@injectable
class GetIngredientsForMenuUseCase {
  final StockRepository repository;

  GetIngredientsForMenuUseCase(this.repository);

  Future<List<IngredientEntity>> call() async {
    try {
      debugPrint('GetIngredientsForMenuUseCase: Fetching all ingredients');
      final ingredients = await repository.getIngredients();
      debugPrint(
          'GetIngredientsForMenuUseCase: Found ${ingredients.length} ingredients');

      if (ingredients.isEmpty) {
        debugPrint('GetIngredientsForMenuUseCase: No ingredients found!');
      } else {
        for (var ingredient in ingredients) {
          debugPrint(
              'GetIngredientsForMenuUseCase: Ingredient: ${ingredient.name} - stock: ${ingredient.stockAmount}');
        }
      }

      return ingredients;
    } catch (e) {
      debugPrint('GetIngredientsForMenuUseCase Error: $e');
      rethrow; // Re-throw to handle in the BLoC
    }
  }
}
