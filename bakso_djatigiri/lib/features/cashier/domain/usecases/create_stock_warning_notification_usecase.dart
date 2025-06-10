// Use case untuk membuat notifikasi peringatan stok rendah
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/notification_repository.dart';

@injectable
class CreateStockWarningNotificationUseCase {
  final NotificationRepository _repository;

  CreateStockWarningNotificationUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String menuName,
    required int stock,
  }) async {
    return await _repository.createStockWarningNotification(menuName, stock);
  }
}
