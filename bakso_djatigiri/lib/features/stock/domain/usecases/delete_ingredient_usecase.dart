// Use case untuk menghapus ingredient (domain layer)
import '../repositories/stock_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteIngredientUseCase {
  final StockRepository repository;

  DeleteIngredientUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteIngredient(id);
  }
}
