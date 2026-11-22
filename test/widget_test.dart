import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:frontend/main.dart';
import 'package:frontend/features/vehicles/models/page_response.dart';
import 'package:frontend/features/vehicles/models/vehicle.dart';
import 'package:frontend/features/vehicles/models/vehicle_enums.dart';
import 'package:frontend/features/vehicles/models/vehicle_query_params.dart';
import 'package:frontend/features/vehicles/providers/vehicle_providers.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  final sampleVehicles = [
    Vehicle(
      id: 1,
      vehicleNumber: 'DM-GA-11-2041',
      vehicleType: VehicleType.car,
      brand: 'Toyota',
      model: 'Corolla Altis',
      manufacturingYear: 2022,
      color: 'Pearl White',
      fuelType: FuelType.hybrid,
      seatingCapacity: 5,
      driverName: 'Rafiqul Islam',
      driverPhone: '+880 1712-345678',
      status: VehicleStatus.available,
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 1, 15),
    ),
    Vehicle(
      id: 2,
      vehicleNumber: 'DM-GHA-14-5592',
      vehicleType: VehicleType.suv,
      brand: 'Mitsubishi',
      model: 'Pajero Sport',
      manufacturingYear: 2021,
      color: 'Titanium Gray',
      fuelType: FuelType.diesel,
      seatingCapacity: 7,
      driverName: 'Kamal Hossain',
      driverPhone: '+880 1819-234567',
      status: VehicleStatus.inUse,
      createdAt: DateTime(2024, 1, 16),
      updatedAt: DateTime(2024, 1, 16),
    ),
  ];

  testWidgets(
    'Vehicles screen renders API data, table headers, and pagination',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final testPage = PageResponse<Vehicle>(
        content: sampleVehicles,
        page: 0,
        size: 10,
        totalElements: 2,
        totalPages: 1,
        first: true,
        last: true,
        hasNext: false,
        hasPrevious: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehicleListProvider.overrideWith((ref) => Future.value(testPage)),
          ],
          child: const StarkGroupVmsApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header and actions
      expect(find.text('Vehicles'), findsWidgets);
      expect(find.text('Add Vehicle'), findsWidgets);
      expect(find.text('Refresh'), findsOneWidget);

      // Verify filter dropdowns
      expect(find.byType(ShadInput), findsWidgets);
      expect(find.text('All Vehicle Types'), findsOneWidget);
      expect(find.text('All Fuel Types'), findsOneWidget);
      expect(find.text('All Statuses'), findsOneWidget);

      // Verify table content from API response
      expect(find.text('DM-GA-11-2041'), findsOneWidget);
      expect(find.text('Corolla Altis'), findsOneWidget);
      expect(find.text('Rafiqul Islam'), findsOneWidget);
      expect(find.text('DM-GHA-14-5592'), findsOneWidget);
      expect(find.text('Pajero Sport'), findsOneWidget);
      expect(find.text('Kamal Hossain'), findsOneWidget);

      // Verify pagination
      expect(find.textContaining('Showing 1-2 of 2 vehicles'), findsOneWidget);
      expect(find.text('Page 1 of 1'), findsOneWidget);
    },
  );

  testWidgets('Vehicles screen renders error state and retry on API failure', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vehicleListProvider.overrideWith(
            (ref) => Future.error(
              Exception(
                'Unable to connect to server. Please verify the backend is running.',
              ),
            ),
          ),
        ],
        child: const StarkGroupVmsApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Failed to load vehicles'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets(
    'Vehicles screen renders empty state when fleet has no vehicles',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehicleListProvider.overrideWith(
              (ref) => Future.value(PageResponse<Vehicle>.empty()),
            ),
          ],
          child: const StarkGroupVmsApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No vehicles in fleet'), findsOneWidget);
    },
  );

  testWidgets(
    'Vehicles screen renders no-results state when filters return zero items',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehicleQueryParamsProvider.overrideWith(
              (ref) => const VehicleQueryParams(search: 'UnknownQuery'),
            ),
            vehicleListProvider.overrideWith(
              (ref) => Future.value(PageResponse<Vehicle>.empty()),
            ),
          ],
          child: const StarkGroupVmsApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No vehicles found'), findsOneWidget);
      expect(find.text('Reset Filters'), findsWidgets);
    },
  );
}
