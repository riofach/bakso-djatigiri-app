// Implementasi repository untuk notifikasi
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../../core/services/notification_service.dart';
import '../domain/entities/notification_entity.dart';
import '../domain/repositories/notification_repository.dart';
import 'models/notification_model.dart';

@Injectable()
class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _firestore;
  final NotificationService _notificationService;

  NotificationRepositoryImpl({
    FirebaseFirestore? firestore,
    NotificationService? notificationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _notificationService = notificationService ?? NotificationService();

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications() async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .get();

      final notifications = querySnapshot.docs.map((doc) {
        return NotificationModel.fromMap(doc.data(), doc.id);
      }).toList();

      return Right(notifications);
    } catch (e) {
      debugPrint('Error getting notifications: $e');
      return const Left(
          ServerFailure(message: 'Gagal memuat notifikasi, coba lagi nanti'));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});

      return const Right(unit);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return const Left(
          ServerFailure(message: 'Gagal menandai notifikasi sebagai terbaca'));
    }
  }

  @override
  Future<Either<Failure, Unit>> createStockWarningNotification(
      String menuName, int stock) async {
    try {
      // Cek apakah sudah ada notifikasi untuk menu yang sama dengan stok rendah yang belum dibaca
      final existingNotifications = await _firestore
          .collection('notifications')
          .where('type', isEqualTo: 'stock_warning')
          .where('isRead', isEqualTo: false)
          .get();

      // Cari notifikasi yang berisi nama menu yang sama
      bool hasUnreadNotification = false;
      for (var doc in existingNotifications.docs) {
        final data = doc.data();
        if (data['message'].toString().contains(menuName)) {
          hasUnreadNotification = true;
          break;
        }
      }

      // Jika sudah ada notifikasi yang belum dibaca untuk menu ini, jangan buat notifikasi baru
      if (hasUnreadNotification) {
        debugPrint(
            'Notifikasi stok rendah untuk $menuName sudah ada dan belum dibaca');
        return const Right(unit);
      }

      // Jika belum ada notifikasi atau semua notifikasi sudah dibaca, buat notifikasi baru
      final notification = NotificationModel(
        id: '', // ID akan dibuat oleh Firestore
        title: 'Peringatan Stok Rendah',
        message: 'Stok $menuName tersisa $stock. Segera tambahkan stok!',
        timestamp: DateTime.now(),
        isRead: false,
        type: 'stock_warning',
      );

      await _firestore.collection('notifications').add(notification.toMap());

      // Tampilkan notifikasi lokal
      await _notificationService.showStockWarningNotification(
        title: notification.title,
        body: notification.message,
      );

      return const Right(unit);
    } catch (e) {
      debugPrint('Error creating stock warning notification: $e');
      return const Left(
          ServerFailure(message: 'Gagal membuat notifikasi peringatan stok'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearReadNotifications() async {
    try {
      // Dapatkan semua notifikasi yang sudah dibaca
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('isRead', isEqualTo: true)
          .get();

      // Hapus notifikasi yang sudah dibaca dalam batch
      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Commit batch
      await batch.commit();

      debugPrint(
          'Berhasil menghapus ${querySnapshot.docs.length} notifikasi yang sudah dibaca');
      return const Right(unit);
    } catch (e) {
      debugPrint('Error clearing read notifications: $e');
      return const Left(ServerFailure(
          message: 'Gagal menghapus notifikasi yang sudah dibaca'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .count()
          .get();

      // Pastikan nilai count tidak null, jika null kembalikan 0
      final count = querySnapshot.count ?? 0;
      return Right(count);
    } catch (e) {
      debugPrint('Error getting unread notifications count: $e');
      return const Left(ServerFailure(
          message: 'Gagal memuat jumlah notifikasi yang belum dibaca'));
    }
  }

  @override
  Stream<int> watchUnreadCount() {
    return _firestore
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .handleError((error) {
      debugPrint('Error watching unread notifications: $error');
      return 0;
    });
  }

  @override
  Stream<List<NotificationEntity>> watchNotifications() {
    return _firestore
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
            .toList())
        .handleError((error) {
      debugPrint('Error watching notifications: $error');
      return <NotificationEntity>[];
    });
  }
}
