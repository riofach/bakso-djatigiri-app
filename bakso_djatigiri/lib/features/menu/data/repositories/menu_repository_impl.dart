// Implementasi repository untuk menu (data layer)
import 'dart:io';
import 'package:injectable/injectable.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/entities/menu_requirement_entity.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_data_source.dart';

@Injectable(as: MenuRepository)
class MenuRepositoryImpl implements MenuRepository {
  final MenuDataSource dataSource;

  MenuRepositoryImpl(this.dataSource);

  @override
  Future<List<MenuEntity>> getMenus() async {
    try {
      final menus = await dataSource.getMenus();
      return menus;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<MenuRequirementEntity>> getMenuRequirements(String menuId) async {
    try {
      final requirements = await dataSource.getMenuRequirements(menuId);
      return requirements;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addMenu({
    required String name,
    required int price,
    required int stock,
    required File imageFile,
    required List<MenuRequirementEntity> requirements,
  }) async {
    try {
      // Upload gambar terlebih dahulu
      final imageUrl = await dataSource.uploadImage(imageFile);

      // Simpan data menu ke Firestore
      final menuId = await dataSource.addMenu(name, price, stock, imageUrl);

      // Simpan data menu requirements ke Firestore
      for (var req in requirements) {
        await dataSource.addMenuRequirement(
          menuId,
          req.ingredientId,
          req.ingredientName,
          req.requiredAmount,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateMenu({
    required String id,
    required String name,
    required int price,
    required int stock,
    File? imageFile,
    String? currentImageUrl,
    required List<MenuRequirementEntity> requirements,
  }) async {
    try {
      String imageUrl = currentImageUrl ?? '';

      // Jika ada file gambar baru, upload dan hapus yang lama
      if (imageFile != null) {
        // Hapus gambar lama jika ada
        if (currentImageUrl != null && currentImageUrl.isNotEmpty) {
          await dataSource.deleteImage(currentImageUrl);
        }

        // Upload gambar baru
        imageUrl = await dataSource.uploadImage(imageFile);
      }

      // Update data menu di Firestore
      await dataSource.updateMenu(id, name, price, stock, imageUrl);

      // Hapus semua menu requirements yang ada
      await dataSource.deleteMenuRequirements(id);

      // Tambahkan menu requirements baru
      for (var req in requirements) {
        await dataSource.addMenuRequirement(
          id,
          req.ingredientId,
          req.ingredientName,
          req.requiredAmount,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteMenu(String id) async {
    try {
      // Ambil data menu untuk mendapatkan URL gambar
      final menus = await dataSource.getMenus();
      final menu = menus.firstWhere(
        (element) => element.id == id,
        orElse: () => throw Exception('Menu tidak ditemukan'),
      );

      // Hapus gambar jika ada
      if (menu.imageUrl.isNotEmpty) {
        await dataSource.deleteImage(menu.imageUrl);
      }

      // Hapus semua menu requirements
      await dataSource.deleteMenuRequirements(id);

      // Hapus data menu dari Firestore
      await dataSource.deleteMenu(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateMenuStock({
    required String menuId,
    required int stock,
  }) async {
    try {
      await dataSource.updateMenuStock(menuId, stock);
    } catch (e) {
      rethrow;
    }
  }
}
