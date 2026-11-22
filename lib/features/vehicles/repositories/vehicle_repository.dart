import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/vehicles/models/page_response.dart';
import 'package:frontend/features/vehicles/models/vehicle.dart';
import 'package:frontend/features/vehicles/models/vehicle_query_params.dart';

class VehicleRepository {
  final ApiClient _apiClient;

  VehicleRepository(this._apiClient);

  Future<PageResponse<Vehicle>> getVehicles(VehicleQueryParams params) async {
    try {
      final response = await _apiClient.get(
        AppConfig.vehiclesEndpoint,
        queryParameters: params.toQueryParameters(),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return PageResponse<Vehicle>.fromJson(data, Vehicle.fromJson);
      } else {
        throw const ApiException(
          message: 'Invalid response format received from server.',
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
}

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VehicleRepository(apiClient);
});
