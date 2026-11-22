import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:frontend/features/vehicles/models/vehicle.dart';
import 'package:frontend/features/vehicles/widgets/vehicle_form.dart';

class EditVehicleScreen extends StatelessWidget {
  final Vehicle? vehicle;

  const EditVehicleScreen({super.key, this.vehicle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ShadTheme.of(context).colorScheme;

    if (vehicle == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.triangleAlert,
                size: 40,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(height: 12),
              Text(
                'Vehicle Not Found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.foreground,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Please select a vehicle from the list to edit its details.',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ShadButton(
                onPressed: () => context.go('/vehicles'),
                child: const Text('Back to Vehicles'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBreadcrumb(context),
              const SizedBox(height: 12),
              _buildHeader(context),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.border),
                ),
                child: VehicleForm(
                  initialVehicle: vehicle,
                  onCancel: () => context.go('/vehicles'),
                  onSuccess: (_) => context.go('/vehicles'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreadcrumb(BuildContext context) {
    final colorScheme = ShadTheme.of(context).colorScheme;

    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => context.go('/vehicles'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.arrowLeft,
                  size: 14,
                  color: colorScheme.mutedForeground,
                ),
                const SizedBox(width: 6),
                Text(
                  'Vehicles',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '/',
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.mutedForeground.withAlpha(120),
            ),
          ),
        ),
        Text(
          'Edit Vehicle',
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = ShadTheme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Edit Vehicle',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: colorScheme.foreground,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Update vehicle specifications and driver assignment for ${vehicle!.vehicleNumber}.',
          style: TextStyle(fontSize: 14, color: colorScheme.mutedForeground),
        ),
      ],
    );
  }
}
