// Dependency Injection setup
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/stock/bloc/stock_bloc.dart';
import '../features/stock/bloc/create_stock_bloc.dart';
import '../features/stock/bloc/edit_stock_bloc.dart';
import '../features/stock/bloc/delete_stock_bloc.dart';
import '../features/stock/data/datasources/stock_data_source.dart';
import '../features/stock/data/repositories/stock_repository_impl.dart';
import '../features/stock/domain/repositories/stock_repository.dart';
import '../features/stock/domain/usecases/add_ingredient_usecase.dart';
import '../features/stock/domain/usecases/delete_ingredient_usecase.dart';
import '../features/stock/domain/usecases/get_ingredients_usecase.dart';
import '../features/stock/domain/usecases/update_ingredient_usecase.dart';

// Import untuk fitur menu
import '../features/menu/bloc/create_menu_bloc.dart';
import '../features/menu/data/datasources/menu_data_source.dart';
import '../features/menu/data/repositories/menu_repository_impl.dart';
import '../features/menu/domain/repositories/menu_repository.dart';
import '../features/menu/domain/usecases/add_menu_usecase.dart';
import '../features/menu/domain/usecases/get_ingredients_for_menu_usecase.dart';
import '../features/menu/domain/usecases/calculate_menu_stock_usecase.dart';
import '../features/menu/domain/usecases/update_menu_stock_usecase.dart';
import '../features/menu/domain/usecases/update_all_menu_stocks_usecase.dart';
import '../features/menu/domain/usecases/get_menu_usecase.dart';
import '../features/menu/domain/usecases/update_menu_usecase.dart';
import '../features/menu/domain/usecases/delete_menu_usecase.dart';
import '../features/menu/domain/usecases/get_menu_requirements_usecase.dart';
import '../features/menu/domain/usecases/update_menu_requirements_usecase.dart';
import '../features/menu/bloc/edit_menu_bloc.dart';
import '../features/menu/bloc/delete_menu_bloc.dart';

// Import untuk fitur kasir
import '../features/cashier/bloc/cashier_bloc.dart';

final GetIt getIt = GetIt.instance;

void setupDependencies() {
  // External
  getIt.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance);

  // Data Sources
  getIt.registerLazySingleton<StockDataSource>(
    () => StockDataSourceImpl(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<MenuDataSource>(
    () => MenuDataSourceImpl(firestore: getIt<FirebaseFirestore>()),
  );

  // Repositories
  getIt.registerLazySingleton<StockRepository>(
    () => StockRepositoryImpl(getIt<StockDataSource>()),
  );
  getIt.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(getIt<MenuDataSource>()),
  );

  // Use Cases
  getIt.registerLazySingleton<GetIngredientsUseCase>(
    () => GetIngredientsUseCase(getIt<StockRepository>()),
  );
  getIt.registerLazySingleton<AddIngredientUseCase>(
    () => AddIngredientUseCase(getIt<StockRepository>()),
  );
  getIt.registerLazySingleton<UpdateIngredientUseCase>(
    () => UpdateIngredientUseCase(getIt<StockRepository>()),
  );
  getIt.registerLazySingleton<DeleteIngredientUseCase>(
    () => DeleteIngredientUseCase(getIt<StockRepository>()),
  );

  // Menu Use Cases
  getIt.registerLazySingleton<AddMenuUseCase>(
    () => AddMenuUseCase(getIt<MenuRepository>()),
  );
  getIt.registerLazySingleton<GetIngredientsForMenuUseCase>(
    () => GetIngredientsForMenuUseCase(getIt<StockRepository>()),
  );

  // Menu Stock Use Cases
  getIt.registerLazySingleton<CalculateMenuStockUseCase>(
    () => const CalculateMenuStockUseCase(),
  );
  getIt.registerLazySingleton<UpdateMenuStockUseCase>(
    () => UpdateMenuStockUseCase(
      menuRepository: getIt<MenuRepository>(),
      calculateMenuStockUseCase: getIt<CalculateMenuStockUseCase>(),
    ),
  );
  getIt.registerLazySingleton<UpdateAllMenuStocksUseCase>(
    () => UpdateAllMenuStocksUseCase(
      getIt<MenuRepository>(),
      getIt<CalculateMenuStockUseCase>(),
    ),
  );

  // BLoCs
  getIt.registerFactory<StockBloc>(
    () => StockBloc(
      getIt<GetIngredientsUseCase>(),
      getIt<DeleteIngredientUseCase>(),
      getIt<UpdateAllMenuStocksUseCase>(),
    ),
  );
  getIt.registerFactory<CreateStockBloc>(
    () => CreateStockBloc(
      getIt<AddIngredientUseCase>(),
      getIt<GetIngredientsUseCase>(),
      getIt<UpdateAllMenuStocksUseCase>(),
    ),
  );
  getIt.registerFactory<EditStockBloc>(
    () => EditStockBloc(
      getIt<GetIngredientsUseCase>(),
      getIt<UpdateIngredientUseCase>(),
      getIt<UpdateAllMenuStocksUseCase>(),
    ),
  );
  getIt.registerFactory<DeleteStockBloc>(
    () => DeleteStockBloc(getIt<DeleteIngredientUseCase>()),
  );

  // Menu BLoCs
  getIt.registerFactory<CreateMenuBloc>(
    () => CreateMenuBloc(
      getIt<AddMenuUseCase>(),
      getIt<GetIngredientsForMenuUseCase>(),
      getIt<CalculateMenuStockUseCase>(),
    ),
  );

  // Edit Menu
  getIt.registerFactory<GetMenuUseCase>(
    () => GetMenuUseCase(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerFactory<UpdateMenuUseCase>(
    () => UpdateMenuUseCase(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerFactory<DeleteMenuUseCase>(
    () => DeleteMenuUseCase(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerFactory<GetMenuRequirementsUseCase>(
    () => GetMenuRequirementsUseCase(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerFactory<UpdateMenuRequirementsUseCase>(
    () => UpdateMenuRequirementsUseCase(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerFactory<EditMenuBloc>(
    () => EditMenuBloc(
      getIt<GetMenuUseCase>(),
      getIt<UpdateMenuUseCase>(),
      getIt<GetMenuRequirementsUseCase>(),
      getIt<GetIngredientsForMenuUseCase>(),
      getIt<UpdateMenuRequirementsUseCase>(),
      getIt<DeleteMenuUseCase>(),
      getIt<UpdateMenuStockUseCase>(),
    ),
  );
  getIt.registerFactory<DeleteMenuBloc>(
    () => DeleteMenuBloc(getIt<DeleteMenuUseCase>()),
  );

  // Cashier BLoCs
  getIt.registerFactory<CashierBloc>(
    () => CashierBloc(),
  );
}
