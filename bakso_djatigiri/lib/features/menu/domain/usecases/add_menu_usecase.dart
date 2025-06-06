// Use case untuk menambahkan menu baru (domain layer)
import 'dart:io';
import 'package:injectable/injectable.dart';
import '../entities/menu_requirement_entity.dart';
import '../repositories/menu_repository.dart';

@injectable
class AddMenuUseCase {
  final MenuRepository repository;

  AddMenuUseCase(this.repository);

  Future<void> call({
    required String name,
    required int price,
    required int stock,
    required File imageFile,
    required List<MenuRequirementEntity> requirements,
  }) async {
    return await repository.addMenu(
      name: name,
      price: price,
      stock: stock,
      imageFile: imageFile,
      requirements: requirements,
    );
  }
}
