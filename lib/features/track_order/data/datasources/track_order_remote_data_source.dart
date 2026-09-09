import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_request_options.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/json_value_parser.dart';
import '../models/track_order_model.dart';

abstract interface class TrackOrderRemoteDataSource {
  Future<TrackOrderModel> trackOrder({required String code});

  void cancelTrackOrderRequest();
}

final class TrackOrderRemoteDataSourceImpl implements TrackOrderRemoteDataSource {
  TrackOrderRemoteDataSourceImpl({required this._dioClient});

  final DioClient _dioClient;

  CancelToken? _activeRequest;

  @override
  Future<TrackOrderModel> trackOrder({required String code}) async {
    cancelTrackOrderRequest();

    final CancelToken cancelToken = DioClient.createCancelToken();

    _activeRequest = cancelToken;

    try {
      final Response<dynamic> response = await _dioClient.get<dynamic>(
        DeliveryEndpoints.track(code),
        options: ApiRequestOptions.publicRequest(),
        cancelToken: cancelToken,
      );

      final Map<String, dynamic>? responseJson = JsonValueParser.map(
        response.data,
      );

      if (responseJson == null) {
        throw const ApiException(
          message: 'The tracking response format is invalid.',
          type: ApiExceptionType.unknown,
        );
      }

      final Map<String, dynamic> orderJson =
          JsonValueParser.map(responseJson['data']) ?? responseJson;

      return TrackOrderModel.fromJson(orderJson);
    } finally {
      if (identical(_activeRequest, cancelToken)) {
        _activeRequest = null;
      }
    }
  }

  @override
  void cancelTrackOrderRequest() {
    final CancelToken? cancelToken = _activeRequest;

    _activeRequest = null;

    DioClient.cancelRequest(
      cancelToken,
      reason: 'A newer track order request replaced the previous request.',
    );
  }
}
