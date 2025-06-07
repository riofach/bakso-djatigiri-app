// Entity class untuk menu requirement (domain layer)
import 'package:equatable/equatable.dart';

class MenuRequirementEntity extends Equatable {
  final String id;
  final String menuId;
  final String ingredientId;
  final String ingredientName;
  final int requiredAmount;

  const MenuRequirementEntity({
    required this.id,
    required this.menuId,
    required this.ingredientId,
    required this.ingredientName,
    required this.requiredAmount,
  });

  @override
  List<Object?> get props =>
      [id, menuId, ingredientId, ingredientName, requiredAmount];

  // Metode untuk membuat salinan objek dengan nilai yang diperbarui
  MenuRequirementEntity copyWith({
    String? id,
    String? menuId,
    String? ingredientId,
    String? ingredientName,
    int? requiredAmount,
  }) {
    return MenuRequirementEntity(
      id: id ?? this.id,
      menuId: menuId ?? this.menuId,
      ingredientId: ingredientId ?? this.ingredientId,
      ingredientName: ingredientName ?? this.ingredientName,
      requiredAmount: requiredAmount ?? this.requiredAmount,
    );
  }
}
