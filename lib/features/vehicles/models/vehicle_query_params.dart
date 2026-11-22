import 'package:frontend/features/vehicles/models/vehicle_enums.dart';

class VehicleQueryParams {
  final String? search;
  final VehicleType? vehicleType;
  final FuelType? fuelType;
  final VehicleStatus? status;
  final int page;
  final int size;
  final String sortBy;
  final String direction;

  const VehicleQueryParams({
    this.search,
    this.vehicleType,
    this.fuelType,
    this.status,
    this.page = 0,
    this.size = 10,
    this.sortBy = 'createdAt',
    this.direction = 'DESC',
  });

  bool get hasActiveFilters =>
      (search != null && search!.trim().isNotEmpty) ||
      vehicleType != null ||
      fuelType != null ||
      status != null;

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'page': page,
      'size': size,
      'sortBy': sortBy,
      'direction': direction,
    };

    if (search != null && search!.trim().isNotEmpty) {
      params['search'] = search!.trim();
    }
    if (vehicleType != null) {
      params['vehicleType'] = vehicleType!.value;
    }
    if (fuelType != null) {
      params['fuelType'] = fuelType!.value;
    }
    if (status != null) {
      params['status'] = status!.value;
    }

    return params;
  }

  VehicleQueryParams copyWith({
    String? search,
    VehicleType? Function()? vehicleType,
    FuelType? Function()? fuelType,
    VehicleStatus? Function()? status,
    int? page,
    int? size,
    String? sortBy,
    String? direction,
  }) {
    return VehicleQueryParams(
      search: search ?? this.search,
      vehicleType: vehicleType != null ? vehicleType() : this.vehicleType,
      fuelType: fuelType != null ? fuelType() : this.fuelType,
      status: status != null ? status() : this.status,
      page: page ?? this.page,
      size: size ?? this.size,
      sortBy: sortBy ?? this.sortBy,
      direction: direction ?? this.direction,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VehicleQueryParams &&
        other.search == search &&
        other.vehicleType == vehicleType &&
        other.fuelType == fuelType &&
        other.status == status &&
        other.page == page &&
        other.size == size &&
        other.sortBy == sortBy &&
        other.direction == direction;
  }

  @override
  int get hashCode => Object.hash(
    search,
    vehicleType,
    fuelType,
    status,
    page,
    size,
    sortBy,
    direction,
  );
}
