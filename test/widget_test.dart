import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:frontend/main.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/vehicles/models/create_vehicle_request.dart';
import 'package:frontend/features/vehicles/models/page_response.dart';
import 'package:frontend/features/vehicles/models/update_vehicle_request.dart';
import 'package:frontend/features/vehicles/models/vehicle.dart';
import 'package:frontend/features/vehicles/models/vehicle_enums.dart';
import 'package:frontend/features/vehicles/models/vehicle_query_params.dart';
import 'package:frontend/features/vehicles/providers/vehicle_providers.dart';
import 'package:frontend/features/vehicles/repositories/vehicle_repository.dart';

class MockVehicleRepository extends Fake implements VehicleRepository {
  CreateVehicleRequest? lastCreatedRequest;
  UpdateVehicleRequest? lastUpdatedRequest;
  int? lastUpdatedId;
  bool shouldThrowConflict = false;
  List<Vehicle> seedVehicles = [];

  @override
  Future<PageResponse<Vehicle>> getVehicles(VehicleQueryParams params) async {
    return PageResponse<Vehicle>(
      content: seedVehicles,
      page: 0,
      size: 10,
      totalElements: seedVehicles.length,
      totalPages: seedVehicles.isEmpty ? 0 : 1,
      first: true,
      last: true,
      hasNext: false,
      hasPrevious: false,
    );
  }

