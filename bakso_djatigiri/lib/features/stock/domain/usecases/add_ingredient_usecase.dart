// Use case untuk menambahkan ingredient baru (domain layer)
import 'dart:io';
import '../repositories/stock_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class AddIngredientUseCase {
  final StockRepository repository;

  AddIngredientUseCase(this.repository);

  Future<void> call({
    required String name,
    required int stockAmount,
    required File imageFile,
  }) async {
    return await repository.addIngredient(
      name: name,
      stockAmount: stockAmount,
      imageFile: imageFile,
    );
  }
}
