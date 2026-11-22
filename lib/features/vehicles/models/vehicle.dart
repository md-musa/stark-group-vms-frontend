import 'package:frontend/features/vehicles/models/vehicle_enums.dart';

class Vehicle {
  final int id;
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
  final VehicleStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Vehicle({
    required this.id,
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
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  String get brandModel => '$brand $model';

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: (json['id'] as num).toInt(),
      vehicleNumber: json['vehicleNumber'] as String? ?? '',
      vehicleType: VehicleType.fromString(json['vehicleType'] as String? ?? ''),
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      manufacturingYear: (json['manufacturingYear'] as num?)?.toInt(),
      color: json['color'] as String?,
      fuelType: FuelType.fromString(json['fuelType'] as String? ?? ''),
      seatingCapacity: (json['seatingCapacity'] as num?)?.toInt(),
      driverName: json['driverName'] as String?,
      driverPhone: json['driverPhone'] as String?,
      status: VehicleStatus.fromString(json['status'] as String? ?? ''),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType.value,
      'brand': brand,
      'model': model,
      if (manufacturingYear != null) 'manufacturingYear': manufacturingYear,
      if (color != null) 'color': color,
      'fuelType': fuelType.value,
      if (seatingCapacity != null) 'seatingCapacity': seatingCapacity,
      if (driverName != null) 'driverName': driverName,
      if (driverPhone != null) 'driverPhone': driverPhone,
      'status': status.value,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
