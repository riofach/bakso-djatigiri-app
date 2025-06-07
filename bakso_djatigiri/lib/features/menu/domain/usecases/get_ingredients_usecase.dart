// Use case untuk mengambil data ingredients (domain layer)
import 'package:injectable/injectable.dart';
import '../../../stock/domain/entities/ingredient_entity.dart';
import '../../../stock/domain/repositories/stock_repository.dart';

@injectable
class GetIngredientsUseCase {
  final StockRepository repository;

  GetIngredientsUseCase(this.repository);

  Future<List<IngredientEntity>> call() async {
    return await repository.getIngredients();
  }
}
