// Use case untuk menandai notifikasi sebagai telah dibaca
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/notification_repository.dart';

@injectable
class MarkNotificationAsReadUseCase {
  final NotificationRepository _repository;

  MarkNotificationAsReadUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String notificationId) async {
    return await _repository.markAsRead(notificationId);
  }
}
