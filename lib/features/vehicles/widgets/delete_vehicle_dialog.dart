import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/vehicles/models/vehicle.dart';
import 'package:frontend/features/vehicles/repositories/vehicle_repository.dart';

class DeleteVehicleDialog extends ConsumerStatefulWidget {
  final Vehicle vehicle;
  final VoidCallback? onDeleted;

  const DeleteVehicleDialog({super.key, required this.vehicle, this.onDeleted});

  @override
  ConsumerState<DeleteVehicleDialog> createState() =>
      _DeleteVehicleDialogState();
}

class _DeleteVehicleDialogState extends ConsumerState<DeleteVehicleDialog> {
  bool _isDeleting = false;
  String? _errorMessage;

  Future<void> _handleDelete() async {
    if (_isDeleting) return;

    setState(() {
      _isDeleting = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(vehicleRepositoryProvider);
      await repository.deleteVehicle(widget.vehicle.id);

      if (mounted) {
        Navigator.of(context).pop(true);
        ShadToaster.of(context).show(
          ShadToast(
            title: const Text('Vehicle Deleted'),
            description: Text(
              'Vehicle "${widget.vehicle.vehicleNumber}" has been successfully deleted.',
            ),
          ),
        );
        widget.onDeleted?.call();
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isDeleting = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDeleting = false;
        _errorMessage = 'An unexpected error occurred while deleting the vehicle. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ShadTheme.of(context).colorScheme;

    return ShadDialog.alert(
      constraints: const BoxConstraints(maxWidth: 480),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              LucideIcons.triangleAlert,
              size: 18,
              color: Color(0xFFDC2626),
            ),
          ),
          const SizedBox(width: 10),
          const Text('Delete Vehicle'),
        ],
      ),
      description: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.mutedForeground,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(
                    text:
                        'Are you sure you want to permanently delete vehicle ',
                  ),
                  TextSpan(
                    text: widget.vehicle.vehicleNumber,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.foreground,
                    ),
                  ),
                  TextSpan(
                    text: ' (${widget.vehicle.brand} ${widget.vehicle.model})?',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.muted.withAlpha(80),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: colorScheme.border),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.info,
                    size: 14,
                    color: colorScheme.mutedForeground,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. Fleet assignments for this vehicle will be removed.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.mutedForeground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.circleAlert,
                      size: 14,
                      color: Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB91C1C),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        ShadButton.outline(
          enabled: !_isDeleting,
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ShadButton.destructive(
          enabled: !_isDeleting,
          onPressed: _handleDelete,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isDeleting) ...[
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Deleting...'),
              ] else ...[
                const Icon(LucideIcons.trash2, size: 16),
                const SizedBox(width: 6),
                const Text('Delete'),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
