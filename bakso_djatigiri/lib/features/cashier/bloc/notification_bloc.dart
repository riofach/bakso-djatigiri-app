// Bloc untuk fitur notifikasi
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../domain/entities/notification_entity.dart';
import '../domain/usecases/get_notifications_usecase.dart';
import '../domain/usecases/mark_notification_as_read_usecase.dart';
import '../domain/usecases/watch_notifications_usecase.dart';
import '../domain/usecases/watch_unread_count_usecase.dart';
import '../domain/usecases/clear_read_notifications_usecase.dart';

// Events
abstract class NotificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadNotificationsEvent extends NotificationEvent {}

class MarkAsReadEvent extends NotificationEvent {
  final String notificationId;

  MarkAsReadEvent(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class ClearReadNotificationsEvent extends NotificationEvent {}

class NotificationsUpdatedEvent extends NotificationEvent {
  final List<NotificationEntity> notifications;

  NotificationsUpdatedEvent(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class UnreadCountUpdatedEvent extends NotificationEvent {
  final int count;

  UnreadCountUpdatedEvent(this.count);

  @override
  List<Object?> get props => [count];
}

// States
abstract class NotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final int unreadCount;

  NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}

class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
@injectable
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationAsReadUseCase _markNotificationAsReadUseCase;
  final WatchNotificationsUseCase _watchNotificationsUseCase;
  final WatchUnreadCountUseCase _watchUnreadCountUseCase;
  final ClearReadNotificationsUseCase _clearReadNotificationsUseCase;

  StreamSubscription? _notificationsSubscription;
  StreamSubscription? _unreadCountSubscription;

  NotificationBloc({
    required GetNotificationsUseCase getNotificationsUseCase,
    required MarkNotificationAsReadUseCase markNotificationAsReadUseCase,
    required WatchNotificationsUseCase watchNotificationsUseCase,
    required WatchUnreadCountUseCase watchUnreadCountUseCase,
    required ClearReadNotificationsUseCase clearReadNotificationsUseCase,
  })  : _getNotificationsUseCase = getNotificationsUseCase,
        _markNotificationAsReadUseCase = markNotificationAsReadUseCase,
        _watchNotificationsUseCase = watchNotificationsUseCase,
        _watchUnreadCountUseCase = watchUnreadCountUseCase,
        _clearReadNotificationsUseCase = clearReadNotificationsUseCase,
        super(NotificationInitial()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<ClearReadNotificationsEvent>(_onClearReadNotifications);
    on<NotificationsUpdatedEvent>(_onNotificationsUpdated);
    on<UnreadCountUpdatedEvent>(_onUnreadCountUpdated);

    // Mulai memantau perubahan notifikasi dan jumlah yang belum dibaca
    _startWatching();
  }

  void _startWatching() {
    _notificationsSubscription?.cancel();
    _unreadCountSubscription?.cancel();

    _notificationsSubscription = _watchNotificationsUseCase().listen(
      (notifications) {
        add(NotificationsUpdatedEvent(notifications));
      },
      onError: (error) {
        debugPrint('Error watching notifications: $error');
      },
    );

    _unreadCountSubscription = _watchUnreadCountUseCase().listen(
      (count) {
        add(UnreadCountUpdatedEvent(count));
      },
      onError: (error) {
        debugPrint('Error watching unread count: $error');
      },
    );
  }

  Future<void> _onLoadNotifications(
    LoadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(NotificationLoading());

      final result = await _getNotificationsUseCase();

      result.fold(
        (failure) {
          debugPrint(
              'NotificationBloc: Error loading notifications: ${failure.message}');
          emit(NotificationError(failure.message));
        },
        (notifications) {
          // Hitung jumlah notifikasi yang belum dibaca
          final unreadCount = notifications.where((n) => !n.isRead).length;
          emit(NotificationLoaded(
            notifications: notifications,
            unreadCount: unreadCount,
          ));
        },
      );
    } catch (e) {
      debugPrint('NotificationBloc: Error loading notifications: $e');
      emit(NotificationError('Gagal memuat notifikasi: $e'));
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final result = await _markNotificationAsReadUseCase(event.notificationId);

      result.fold(
        (failure) {
          debugPrint(
              'NotificationBloc: Error marking notification as read: ${failure.message}');
          // Tidak perlu emit state baru karena watchNotifications akan memperbarui state
        },
        (_) {
          // Tidak perlu emit state baru karena watchNotifications akan memperbarui state
          debugPrint(
              'NotificationBloc: Notification marked as read successfully');
        },
      );
    } catch (e) {
      debugPrint('NotificationBloc: Error marking notification as read: $e');
    }
  }

  Future<void> _onClearReadNotifications(
    ClearReadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final result = await _clearReadNotificationsUseCase();

      result.fold(
        (failure) {
          debugPrint(
              'NotificationBloc: Error clearing read notifications: ${failure.message}');
          // Tidak perlu emit state baru karena watchNotifications akan memperbarui state
        },
        (_) {
          // Tidak perlu emit state baru karena watchNotifications akan memperbarui state
          debugPrint(
              'NotificationBloc: Read notifications cleared successfully');
        },
      );
    } catch (e) {
      debugPrint('NotificationBloc: Error clearing read notifications: $e');
    }
  }

  void _onNotificationsUpdated(
    NotificationsUpdatedEvent event,
    Emitter<NotificationState> emit,
  ) {
    final notifications = event.notifications;
    final unreadCount = notifications.where((n) => !n.isRead).length;

    emit(NotificationLoaded(
      notifications: notifications,
      unreadCount: unreadCount,
    ));
  }

  void _onUnreadCountUpdated(
    UnreadCountUpdatedEvent event,
    Emitter<NotificationState> emit,
  ) {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      emit(NotificationLoaded(
        notifications: currentState.notifications,
        unreadCount: event.count,
      ));
    }
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    return super.close();
  }
}
