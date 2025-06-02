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

  @override
  List<Object?> get props => [id, name, stockAmount, imageUrl, createdAt];
}
