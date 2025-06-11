// Use case untuk menghapus notifikasi yang sudah dibaca
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/notification_repository.dart';

@injectable
class ClearReadNotificationsUseCase {
  final NotificationRepository _repository;

  ClearReadNotificationsUseCase(this._repository);

  Future<Either<Failure, Unit>> call() async {
    return await _repository.clearReadNotifications();
  }
}
