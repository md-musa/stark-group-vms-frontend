import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('App smoke test on desktop', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const ProviderScope(child: StarkGroupVmsApp()));
    await tester.pumpAndSettle();

    expect(find.text('Stark Group'), findsOneWidget);
    expect(find.text('Vehicles'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });
}
