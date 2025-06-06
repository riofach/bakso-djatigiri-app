// Use case untuk mengambil data ingredients (domain layer)
import 'package:injectable/injectable.dart';
import '../../../stock/domain/entities/ingredient_entity.dart';
import '../../../stock/domain/repositories/stock_repository.dart';

@injectable
class GetIngredientsForMenuUseCase {
  final StockRepository repository;

  GetIngredientsForMenuUseCase(this.repository);

  Future<List<IngredientEntity>> call() async {
    return await repository.getIngredients();
  }
}
