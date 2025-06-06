// Model class untuk ingredient (data layer)
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ingredient_entity.dart';

class IngredientModel extends IngredientEntity {
  const IngredientModel({
    required super.id,
    required super.name,
    required super.stockAmount,
    required super.imageUrl,
    required super.createdAt,
  });

  factory IngredientModel.fromMap(Map<String, dynamic> map, String id) {
    return IngredientModel(
      id: id,
      name: map['name'] ?? '',
      stockAmount: map['stock_amount'] ?? 0,
      imageUrl: map['image_url'] ?? '',
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'stock_amount': stockAmount,
      'image_url': imageUrl,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  // Factory constructor untuk membuat IngredientModel dari IngredientEntity
  factory IngredientModel.fromEntity(IngredientEntity entity) {
    return IngredientModel(
      id: entity.id,
      name: entity.name,
      stockAmount: entity.stockAmount,
      imageUrl: entity.imageUrl,
      createdAt: entity.createdAt,
    );
  }
}
