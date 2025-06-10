// Halaman notifikasi - Menampilkan daftar notifikasi
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import untuk inisialisasi locale
import '../../../core/theme/color_pallete.dart';
import '../bloc/notification_bloc.dart';
import '../domain/entities/notification_entity.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetIt.instance<NotificationBloc>()..add(LoadNotificationsEvent()),
      child: const _NotificationPageView(),
    );
  }
}

class _NotificationPageView extends StatefulWidget {
  const _NotificationPageView();

  @override
  State<_NotificationPageView> createState() => _NotificationPageViewState();
}

class _NotificationPageViewState extends State<_NotificationPageView> {
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
  bool _isRefreshing = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi data locale untuk format tanggal Indonesia
    initializeDateFormatting('id_ID', null);
  }

  // Fungsi untuk refresh notifikasi
  Future<void> _refreshNotifications() async {
    if (mounted) {
      setState(() {
        _isRefreshing = true;
      });

      try {
        context.read<NotificationBloc>().add(LoadNotificationsEvent());
        // Tambahkan delay kecil untuk memberi waktu UI memperbarui
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        debugPrint('Error refreshing notifications: $e');

        // Tampilkan snackbar error jika gagal refresh
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memperbarui notifikasi: $e'),
              backgroundColor: errorColor,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isRefreshing = false;
          });
        }
      }
    }
  }

  // Fungsi untuk menghapus semua notifikasi yang sudah dibaca
  void _clearReadNotifications() {
    // Konfirmasi penghapusan
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Notifikasi'),
        content: const Text('Hapus semua notifikasi yang sudah dibaca?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isDeleting = true;
              });

              // Proses penghapusan
              context
                  .read<NotificationBloc>()
                  .add(ClearReadNotificationsEvent());

              // Tampilkan snackbar sukses
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Notifikasi yang sudah dibaca berhasil dihapus'),
                  backgroundColor: successColor,
                ),
              );

              setState(() {
                _isDeleting = false;
              });
            },
            style: TextButton.styleFrom(foregroundColor: errorColor),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: dark900),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: dark900,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoaded) {
                // Hitung jumlah notifikasi yang sudah dibaca
                final readNotifications =
                    state.notifications.where((n) => n.isRead).toList();

                // Tampilkan tombol hapus hanya jika ada notifikasi yang sudah dibaca
                if (readNotifications.isNotEmpty) {
                  return IconButton(
                    icon: _isDeleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: primary950,
                            ),
                          )
                        : const Icon(Icons.delete_sweep, color: primary950),
                    tooltip: 'Hapus notifikasi yang sudah dibaca',
                    onPressed: _isDeleting ? null : _clearReadNotifications,
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        color: primary950,
        backgroundColor: white900,
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(
                child: CircularProgressIndicator(color: primary950),
              );
            } else if (state is NotificationError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: errorColor),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: gray900),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshNotifications,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary950,
                        foregroundColor: white900,
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            } else if (state is NotificationLoaded) {
              final notifications = state.notifications;

              if (notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.notifications_off_outlined,
                        size: 64,
                        color: gray900,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada notifikasi',
                        style: TextStyle(
                          color: dark900,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Notifikasi akan muncul di sini',
                        style: TextStyle(color: gray900, fontSize: 14),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _buildNotificationItem(context, notification);
                },
              );
            }

            // State awal atau tidak dikenal
            return const Center(
              child: CircularProgressIndicator(color: primary950),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationEntity notification,
  ) {
    // Warna latar belakang berdasarkan status dibaca
    final bgColor = notification.isRead ? white900 : white900.withOpacity(0.7);

    // Warna dan ikon berdasarkan tipe notifikasi
    Color iconColor = primary950;
    IconData iconData = Icons.info_outline;

    if (notification.type == 'stock_warning') {
      iconColor = warningColor;
      iconData = Icons.warning_amber_rounded;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: bgColor,
      elevation: notification.isRead ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notification.isRead ? gray200 : primary200,
          width: notification.isRead ? 0.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            context
                .read<NotificationBloc>()
                .add(MarkAsReadEvent(notification.id));
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconData, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                              fontSize: 14,
                              color: dark900,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: primary950,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        fontSize: 13,
                        color: gray900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _dateFormat.format(notification.timestamp),
                      style: const TextStyle(
                        fontSize: 11,
                        color: gray700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
