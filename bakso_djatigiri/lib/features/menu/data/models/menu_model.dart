// Model class untuk menu (data layer)
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/menu_entity.dart';

class MenuModel extends MenuEntity {
  const MenuModel({
    required super.id,
    required super.name,
    required super.price,
    required super.stock,
    required super.imageUrl,
    required super.createdAt,
  });

  factory MenuModel.fromMap(Map<String, dynamic> map, String id) {
    return MenuModel(
      id: id,
      name: map['name'] ?? '',
      price: map['price'] ?? 0,
      stock: map['stock'] ?? 0,
      imageUrl: map['image_url'] ?? '',
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'stock': stock,
      'image_url': imageUrl,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  // Factory constructor untuk membuat MenuModel dari MenuEntity
  factory MenuModel.fromEntity(MenuEntity entity) {
    return MenuModel(
      id: entity.id,
      name: entity.name,
      price: entity.price,
      stock: entity.stock,
      imageUrl: entity.imageUrl,
      createdAt: entity.createdAt,
    );
  }
}
