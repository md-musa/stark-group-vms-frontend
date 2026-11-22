import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:frontend/main.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/vehicles/models/create_vehicle_request.dart';
import 'package:frontend/features/vehicles/models/page_response.dart';
import 'package:frontend/features/vehicles/models/vehicle.dart';
import 'package:frontend/features/vehicles/models/vehicle_enums.dart';
import 'package:frontend/features/vehicles/models/vehicle_query_params.dart';
import 'package:frontend/features/vehicles/repositories/vehicle_repository.dart';

class MockVehicleRepository extends Fake implements VehicleRepository {
  CreateVehicleRequest? lastCreatedRequest;
  bool shouldThrowConflict = false;

  @override
  Future<PageResponse<Vehicle>> getVehicles(VehicleQueryParams params) async {
    return PageResponse<Vehicle>.empty();
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
}

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

      // Tap "Add Vehicle" button from listing screen
      await tester.tap(find.text('Add Vehicle').first);
      await tester.pumpAndSettle();

      // Verify on Add Vehicle page
      expect(find.text('Vehicle Specifications'), findsOneWidget);
      expect(find.text('Save Vehicle'), findsOneWidget);

      // Tap "Save Vehicle" without filling required fields
      await tester.tap(find.text('Save Vehicle'));
      await tester.pumpAndSettle();

      // Verify validation errors
      expect(find.text('Vehicle number is required'), findsOneWidget);
      expect(find.text('Please select a vehicle type'), findsOneWidget);
      expect(find.text('Brand is required'), findsOneWidget);
      expect(find.text('Model is required'), findsOneWidget);
      expect(find.text('Please select a fuel type'), findsOneWidget);

      // Verify repository was not called
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

      // Enter invalid year (e.g. 1850)
      final textFields = find.byType(EditableText);
      await tester.enterText(
        textFields.at(0),
        'DM-GA-99-0001',
      ); // vehicle number
      await tester.enterText(textFields.at(1), 'Toyota'); // brand
      await tester.enterText(textFields.at(2), 'Corolla'); // model
      await tester.enterText(textFields.at(3), '1850'); // year (invalid < 1900)
      await tester.enterText(
        textFields.at(5),
        '0',
      ); // seating capacity (invalid <= 0)
      await tester.enterText(
        textFields.at(7),
        'invalid_phone_#@',
      ); // phone (invalid pattern)

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
    await tester.enterText(
      textFields.at(0),
      'DM-GA-11-2041',
    ); // duplicate number
    await tester.enterText(textFields.at(1), 'Toyota');
    await tester.enterText(textFields.at(2), 'Corolla');

    // Select Vehicle Type
    await tester.tap(find.text('Select vehicle type'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Car').last);
    await tester.pumpAndSettle();

    // Select Fuel Type
    await tester.tap(find.text('Select fuel type'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Octane').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Vehicle'));
    await tester.pumpAndSettle();

    // Verify duplicate error feedback
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

    // Select Vehicle Type
    await tester.tap(find.text('Select vehicle type'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Car').last);
    await tester.pumpAndSettle();

    // Select Fuel Type
    await tester.tap(find.text('Select fuel type'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Petrol').last);
    await tester.pumpAndSettle();

    // Submit
    await tester.tap(find.text('Save Vehicle'));
    await tester.pumpAndSettle();

    // Verify repository received the right payload
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

    // Verify navigated back to vehicles list
    expect(
      find.text('Manage, monitor, and inspect your organization fleet.'),
      findsOneWidget,
    );
  });
}
