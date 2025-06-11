// Interface repository untuk notifikasi
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  // Mendapatkan semua notifikasi
  Future<Either<Failure, List<NotificationEntity>>> getNotifications();

  // Menandai notifikasi sebagai telah dibaca
  Future<Either<Failure, Unit>> markAsRead(String notificationId);

  // Membuat notifikasi peringatan stok rendah
  Future<Either<Failure, Unit>> createStockWarningNotification(
      String menuName, int stock);

  // Mendapatkan jumlah notifikasi yang belum dibaca
  Future<Either<Failure, int>> getUnreadCount();

  // Stream untuk memantau jumlah notifikasi yang belum dibaca
  Stream<int> watchUnreadCount();

  // Stream untuk memantau perubahan pada notifikasi
  Stream<List<NotificationEntity>> watchNotifications();

  // Menghapus notifikasi yang telah dibaca
  Future<Either<Failure, Unit>> clearReadNotifications();
}
