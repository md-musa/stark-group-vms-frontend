import 'package:material_ui/material_ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:frontend/features/vehicles/models/vehicle_enums.dart';

class VehicleFiltersBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VehicleType? selectedType;
  final ValueChanged<VehicleType?> onTypeChanged;
  final FuelType? selectedFuel;
  final ValueChanged<FuelType?> onFuelChanged;
  final VehicleStatus? selectedStatus;
  final ValueChanged<VehicleStatus?> onStatusChanged;
  final VoidCallback onResetAll;
  final bool hasActiveFilters;

  const VehicleFiltersBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.selectedType,
    required this.onTypeChanged,
    required this.selectedFuel,
    required this.onFuelChanged,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onResetAll,
    required this.hasActiveFilters,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = ShadTheme.of(context).colorScheme;
    final breakpoint = context.breakpoint;
    final isDesktop = breakpoint >= ShadBreakpointLG(1024);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.border),
      ),
      child: isDesktop
          ? _buildDesktopLayout(context)
          : _buildMobileLayout(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 3, child: _buildSearchField()),
        const SizedBox(width: 12),
        Expanded(flex: 2, child: _buildTypeFilter()),
        const SizedBox(width: 12),
        Expanded(flex: 2, child: _buildFuelFilter()),
        const SizedBox(width: 12),
        Expanded(flex: 2, child: _buildStatusFilter()),
        if (hasActiveFilters) ...[
          const SizedBox(width: 12),
          ShadButton.outline(
            size: ShadButtonSize.sm,
            onPressed: onResetAll,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.rotateCcw, size: 14),
                SizedBox(width: 6),
                Text('Reset'),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSearchField(),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(width: 170, child: _buildTypeFilter()),
            SizedBox(width: 170, child: _buildFuelFilter()),
            SizedBox(width: 170, child: _buildStatusFilter()),
            if (hasActiveFilters)
              ShadButton.outline(
                size: ShadButtonSize.sm,
                onPressed: onResetAll,
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
      ],
    );
  }

  Widget _buildSearchField() {
    return ShadInput(
      controller: searchController,
      onChanged: onSearchChanged,
      placeholder: const Text('Search by number, brand, model, driver...'),
      leading: const Padding(
        padding: EdgeInsets.only(left: 8, right: 4),
        child: Icon(LucideIcons.search, size: 16, color: Color(0xFF71717A)),
      ),
      trailing: searchController.text.isNotEmpty
          ? GestureDetector(
              onTap: onClearSearch,
              child: const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(LucideIcons.x, size: 14, color: Color(0xFF71717A)),
              ),
            )
          : null,
    );
  }

  Widget _buildTypeFilter() {
    return ShadSelect<VehicleType?>(
      initialValue: selectedType,
      placeholder: const Text('All Vehicle Types'),
      selectedOptionBuilder: (context, value) =>
          Text(value == null ? 'All Vehicle Types' : 'Type: ${value.label}'),
      onChanged: onTypeChanged,
      options: [
        const ShadOption<VehicleType?>(
          value: null,
          child: Text('All Vehicle Types'),
        ),
        ...VehicleType.values.map(
          (type) =>
              ShadOption<VehicleType?>(value: type, child: Text(type.label)),
        ),
      ],
    );
  }

  Widget _buildFuelFilter() {
    return ShadSelect<FuelType?>(
      initialValue: selectedFuel,
      placeholder: const Text('All Fuel Types'),
      selectedOptionBuilder: (context, value) =>
          Text(value == null ? 'All Fuel Types' : 'Fuel: ${value.label}'),
      onChanged: onFuelChanged,
      options: [
        const ShadOption<FuelType?>(value: null, child: Text('All Fuel Types')),
        ...FuelType.values.map(
          (fuel) => ShadOption<FuelType?>(value: fuel, child: Text(fuel.label)),
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return ShadSelect<VehicleStatus?>(
      initialValue: selectedStatus,
      placeholder: const Text('All Statuses'),
      selectedOptionBuilder: (context, value) =>
          Text(value == null ? 'All Statuses' : 'Status: ${value.label}'),
      onChanged: onStatusChanged,
      options: [
        const ShadOption<VehicleStatus?>(
          value: null,
          child: Text('All Statuses'),
        ),
        ...VehicleStatus.values.map(
          (status) => ShadOption<VehicleStatus?>(
            value: status,
            child: Text(status.label),
          ),
        ),
      ],
    );
  }
}
