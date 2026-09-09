import '../../../../core/error/app_result.dart';
import '../entities/track_order_entity.dart';
import '../repositories/track_order_repository.dart';

final class TrackOrderUseCase {
  const TrackOrderUseCase({required this._repository});

  final TrackOrderRepository _repository;

  Future<AppResult<TrackOrderEntity>> call({required String code}) {
    return _repository.trackOrder(code: code);
  }
}
