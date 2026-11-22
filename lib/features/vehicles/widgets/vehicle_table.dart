import 'package:material_ui/material_ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:frontend/features/vehicles/models/vehicle.dart';
import 'package:frontend/features/vehicles/models/vehicle_enums.dart';
import 'package:frontend/features/vehicles/widgets/vehicle_status_badge.dart';

class VehicleTable extends StatelessWidget {
  final List<Vehicle> vehicles;
  final ValueChanged<Vehicle>? onActionTap;

  const VehicleTable({super.key, required this.vehicles, this.onActionTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ShadTheme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                colorScheme.muted.withAlpha(80),
              ),
              dividerThickness: 1,
              horizontalMargin: 20,
              columnSpacing: 24,
              dataRowMinHeight: 56,
              dataRowMaxHeight: 56,
              headingRowHeight: 44,
              columns: [
                _buildHeaderColumn('Vehicle Number', context),
                _buildHeaderColumn('Type', context),
                _buildHeaderColumn('Brand / Model', context),
                _buildHeaderColumn('Year', context),
                _buildHeaderColumn('Driver', context),
                _buildHeaderColumn('Fuel', context),
                _buildHeaderColumn('Status', context),
                _buildHeaderColumn('Actions', context, isCenter: true),
              ],
              rows: vehicles.map((v) => _buildDataRow(v, context)).toList(),
            ),
          ),
        );
      },
    );
  }

  DataColumn _buildHeaderColumn(
    String label,
    BuildContext context, {
    bool isCenter = false,
  }) {
    final colorScheme = ShadTheme.of(context).colorScheme;

    return DataColumn(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colorScheme.mutedForeground,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  DataRow _buildDataRow(Vehicle vehicle, BuildContext context) {
    final colorScheme = ShadTheme.of(context).colorScheme;

    return DataRow(
      cells: [
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _iconForType(vehicle.vehicleType),
                  size: 15,
                  color: colorScheme.foreground,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                vehicle.vehicleNumber,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.foreground,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Text(
            vehicle.vehicleType.label,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.foreground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vehicle.brand,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.foreground,
                ),
              ),
              Text(
                vehicle.model,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Text(
            '${vehicle.manufacturingYear}',
            style: TextStyle(fontSize: 13, color: colorScheme.foreground),
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vehicle.driverName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.foreground,
                ),
              ),
              Text(
                vehicle.driverPhone,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.secondary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              vehicle.fuelType.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: colorScheme.foreground,
              ),
            ),
          ),
        ),
        DataCell(VehicleStatusBadge(status: vehicle.status)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShadTooltip(
                builder: (_) => const Text('View details (coming soon)'),
                child: ShadButton.ghost(
                  size: ShadButtonSize.sm,
                  onPressed: () => onActionTap?.call(vehicle),
                  child: const Icon(LucideIcons.eye, size: 16),
                ),
              ),
              ShadTooltip(
                builder: (_) => const Text('More actions (coming soon)'),
                child: ShadButton.ghost(
                  size: ShadButtonSize.sm,
                  onPressed: () => onActionTap?.call(vehicle),
                  child: const Icon(LucideIcons.ellipsis, size: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _iconForType(VehicleType type) {
    return switch (type) {
      VehicleType.car => LucideIcons.car,
      VehicleType.suv => LucideIcons.carFront,
      VehicleType.van => LucideIcons.bus,
      VehicleType.microbus => LucideIcons.bus,
      VehicleType.bus => LucideIcons.bus,
      VehicleType.truck => LucideIcons.truck,
      VehicleType.pickup => LucideIcons.truck,
      VehicleType.motorcycle => LucideIcons.bike,
    };
  }
}
