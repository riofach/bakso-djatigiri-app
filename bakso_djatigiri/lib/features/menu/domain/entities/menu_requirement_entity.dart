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
}
