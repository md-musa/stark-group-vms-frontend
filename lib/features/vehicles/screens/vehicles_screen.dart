import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:frontend/features/vehicles/models/vehicle.dart';
import 'package:frontend/features/vehicles/models/vehicle_enums.dart';
import 'package:frontend/features/vehicles/models/vehicle_query_params.dart';
import 'package:frontend/features/vehicles/providers/vehicle_providers.dart';
import 'package:frontend/features/vehicles/widgets/delete_vehicle_dialog.dart';
import 'package:frontend/features/vehicles/widgets/vehicle_filters_bar.dart';
import 'package:frontend/features/vehicles/widgets/vehicle_form.dart';
import 'package:frontend/features/vehicles/widgets/vehicle_pagination_bar.dart';
import 'package:frontend/features/vehicles/widgets/vehicle_state_views.dart';
import 'package:frontend/features/vehicles/widgets/vehicle_table.dart';

class VehiclesScreen extends ConsumerStatefulWidget {
  const VehiclesScreen({super.key});

  @override
  ConsumerState<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends ConsumerState<VehiclesScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    final initialSearch = ref.read(vehicleQueryParamsProvider).search;
    if (initialSearch != null && initialSearch.isNotEmpty) {
      _searchController.text = initialSearch;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      final current = ref.read(vehicleQueryParamsProvider);
      ref.read(vehicleQueryParamsProvider.notifier).state = current.copyWith(
        search: value.trim().isEmpty ? null : value.trim(),
        page: 0,
      );
    });
  }

  void _onClearSearch() {
    _debounceTimer?.cancel();
    _searchController.clear();
    final current = ref.read(vehicleQueryParamsProvider);
    ref.read(vehicleQueryParamsProvider.notifier).state = current.copyWith(
      search: null,
      page: 0,
    );
  }

  void _onTypeChanged(VehicleType? type) {
    final current = ref.read(vehicleQueryParamsProvider);
    ref.read(vehicleQueryParamsProvider.notifier).state = current.copyWith(
      vehicleType: () => type,
      page: 0,
    );
  }

  void _onFuelChanged(FuelType? fuel) {
    final current = ref.read(vehicleQueryParamsProvider);
    ref.read(vehicleQueryParamsProvider.notifier).state = current.copyWith(
      fuelType: () => fuel,
      page: 0,
    );
  }

  void _onStatusChanged(VehicleStatus? status) {
    final current = ref.read(vehicleQueryParamsProvider);
    ref.read(vehicleQueryParamsProvider.notifier).state = current.copyWith(
      status: () => status,
      page: 0,
    );
  }

  void _onResetAll() {
    _debounceTimer?.cancel();
    _searchController.clear();
    ref.read(vehicleQueryParamsProvider.notifier).state =
        const VehicleQueryParams();
  }

  void _onPageChanged(int newPage) {
    final current = ref.read(vehicleQueryParamsProvider);
    ref.read(vehicleQueryParamsProvider.notifier).state = current.copyWith(
      page: newPage,
    );
  }

  void _onPageSizeChanged(int newSize) {
    final current = ref.read(vehicleQueryParamsProvider);
    ref.read(vehicleQueryParamsProvider.notifier).state = current.copyWith(
      size: newSize,
      page: 0,
    );
  }

  void _onSortChanged(String column, String direction) {
    final current = ref.read(vehicleQueryParamsProvider);
    ref.read(vehicleQueryParamsProvider.notifier).state = current.copyWith(
      sortBy: column,
      direction: direction,
      page: 0,
    );
  }

  void _navigateToAddVehicle() {
    context.go('/vehicles/new');
  }

  void _handleEditVehicle(Vehicle vehicle) {
    showShadDialog(
      context: context,
      builder: (dialogContext) {
        return ShadDialog(
          title: Text('Edit Vehicle (${vehicle.vehicleNumber})'),
          description: const Text(
            'Update vehicle specifications and driver assignment.',
          ),
          constraints: const BoxConstraints(maxWidth: 680),
          child: VehicleForm(
            initialVehicle: vehicle,
            isDialog: true,
            onCancel: () => Navigator.of(dialogContext).pop(),
            onSuccess: (_) {
              Navigator.of(dialogContext).pop();
            },
          ),
        );
      },
    );
  }

  Future<void> _handleDeleteVehicle(
    Vehicle vehicle,
    int currentPageItemsCount,
  ) async {
    final deleted = await showShadDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return DeleteVehicleDialog(vehicle: vehicle);
      },
    );

    if (deleted == true && mounted) {
      final params = ref.read(vehicleQueryParamsProvider);
      if (currentPageItemsCount == 1 && params.page > 0) {
        ref.read(vehicleQueryParamsProvider.notifier).state = params.copyWith(
          page: params.page - 1,
        );
      } else {
        ref.invalidate(vehicleListProvider);
      }
    }
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

    final params = ref.watch(vehicleQueryParamsProvider);
    final vehicleListAsync = ref.watch(vehicleListProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 28 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, isDesktop),
          const SizedBox(height: 20),
          VehicleFiltersBar(
            searchController: _searchController,
            onSearchChanged: _onSearchChanged,
            onClearSearch: _onClearSearch,
            selectedType: params.vehicleType,
            onTypeChanged: _onTypeChanged,
            selectedFuel: params.fuelType,
            onFuelChanged: _onFuelChanged,
            selectedStatus: params.status,
            onStatusChanged: _onStatusChanged,
            onResetAll: _onResetAll,
            hasActiveFilters: params.hasActiveFilters,
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: vehicleListAsync.when(
                loading: () => const VehicleLoadingState(),
                error: (error, _) => VehicleErrorState(
                  message: error.toString(),
                  onRetry: () => ref.refresh(vehicleListProvider),
                ),
                data: (pageResponse) {
                  if (pageResponse.totalElements == 0) {
                    if (params.hasActiveFilters) {
                      return VehicleNoResultsState(onResetFilters: _onResetAll);
                    }
                    return VehicleEmptyState(
                      onAddVehicle: _navigateToAddVehicle,
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      VehicleTable(
                        vehicles: pageResponse.content,
                        sortBy: params.sortBy,
                        sortDirection: params.direction,
                        onSort: _onSortChanged,
                        onActionTap: _handleActionPlaceholder,
                        onEditTap: _handleEditVehicle,
                        onDeleteTap: (v) => _handleDeleteVehicle(
                          v,
                          pageResponse.content.length,
                        ),
                      ),
                      VehiclePaginationBar(
                        currentPage: pageResponse.page,
                        totalPages: pageResponse.totalPages,
                        totalItems: pageResponse.totalElements,
                        pageSize: pageResponse.size,
                        onPageChanged: _onPageChanged,
                        onPageSizeChanged: _onPageSizeChanged,
                      ),
                    ],
                  );
                },
              ),
            ),
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
        ShadButton.outline(
          size: ShadButtonSize.sm,
          onPressed: () => ref.refresh(vehicleListProvider),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.refreshCw, size: 14),
              SizedBox(width: 6),
              Text('Refresh'),
            ],
          ),
        ),
        const SizedBox(width: 10),
        ShadButton(
          size: ShadButtonSize.sm,
          onPressed: _navigateToAddVehicle,
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
}
