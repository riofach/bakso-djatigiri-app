// Entity class untuk ingredient (domain layer)
import 'package:equatable/equatable.dart';

class IngredientEntity extends Equatable {
  final String id;
  final String name;
  final int stockAmount;
  final String imageUrl;
  final DateTime createdAt;

  const IngredientEntity({
    required this.id,
    required this.name,
    required this.stockAmount,
    required this.imageUrl,
    required this.createdAt,
  });

  // Method untuk membuat salinan objek dengan nilai yang diubah
  IngredientEntity copyWith({
    String? id,
    String? name,
    int? stockAmount,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return IngredientEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      stockAmount: stockAmount ?? this.stockAmount,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, stockAmount, imageUrl, createdAt];
}
