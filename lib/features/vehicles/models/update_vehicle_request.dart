import 'package:frontend/features/vehicles/models/vehicle_enums.dart';

class UpdateVehicleRequest {
  final String vehicleNumber;
  final VehicleType vehicleType;
  final String brand;
  final String model;
  final int? manufacturingYear;
  final String? color;
  final FuelType fuelType;
  final int? seatingCapacity;
  final String? driverName;
  final String? driverPhone;

  const UpdateVehicleRequest({
    required this.vehicleNumber,
    required this.vehicleType,
    required this.brand,
    required this.model,
    this.manufacturingYear,
    this.color,
    required this.fuelType,
    this.seatingCapacity,
    this.driverName,
    this.driverPhone,
  });

  Map<String, dynamic> toJson() {
    return {
      'vehicleNumber': vehicleNumber.trim(),
      'vehicleType': vehicleType.value,
      'brand': brand.trim(),
      'model': model.trim(),
      if (manufacturingYear != null) 'manufacturingYear': manufacturingYear,
      if (color != null && color!.trim().isNotEmpty) 'color': color!.trim(),
      'fuelType': fuelType.value,
      if (seatingCapacity != null) 'seatingCapacity': seatingCapacity,
      if (driverName != null && driverName!.trim().isNotEmpty)
        'driverName': driverName!.trim(),
      if (driverPhone != null && driverPhone!.trim().isNotEmpty)
        'driverPhone': driverPhone!.trim(),
    };
  }
}
