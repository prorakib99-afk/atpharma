import '../../../../core/error/app_failure.dart';
import '../../../../core/error/app_result.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/datasources/track_order_remote_data_source.dart';
import '../../data/models/track_order_model.dart';
import '../entities/track_order_entity.dart';
import 'track_order_repository.dart';

final class TrackOrderRepositoryImpl implements TrackOrderRepository {
  TrackOrderRepositoryImpl({required this._remoteDataSource});

  final TrackOrderRemoteDataSource _remoteDataSource;

  @override
  Future<AppResult<TrackOrderEntity>> trackOrder({required String code}) async {
    final String normalizedCode = code.trim();

    if (normalizedCode.isEmpty) {
      return const AppError<TrackOrderEntity>(
        AppFailure(
          message: 'Enter an order ID or phone number to track.',
          type: AppFailureType.validation,
        ),
      );
    }

    try {
      final TrackOrderModel response = await _remoteDataSource.trackOrder(
        code: normalizedCode,
      );

      return AppSuccess<TrackOrderEntity>(response.toEntity());
    } on ApiException catch (error) {
      return AppError<TrackOrderEntity>(FailureMapper.fromApiException(error));
    } catch (error) {
      return AppError<TrackOrderEntity>(FailureMapper.fromException(error));
    }
  }

  @override
  void cancelTrackOrderRequest() {
    _remoteDataSource.cancelTrackOrderRequest();
  }
}
