// Use case untuk mendapatkan jumlah notifikasi yang belum dibaca
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/notification_repository.dart';

@injectable
class GetUnreadCountUseCase {
  final NotificationRepository _repository;

  GetUnreadCountUseCase(this._repository);

  Future<Either<Failure, int>> call() async {
    return await _repository.getUnreadCount();
  }
}
