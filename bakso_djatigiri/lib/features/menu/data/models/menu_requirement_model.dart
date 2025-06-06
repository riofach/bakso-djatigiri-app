// Model class untuk menu requirement (data layer)
import '../../domain/entities/menu_requirement_entity.dart';

class MenuRequirementModel extends MenuRequirementEntity {
  const MenuRequirementModel({
    required super.id,
    required super.menuId,
    required super.ingredientId,
    required super.ingredientName,
    required super.requiredAmount,
  });

  factory MenuRequirementModel.fromMap(Map<String, dynamic> map, String id) {
    return MenuRequirementModel(
      id: id,
      menuId: map['menu_id'] ?? '',
      ingredientId: map['ingredient_id'] ?? '',
      ingredientName: map['ingredient_name'] ?? '',
      requiredAmount: map['required_amount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'menu_id': menuId,
      'ingredient_id': ingredientId,
      'ingredient_name': ingredientName,
      'required_amount': requiredAmount,
    };
  }

  // Factory constructor untuk membuat MenuRequirementModel dari MenuRequirementEntity
  factory MenuRequirementModel.fromEntity(MenuRequirementEntity entity) {
    return MenuRequirementModel(
      id: entity.id,
      menuId: entity.menuId,
      ingredientId: entity.ingredientId,
      ingredientName: entity.ingredientName,
      requiredAmount: entity.requiredAmount,
    );
  }
}
