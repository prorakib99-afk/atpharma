import '../../../../core/error/app_result.dart';
import '../entities/track_order_entity.dart';

abstract interface class TrackOrderRepository {
  Future<AppResult<TrackOrderEntity>> trackOrder({required String code});

  void cancelTrackOrderRequest();
}
