// Use case untuk mengupdate ingredient (domain layer)
import 'dart:io';
import '../repositories/stock_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateIngredientUseCase {
  final StockRepository repository;

  UpdateIngredientUseCase(this.repository);

  Future<void> call({
    required String id,
    required String name,
    required int stockAmount,
    File? imageFile,
    String? currentImageUrl,
  }) async {
    return await repository.updateIngredient(
      id: id,
      name: name,
      stockAmount: stockAmount,
      imageFile: imageFile,
      currentImageUrl: currentImageUrl,
    );
  }
}
