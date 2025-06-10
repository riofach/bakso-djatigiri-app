// UseCase untuk mendapatkan daftar menu dari Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/failures.dart';
import '../../../menu/domain/entities/menu_entity.dart';
import 'package:dartz/dartz.dart';

class GetMenusUseCase {
  final FirebaseFirestore firestore;

  const GetMenusUseCase({required this.firestore});

  Future<Either<Failure, List<MenuEntity>>> call() async {
    try {
      final snapshot = await firestore.collection('menus').get();

      final menus = snapshot.docs.map((doc) {
        final data = doc.data();
        return MenuEntity(
          id: doc.id,
          name: data['name'] ?? '',
          price: (data['price'] ?? 0).toInt(),
          stock: (data['stock'] ?? 0).toInt(),
          imageUrl: data['image_url'] ?? '',
          createdAt:
              (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();

      return Right(menus);
    } catch (e) {
      return Left(ServerFailure(message: 'Gagal mendapatkan menu: $e'));
    }
  }
}