  @override
  Future<Vehicle> createVehicle(CreateVehicleRequest request) async {
    lastCreatedRequest = request;
    if (shouldThrowConflict) {
      throw ApiException(
        message: 'A vehicle with this vehicle number already exists.',
        statusCode: 409,
      );
    }
    return Vehicle(
      id: 99,
      vehicleNumber: request.vehicleNumber,
      vehicleType: request.vehicleType,
      brand: request.brand,
      model: request.model,
      manufacturingYear: request.manufacturingYear,
      color: request.color,
      fuelType: request.fuelType,
      seatingCapacity: request.seatingCapacity,
      driverName: request.driverName,
      driverPhone: request.driverPhone,
      status: VehicleStatus.available,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<Vehicle> updateVehicle(int id, UpdateVehicleRequest request) async {
    lastUpdatedId = id;
    lastUpdatedRequest = request;
    if (shouldThrowConflict) {
      throw ApiException(
        message: 'A vehicle with this vehicle number already exists.',
        statusCode: 409,
      );
    }
    return Vehicle(
      id: id,
      vehicleNumber: request.vehicleNumber,
      vehicleType: request.vehicleType,
      brand: request.brand,
      model: request.model,
      manufacturingYear: request.manufacturingYear,
      color: request.color,
      fuelType: request.fuelType,
      seatingCapacity: request.seatingCapacity,
      driverName: request.driverName,
      driverPhone: request.driverPhone,
      status: VehicleStatus.available,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  int? lastDeletedId;
  bool shouldThrowDeleteError = false;

  @override
  Future<void> deleteVehicle(int id) async {
    lastDeletedId = id;
    if (shouldThrowDeleteError) {
      throw const ApiException(
        message: 'Failed to delete vehicle. Vehicle may be in active use.',
        statusCode: 400,
      );
    }
    seedVehicles.removeWhere((v) => v.id == id);
  }
}

Vehicle _sampleVehicle() => Vehicle(
  id: 1,
  vehicleNumber: 'DM-GA-11-2041',
  vehicleType: VehicleType.car,
  brand: 'Toyota',
  model: 'Corolla',
  manufacturingYear: 2022,
  color: 'White',
  fuelType: FuelType.petrol,
  seatingCapacity: 5,
  driverName: 'Rafiqul Islam',
  driverPhone: '+880 1712-345678',
  status: VehicleStatus.available,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

void main() {
  testWidgets(
    'Add Vehicle form validation prevents submission on empty required fields',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockRepo = MockVehicleRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [vehicleRepositoryProvider.overrideWithValue(mockRepo)],
          child: const StarkGroupVmsApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Vehicle').first);
      await tester.pumpAndSettle();

      expect(find.text('Vehicle Specifications'), findsOneWidget);
      expect(find.text('Save Vehicle'), findsOneWidget);

      await tester.tap(find.text('Save Vehicle'));
      await tester.pumpAndSettle();

      expect(find.text('Vehicle number is required'), findsOneWidget);
      expect(find.text('Please select a vehicle type'), findsOneWidget);
      expect(find.text('Brand is required'), findsOneWidget);
      expect(find.text('Model is required'), findsOneWidget);
      expect(find.text('Please select a fuel type'), findsOneWidget);

      expect(mockRepo.lastCreatedRequest, isNull);
    },
  );

  testWidgets(
    'Add Vehicle validates manufacturing year, seating capacity, and phone format',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockRepo = MockVehicleRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [vehicleRepositoryProvider.overrideWithValue(mockRepo)],
          child: const StarkGroupVmsApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Vehicle').first);
      await tester.pumpAndSettle();

      final textFields = find.byType(EditableText);
      await tester.enterText(textFields.at(0), 'DM-GA-99-0001');
      await tester.enterText(textFields.at(1), 'Toyota');
      await tester.enterText(textFields.at(2), 'Corolla');
      await tester.enterText(textFields.at(3), '1850');
      await tester.enterText(textFields.at(5), '0');
      await tester.enterText(textFields.at(7), 'invalid_phone_#@');

      await tester.tap(find.text('Save Vehicle'));
      await tester.pumpAndSettle();

      expect(find.text('Year must be between 1900 and 2100'), findsOneWidget);
      expect(
        find.text('Seating capacity must be a positive number'),
        findsOneWidget,
      );
      expect(find.text('Phone contains invalid characters'), findsOneWidget);
    },
  );

  testWidgets('Add Vehicle handles duplicate vehicle number error (HTTP 409)', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final mockRepo = MockVehicleRepository()..shouldThrowConflict = true;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [vehicleRepositoryProvider.overrideWithValue(mockRepo)],
        child: const StarkGroupVmsApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Vehicle').first);
    await tester.pumpAndSettle();

    final textFields = find.byType(EditableText);
    await tester.enterText(textFields.at(0), 'DM-GA-11-2041');
    await tester.enterText(textFields.at(1), 'Toyota');
    await tester.enterText(textFields.at(2), 'Corolla');

    await tester.tap(find.text('Select vehicle type'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Car').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select fuel type'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Octane').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Vehicle'));
    await tester.pumpAndSettle();

    expect(find.textContaining('already exists'), findsWidgets);
  });

  testWidgets('Add Vehicle successfully submits and navigates back to list', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final mockRepo = MockVehicleRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [vehicleRepositoryProvider.overrideWithValue(mockRepo)],
        child: const StarkGroupVmsApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Vehicle').first);
    await tester.pumpAndSettle();

    final textFields = find.byType(EditableText);
    await tester.enterText(textFields.at(0), 'DM-GA-88-1234');
    await tester.enterText(textFields.at(1), 'Honda');
    await tester.enterText(textFields.at(2), 'Civic');
    await tester.enterText(textFields.at(3), '2023');
    await tester.enterText(textFields.at(4), 'Black');
    await tester.enterText(textFields.at(5), '5');
    await tester.enterText(textFields.at(6), 'Rahim Uddin');
    await tester.enterText(textFields.at(7), '+880 1711-223344');

    await tester.tap(find.text('Select vehicle type'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Car').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select fuel type'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Petrol').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Vehicle'));
    await tester.pumpAndSettle();

    expect(mockRepo.lastCreatedRequest, isNotNull);
    expect(mockRepo.lastCreatedRequest!.vehicleNumber, 'DM-GA-88-1234');
    expect(mockRepo.lastCreatedRequest!.brand, 'Honda');
    expect(mockRepo.lastCreatedRequest!.model, 'Civic');
    expect(mockRepo.lastCreatedRequest!.manufacturingYear, 2023);
    expect(mockRepo.lastCreatedRequest!.color, 'Black');
    expect(mockRepo.lastCreatedRequest!.fuelType, FuelType.petrol);
    expect(mockRepo.lastCreatedRequest!.seatingCapacity, 5);
    expect(mockRepo.lastCreatedRequest!.driverName, 'Rahim Uddin');
    expect(mockRepo.lastCreatedRequest!.driverPhone, '+880 1711-223344');

    expect(
      find.text('Manage, monitor, and inspect your organization fleet.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'Edit Vehicle dialog opens pre-populated with existing vehicle data',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final vehicle = _sampleVehicle();
      final mockRepo = MockVehicleRepository()..seedVehicles = [vehicle];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [vehicleRepositoryProvider.overrideWithValue(mockRepo)],
          child: const StarkGroupVmsApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Click the Edit (pencil) button on the first row
      await tester.tap(find.byIcon(LucideIcons.pencil).first);
      await tester.pumpAndSettle();

      // Dialog should open with the vehicle's data pre-populated
      expect(find.text('Edit Vehicle (DM-GA-11-2041)'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // The vehicle number field should be pre-filled
      expect(find.text('DM-GA-11-2041'), findsWidgets);
    },
  );

  testWidgets('Edit Vehicle successfully submits update and closes dialog', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final vehicle = _sampleVehicle();
    final mockRepo = MockVehicleRepository()..seedVehicles = [vehicle];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [vehicleRepositoryProvider.overrideWithValue(mockRepo)],
        child: const StarkGroupVmsApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.pencil).first);
    await tester.pumpAndSettle();

    expect(find.text('Save Changes'), findsOneWidget);

    await tester.ensureVisible(find.text('Save Changes'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(mockRepo.lastUpdatedId, 1);
    expect(mockRepo.lastUpdatedRequest, isNotNull);
    expect(mockRepo.lastUpdatedRequest!.vehicleNumber, 'DM-GA-11-2041');
    expect(mockRepo.lastUpdatedRequest!.brand, 'Toyota');
  });

  testWidgets(
    'Edit Vehicle handles duplicate vehicle number conflict (HTTP 409)',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final vehicle = _sampleVehicle();
      final mockRepo = MockVehicleRepository()
        ..seedVehicles = [vehicle]
        ..shouldThrowConflict = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [vehicleRepositoryProvider.overrideWithValue(mockRepo)],
          child: const StarkGroupVmsApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.pencil).first);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Save Changes'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      // Conflict error should appear
      expect(find.textContaining('already exists'), findsWidgets);
    },
  );

  testWidgets(
    'Delete Vehicle shows confirmation dialog with vehicle number and allows cancellation',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final vehicle = _sampleVehicle();
      final mockRepo = MockVehicleRepository()..seedVehicles = [vehicle];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [vehicleRepositoryProvider.overrideWithValue(mockRepo)],
          child: const StarkGroupVmsApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byIcon(LucideIcons.trash2).first);
      await tester.pumpAndSettle();

      // Tap Delete (trash) icon
      await tester.tap(find.byIcon(LucideIcons.trash2).first);
      await tester.pumpAndSettle();

      // Verify dialog is open and displays vehicle number
      expect(find.text('Delete Vehicle'), findsOneWidget);
      expect(find.textContaining('DM-GA-11-2041'), findsWidgets);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify repository delete was not called
      expect(mockRepo.lastDeletedId, isNull);
    },
  );

  testWidgets(
    'Delete Vehicle successfully deletes vehicle and triggers list refresh',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final vehicle = _sampleVehicle();
      final mockRepo = MockVehicleRepository()..seedVehicles = [vehicle];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [vehicleRepositoryProvider.overrideWithValue(mockRepo)],
          child: const StarkGroupVmsApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byIcon(LucideIcons.trash2).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.trash2).first);
      await tester.pumpAndSettle();

      // Tap Delete in dialog
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify repository delete was called with vehicle id
      expect(mockRepo.lastDeletedId, 1);
      expect(mockRepo.seedVehicles, isEmpty);
    },
  );

  testWidgets('Delete Vehicle handles API errors and displays error message', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final vehicle = _sampleVehicle();
    final mockRepo = MockVehicleRepository()
      ..seedVehicles = [vehicle]
      ..shouldThrowDeleteError = true;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [vehicleRepositoryProvider.overrideWithValue(mockRepo)],
        child: const StarkGroupVmsApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byIcon(LucideIcons.trash2).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.trash2).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // Verify error is shown in dialog
    expect(
      find.text('Failed to delete vehicle. Vehicle may be in active use.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'Delete Vehicle adjusts page when deleting last item on page > 0',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final vehicle = _sampleVehicle();
      final mockRepo = MockVehicleRepository()..seedVehicles = [vehicle];

      final container = ProviderContainer(
        overrides: [vehicleRepositoryProvider.overrideWithValue(mockRepo)],
      );
      container.read(vehicleQueryParamsProvider.notifier).state =
          const VehicleQueryParams(page: 1);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const StarkGroupVmsApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byIcon(LucideIcons.trash2).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.trash2).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(container.read(vehicleQueryParamsProvider).page, 0);
    },
  );

  testWidgets(
    'Sidebar drawer toggles open on mobile view when menu button is pressed',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockRepo = MockVehicleRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [vehicleRepositoryProvider.overrideWithValue(mockRepo)],
          child: const StarkGroupVmsApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap menu button
      await tester.tap(find.byIcon(LucideIcons.menu));
      await tester.pumpAndSettle();

      // Drawer should be open displaying sidebar branding and navigation
      expect(find.byType(Drawer), findsOneWidget);
      expect(find.text('Stark Group'), findsWidgets);
      expect(find.text('Settings'), findsWidgets);
    },
  );
}
