import 'package:material_ui/material_ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:frontend/features/vehicles/data/mock_vehicles.dart';
import 'package:frontend/features/vehicles/models/vehicle.dart';
import 'package:frontend/features/vehicles/models/vehicle_enums.dart';
import 'package:frontend/features/vehicles/widgets/vehicle_filters_bar.dart';
import 'package:frontend/features/vehicles/widgets/vehicle_pagination_bar.dart';
import 'package:frontend/features/vehicles/widgets/vehicle_state_views.dart';
import 'package:frontend/features/vehicles/widgets/vehicle_table.dart';

enum ViewMode { normal, loading, empty, error }

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final TextEditingController _searchController = TextEditingController();

  VehicleType? _selectedType;
  FuelType? _selectedFuel;
  VehicleStatus? _selectedStatus;

  int _currentPage = 0;
  int _pageSize = 10;

  ViewMode _viewMode = ViewMode.normal;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _searchController.text.trim().isNotEmpty ||
      _selectedType != null ||
      _selectedFuel != null ||
      _selectedStatus != null;

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedType = null;
      _selectedFuel = null;
      _selectedStatus = null;
      _currentPage = 0;
    });
  }

  List<Vehicle> get _filteredVehicles {
    final query = _searchController.text.trim().toLowerCase();

    return kSampleVehicles.where((vehicle) {
      if (query.isNotEmpty) {
        final matchesNumber = vehicle.vehicleNumber.toLowerCase().contains(
          query,
        );
        final matchesBrand = vehicle.brand.toLowerCase().contains(query);
        final matchesModel = vehicle.model.toLowerCase().contains(query);
        final matchesDriver = vehicle.driverName.toLowerCase().contains(query);

        if (!matchesNumber &&
            !matchesBrand &&
            !matchesModel &&
            !matchesDriver) {
          return false;
        }
      }

      if (_selectedType != null && vehicle.vehicleType != _selectedType) {
        return false;
      }

      if (_selectedFuel != null && vehicle.fuelType != _selectedFuel) {
        return false;
      }

      if (_selectedStatus != null && vehicle.status != _selectedStatus) {
        return false;
      }

      return true;
    }).toList();
  }

  List<Vehicle> _paginatedVehicles(List<Vehicle> list) {
    final startIndex = _currentPage * _pageSize;
    if (startIndex >= list.length) {
      return [];
    }
    final endIndex = (startIndex + _pageSize).clamp(0, list.length);
    return list.sublist(startIndex, endIndex);
  }

  void _handleAddVehiclePlaceholder() {
    ShadToaster.of(context).show(
      const ShadToast(
        title: Text('Add Vehicle'),
        description: Text(
          'Vehicle registration feature will be enabled in the next update.',
        ),
      ),
    );
  }

  void _handleActionPlaceholder(Vehicle vehicle) {
    ShadToaster.of(context).show(
      ShadToast(
        title: Text(vehicle.vehicleNumber),
        description: const Text(
          'Vehicle action details will be enabled in the upcoming task.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ShadTheme.of(context).colorScheme;
    final breakpoint = context.breakpoint;
    final isDesktop = breakpoint >= ShadBreakpointLG(1024);

    final filtered = _filteredVehicles;
    final totalFiltered = filtered.length;
    final totalPages = (totalFiltered / _pageSize).ceil();
    final pageVehicles = _paginatedVehicles(filtered);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 28 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, isDesktop),
          const SizedBox(height: 20),
          VehicleFiltersBar(
            searchController: _searchController,
            onSearchChanged: (_) => setState(() => _currentPage = 0),
            onClearSearch: () {
              _searchController.clear();
              setState(() => _currentPage = 0);
            },
            selectedType: _selectedType,
            onTypeChanged: (type) => setState(() {
              _selectedType = type;
              _currentPage = 0;
            }),
            selectedFuel: _selectedFuel,
            onFuelChanged: (fuel) => setState(() {
              _selectedFuel = fuel;
              _currentPage = 0;
            }),
            selectedStatus: _selectedStatus,
            onStatusChanged: (status) => setState(() {
              _selectedStatus = status;
              _currentPage = 0;
            }),
            onResetAll: _resetFilters,
            hasActiveFilters: _hasActiveFilters,
          ),
          const SizedBox(height: 16),
          _buildTableCard(
            context,
            totalFiltered: totalFiltered,
            totalPages: totalPages,
            pageVehicles: pageVehicles,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDesktop) {
    final colorScheme = ShadTheme.of(context).colorScheme;

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vehicles',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: colorScheme.foreground,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage, monitor, and inspect your organization fleet.',
          style: TextStyle(fontSize: 14, color: colorScheme.mutedForeground),
        ),
      ],
    );

    final actionBlock = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatePreviewDropdown(),
        const SizedBox(width: 12),
        ShadButton(
          onPressed: _handleAddVehiclePlaceholder,
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
    );

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [titleBlock, actionBlock],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [titleBlock, const SizedBox(height: 14), actionBlock],
    );
  }

  Widget _buildStatePreviewDropdown() {
    return ShadTooltip(
      builder: (_) =>
          const Text('Preview UI states for testing and verification'),
      child: SizedBox(
        width: 130,
        child: ShadSelect<ViewMode>(
          initialValue: _viewMode,
          selectedOptionBuilder: (context, value) => Text(switch (value) {
            ViewMode.normal => 'State: Normal',
            ViewMode.loading => 'State: Loading',
            ViewMode.empty => 'State: Empty',
            ViewMode.error => 'State: Error',
          }, style: const TextStyle(fontSize: 12)),
          onChanged: (mode) {
            if (mode != null) setState(() => _viewMode = mode);
          },
          options: const [
            ShadOption<ViewMode>(
              value: ViewMode.normal,
              child: Text('Normal State'),
            ),
            ShadOption<ViewMode>(
              value: ViewMode.loading,
              child: Text('Loading State'),
            ),
            ShadOption<ViewMode>(
              value: ViewMode.empty,
              child: Text('Empty State'),
            ),
            ShadOption<ViewMode>(
              value: ViewMode.error,
              child: Text('Error State'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCard(
    BuildContext context, {
    required int totalFiltered,
    required int totalPages,
    required List<Vehicle> pageVehicles,
    required ShadColorScheme colorScheme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMainContent(
              totalFiltered: totalFiltered,
              pageVehicles: pageVehicles,
            ),
            if (_viewMode == ViewMode.normal && totalFiltered > 0)
              VehiclePaginationBar(
                currentPage: _currentPage,
                totalPages: totalPages,
                totalItems: totalFiltered,
                pageSize: _pageSize,
                onPageChanged: (page) => setState(() => _currentPage = page),
                onPageSizeChanged: (size) => setState(() {
                  _pageSize = size;
                  _currentPage = 0;
                }),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent({
    required int totalFiltered,
    required List<Vehicle> pageVehicles,
  }) {
    switch (_viewMode) {
      case ViewMode.loading:
        return const VehicleLoadingState();
      case ViewMode.empty:
        return VehicleEmptyState(onAddVehicle: _handleAddVehiclePlaceholder);
      case ViewMode.error:
        return VehicleErrorState(
          onRetry: () => setState(() => _viewMode = ViewMode.normal),
        );
      case ViewMode.normal:
        if (totalFiltered == 0) {
          if (_hasActiveFilters) {
            return VehicleNoResultsState(onResetFilters: _resetFilters);
          }
          return VehicleEmptyState(onAddVehicle: _handleAddVehiclePlaceholder);
        }
        return VehicleTable(
          vehicles: pageVehicles,
          onActionTap: _handleActionPlaceholder,
        );
    }
  }
}
