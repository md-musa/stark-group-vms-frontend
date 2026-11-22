import 'package:material_ui/material_ui.dart';
import 'package:frontend/features/vehicles/models/vehicle_enums.dart';

class VehicleStatusBadge extends StatelessWidget {
  final VehicleStatus status;

  const VehicleStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border, dotColor) = switch (status) {
      VehicleStatus.available => (
        const Color(0xFFF0FDF4),
        const Color(0xFF166534),
        const Color(0xFFBBF7D0),
        const Color(0xFF22C55E),
      ),
      VehicleStatus.inUse => (
        const Color(0xFFEFF6FF),
        const Color(0xFF1E40AF),
        const Color(0xFFBFDBFE),
        const Color(0xFF3B82F6),
      ),
      VehicleStatus.maintenance => (
        const Color(0xFFFFFBEB),
        const Color(0xFF92400E),
        const Color(0xFFFDE68A),
        const Color(0xFFF59E0B),
      ),
      VehicleStatus.inactive => (
        const Color(0xFFF4F4F5),
        const Color(0xFF52525B),
        const Color(0xFFE4E4E7),
        const Color(0xFF71717A),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            status.value,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
