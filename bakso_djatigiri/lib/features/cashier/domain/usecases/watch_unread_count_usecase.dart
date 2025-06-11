// Use case untuk memantau jumlah notifikasi yang belum dibaca
import 'package:injectable/injectable.dart';
import '../repositories/notification_repository.dart';

@injectable
class WatchUnreadCountUseCase {
  final NotificationRepository _repository;

  WatchUnreadCountUseCase(this._repository);

  Stream<int> call() {
    return _repository.watchUnreadCount();
  }
}
