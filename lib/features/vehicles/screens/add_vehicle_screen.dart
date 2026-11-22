import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:frontend/features/vehicles/widgets/vehicle_form.dart';

class AddVehicleScreen extends StatelessWidget {
  const AddVehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ShadTheme.of(context).colorScheme;
    final breakpoint = context.breakpoint;
    final isMobile = breakpoint < ShadBreakpointMD(768);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 16 : 24,
      ),
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
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                decoration: BoxDecoration(
                  color: colorScheme.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.border),
                ),
                child: VehicleForm(
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
          'Add Vehicle',
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
          'Add Vehicle',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: colorScheme.foreground,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Register a new vehicle into the Stark Group fleet system.',
          style: TextStyle(fontSize: 14, color: colorScheme.mutedForeground),
        ),
      ],
    );
  }
}
