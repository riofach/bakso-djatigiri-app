// Entity model untuk menu
// File ini berisi definisi Menu Entity

import 'package:equatable/equatable.dart';

class MenuEntity extends Equatable {
  final String id;
  final String name;
  final int price;
  final int stock;
  final String imageUrl;
  final DateTime createdAt;

  const MenuEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, price, stock, imageUrl, createdAt];
}
