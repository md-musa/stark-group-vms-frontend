enum VehicleStatus {
  available('AVAILABLE', 'Available'),
  inUse('IN_USE', 'In Use'),
  maintenance('MAINTENANCE', 'Maintenance'),
  inactive('INACTIVE', 'Inactive');

  final String value;
  final String label;

  const VehicleStatus(this.value, this.label);

  static VehicleStatus fromString(String value) {
    return VehicleStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => VehicleStatus.available,
    );
  }
}

enum VehicleType {
  car('CAR', 'Car'),
  suv('SUV', 'SUV'),
  van('VAN', 'Van'),
  microbus('MICROBUS', 'Microbus'),
  bus('BUS', 'Bus'),
  truck('TRUCK', 'Truck'),
  pickup('PICKUP', 'Pickup'),
  motorcycle('MOTORCYCLE', 'Motorcycle');

  final String value;
  final String label;

  const VehicleType(this.value, this.label);

  static VehicleType fromString(String value) {
    return VehicleType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => VehicleType.car,
    );
  }
}

enum FuelType {
  petrol('PETROL', 'Petrol'),
  diesel('DIESEL', 'Diesel'),
  octane('OCTANE', 'Octane'),
  cng('CNG', 'CNG'),
  lpg('LPG', 'LPG'),
  hybrid('HYBRID', 'Hybrid'),
  electric('ELECTRIC', 'Electric');

  final String value;
  final String label;

  const FuelType(this.value, this.label);

  static FuelType fromString(String value) {
    return FuelType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FuelType.petrol,
    );
  }
}
