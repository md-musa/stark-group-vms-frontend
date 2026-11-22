import 'package:material_ui/material_ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class VehicleLoadingState extends StatelessWidget {
  const VehicleLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ShadTheme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading vehicles...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VehicleEmptyState extends StatelessWidget {
  final VoidCallback onAddVehicle;

  const VehicleEmptyState({super.key, required this.onAddVehicle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ShadTheme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.car,
                size: 32,
                color: colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No vehicles in fleet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.foreground,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Get started by adding your first vehicle to the Fleetora fleet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 20),
            ShadButton(
              size: ShadButtonSize.sm,
              onPressed: onAddVehicle,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.plus, size: 16),
                  SizedBox(width: 6),
                  Text('Add Vehicle'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VehicleNoResultsState extends StatelessWidget {
  final VoidCallback onResetFilters;

  const VehicleNoResultsState({super.key, required this.onResetFilters});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ShadTheme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.searchX,
                size: 32,
                color: colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No vehicles found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.foreground,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No vehicles match your current search query or filter criteria.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 20),
            ShadButton.outline(
              size: ShadButtonSize.sm,
              onPressed: onResetFilters,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.rotateCcw, size: 14),
                  SizedBox(width: 6),
                  Text('Reset Filters'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VehicleErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const VehicleErrorState({super.key, this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ShadTheme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.triangleAlert,
                size: 32,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load vehicles',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.foreground,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message ??
                  'An unexpected error occurred while fetching fleet data.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 20),
            ShadButton.outline(
              size: ShadButtonSize.sm,
              onPressed: onRetry,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.refreshCw, size: 14),
                  SizedBox(width: 6),
                  Text('Retry'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
