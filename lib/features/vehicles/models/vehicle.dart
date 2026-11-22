import 'package:frontend/features/vehicles/models/vehicle_enums.dart';

class Vehicle {
  final int id;
  final String vehicleNumber;
  final VehicleType vehicleType;
  final String brand;
  final String model;
  final int manufacturingYear;
  final String color;
  final FuelType fuelType;
  final int seatingCapacity;
  final String driverName;
  final String driverPhone;
  final VehicleStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Vehicle({
    required this.id,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.brand,
    required this.model,
    required this.manufacturingYear,
    required this.color,
    required this.fuelType,
    required this.seatingCapacity,
    required this.driverName,
    required this.driverPhone,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  String get brandModel => '$brand $model';
}
