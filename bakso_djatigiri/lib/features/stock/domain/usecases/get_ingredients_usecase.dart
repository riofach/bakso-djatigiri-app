// Use case untuk mengambil semua ingredient (domain layer)
import '../entities/ingredient_entity.dart';
import '../repositories/stock_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetIngredientsUseCase {
  final StockRepository repository;

  GetIngredientsUseCase(this.repository);

  Future<List<IngredientEntity>> call() async {
    return await repository.getIngredients();
  }
}
