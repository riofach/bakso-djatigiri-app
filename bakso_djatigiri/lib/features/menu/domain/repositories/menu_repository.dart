// Repository abstrak untuk menu (domain layer)
import 'dart:io';
import '../entities/menu_entity.dart';
import '../entities/menu_requirement_entity.dart';

abstract class MenuRepository {
  /// Mengambil semua data menu
  Future<List<MenuEntity>> getMenus();

  /// Mengambil data menu requirement berdasarkan menu id
  Future<List<MenuRequirementEntity>> getMenuRequirements(String menuId);

  /// Menambahkan menu baru
  Future<void> addMenu({
    required String name,
    required int price,
    required int stock,
    required File imageFile,
    required List<MenuRequirementEntity> requirements,
  });

  /// Mengupdate menu yang sudah ada
  Future<void> updateMenu({
    required String id,
    required String name,
    required int price,
    required int stock,
    File? imageFile,
    String? currentImageUrl,
    required List<MenuRequirementEntity> requirements,
  });

  /// Mengupdate stock menu
  Future<void> updateMenuStock({
    required String menuId,
    required int stock,
  });

  /// Menghapus menu berdasarkan id
  Future<void> deleteMenu(String id);
}
