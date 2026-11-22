import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:frontend/main.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  testWidgets(
    'Vehicles screen renders table, filters, and pagination on desktop',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const ProviderScope(child: StarkGroupVmsApp()));
      await tester.pumpAndSettle();

      // Verify title and Add Vehicle button
      expect(find.text('Vehicles'), findsWidgets);
      expect(find.text('Add Vehicle'), findsWidgets);

      // Verify search and filter controls
      expect(find.byType(ShadInput), findsWidgets);
      expect(find.text('All Vehicle Types'), findsOneWidget);
      expect(find.text('All Fuel Types'), findsOneWidget);
      expect(find.text('All Statuses'), findsOneWidget);

      // Verify sample vehicle table content
      expect(find.text('DM-GA-11-2041'), findsOneWidget);
      expect(find.text('Corolla Altis'), findsOneWidget);
      expect(find.text('Rafiqul Islam'), findsOneWidget);
      expect(find.text('AVAILABLE'), findsWidgets);

      // Verify pagination
      expect(
        find.textContaining('Showing 1-10 of 12 vehicles'),
        findsOneWidget,
      );
      expect(find.text('Page 1 of 2'), findsOneWidget);

      // Test search filter
      await tester.enterText(find.byType(EditableText).first, 'Pajero');
      await tester.pumpAndSettle();

      expect(find.text('DM-GHA-14-5592'), findsOneWidget);
      expect(find.text('Pajero Sport'), findsOneWidget);
      expect(find.text('DM-GA-11-2041'), findsNothing);

      // Test no results state
      await tester.enterText(
        find.byType(EditableText).first,
        'NonExistentVehicle12345',
      );
      await tester.pumpAndSettle();

      expect(find.text('No vehicles found'), findsOneWidget);
      expect(find.text('Reset Filters'), findsWidgets);
    },
  );
}
