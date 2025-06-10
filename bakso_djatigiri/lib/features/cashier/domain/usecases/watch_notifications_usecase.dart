// Use case untuk memantau perubahan pada notifikasi
import 'package:injectable/injectable.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

@injectable
class WatchNotificationsUseCase {
  final NotificationRepository _repository;

  WatchNotificationsUseCase(this._repository);

  Stream<List<NotificationEntity>> call() {
    return _repository.watchNotifications();
  }
}
