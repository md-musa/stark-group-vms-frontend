import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/vehicles/models/page_response.dart';
import 'package:frontend/features/vehicles/models/vehicle.dart';
import 'package:frontend/features/vehicles/models/vehicle_query_params.dart';
import 'package:frontend/features/vehicles/repositories/vehicle_repository.dart';

final vehicleQueryParamsProvider = StateProvider<VehicleQueryParams>((ref) {
  return const VehicleQueryParams();
});

final vehicleListProvider = FutureProvider.autoDispose<PageResponse<Vehicle>>((
  ref,
) async {
  final repository = ref.watch(vehicleRepositoryProvider);
  final params = ref.watch(vehicleQueryParamsProvider);

  return repository.getVehicles(params);
});
