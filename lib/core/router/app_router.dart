import 'package:go_router/go_router.dart';
import 'package:frontend/features/vehicles/models/vehicle.dart';
import 'package:frontend/features/vehicles/screens/add_vehicle_screen.dart';
import 'package:frontend/features/vehicles/screens/edit_vehicle_screen.dart';
import 'package:frontend/features/vehicles/screens/vehicles_screen.dart';
import 'package:frontend/features/settings/screens/settings_screen.dart';
import 'package:frontend/shared/widgets/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/vehicles',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/vehicles',
          name: 'vehicles',
          builder: (context, state) => const VehiclesScreen(),
          routes: [
            GoRoute(
              path: 'new',
              name: 'add-vehicle',
              builder: (context, state) => const AddVehicleScreen(),
            ),
            GoRoute(
              path: ':id/edit',
              name: 'edit-vehicle',
              builder: (context, state) {
                final vehicle = state.extra as Vehicle?;
                return EditVehicleScreen(vehicle: vehicle);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);
