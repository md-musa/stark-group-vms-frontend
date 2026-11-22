import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/vehicles/models/create_vehicle_request.dart';
import 'package:frontend/features/vehicles/models/update_vehicle_request.dart';
import 'package:frontend/features/vehicles/models/vehicle.dart';
import 'package:frontend/features/vehicles/models/vehicle_enums.dart';
import 'package:frontend/features/vehicles/providers/vehicle_providers.dart';
import 'package:frontend/features/vehicles/repositories/vehicle_repository.dart';

class VehicleForm extends ConsumerStatefulWidget {
  final Vehicle? initialVehicle;
  final VoidCallback? onCancel;
  final void Function(Vehicle vehicle)? onSuccess;
  final bool isDialog;

  const VehicleForm({
    super.key,
    this.initialVehicle,
    this.onCancel,
    this.onSuccess,
    this.isDialog = false,
  });

  bool get isEditing => initialVehicle != null;

  @override
  ConsumerState<VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends ConsumerState<VehicleForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _vehicleNumberController;
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _colorController;
  late final TextEditingController _seatingController;
  late final TextEditingController _driverNameController;
  late final TextEditingController _driverPhoneController;

  VehicleType? _selectedType;
  FuelType? _selectedFuel;

  bool _isSubmitting = false;
  String? _globalError;

  String? _vehicleNumberError;
  String? _typeError;
  String? _brandError;
  String? _modelError;
  String? _fuelError;
  String? _yearError;
  String? _seatingError;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    final v = widget.initialVehicle;
    _vehicleNumberController = TextEditingController(
      text: v?.vehicleNumber ?? '',
    );
    _brandController = TextEditingController(text: v?.brand ?? '');
    _modelController = TextEditingController(text: v?.model ?? '');
    _yearController = TextEditingController(
      text: v?.manufacturingYear != null ? '${v!.manufacturingYear}' : '',
    );
    _colorController = TextEditingController(text: v?.color ?? '');
    _seatingController = TextEditingController(
      text: v?.seatingCapacity != null ? '${v!.seatingCapacity}' : '',
    );
    _driverNameController = TextEditingController(text: v?.driverName ?? '');
    _driverPhoneController = TextEditingController(text: v?.driverPhone ?? '');
    _selectedType = v?.vehicleType;
    _selectedFuel = v?.fuelType;
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _seatingController.dispose();
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    bool isValid = true;

    setState(() {
      _globalError = null;
      _vehicleNumberError = null;
      _typeError = null;
      _brandError = null;
      _modelError = null;
      _fuelError = null;
      _yearError = null;
      _seatingError = null;
      _phoneError = null;

      final vehicleNumber = _vehicleNumberController.text.trim();
      if (vehicleNumber.isEmpty) {
        _vehicleNumberError = 'Vehicle number is required';
        isValid = false;
      } else if (vehicleNumber.length > 50) {
        _vehicleNumberError = 'Vehicle number must not exceed 50 characters';
        isValid = false;
      }

      if (_selectedType == null) {
        _typeError = 'Please select a vehicle type';
        isValid = false;
      }

      final brand = _brandController.text.trim();
      if (brand.isEmpty) {
        _brandError = 'Brand is required';
        isValid = false;
      } else if (brand.length > 100) {
        _brandError = 'Brand must not exceed 100 characters';
        isValid = false;
      }

      final model = _modelController.text.trim();
      if (model.isEmpty) {
        _modelError = 'Model is required';
        isValid = false;
      } else if (model.length > 100) {
        _modelError = 'Model must not exceed 100 characters';
        isValid = false;
      }

      if (_selectedFuel == null) {
        _fuelError = 'Please select a fuel type';
        isValid = false;
      }

      final yearText = _yearController.text.trim();
      if (yearText.isNotEmpty) {
        final year = int.tryParse(yearText);
        if (year == null || year < 1900 || year > 2100) {
          _yearError = 'Year must be between 1900 and 2100';
          isValid = false;
        }
      }

      final seatingText = _seatingController.text.trim();
      if (seatingText.isNotEmpty) {
        final seating = int.tryParse(seatingText);
        if (seating == null || seating <= 0) {
          _seatingError = 'Seating capacity must be a positive number';
          isValid = false;
        }
      }

      final phone = _driverPhoneController.text.trim();
      if (phone.isNotEmpty) {
        if (phone.length > 20) {
          _phoneError = 'Phone number must not exceed 20 characters';
          isValid = false;
        } else if (!RegExp(r'^[0-9+\-() ]*$').hasMatch(phone)) {
          _phoneError = 'Phone contains invalid characters';
          isValid = false;
        }
      }
    });

    return isValid;
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    if (!_validateForm()) return;

    setState(() {
      _isSubmitting = true;
      _globalError = null;
    });

    final yearText = _yearController.text.trim();
    final seatingText = _seatingController.text.trim();
    final repository = ref.read(vehicleRepositoryProvider);

    try {
      Vehicle result;

      if (widget.isEditing) {
        final request = UpdateVehicleRequest(
          vehicleNumber: _vehicleNumberController.text.trim(),
          vehicleType: _selectedType!,
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          manufacturingYear: yearText.isNotEmpty
              ? int.tryParse(yearText)
              : null,
          color: _colorController.text.trim().isNotEmpty
              ? _colorController.text.trim()
              : null,
          fuelType: _selectedFuel!,
          seatingCapacity: seatingText.isNotEmpty
              ? int.tryParse(seatingText)
              : null,
          driverName: _driverNameController.text.trim().isNotEmpty
              ? _driverNameController.text.trim()
              : null,
          driverPhone: _driverPhoneController.text.trim().isNotEmpty
              ? _driverPhoneController.text.trim()
              : null,
        );

        result = await repository.updateVehicle(
          widget.initialVehicle!.id,
          request,
        );

        ref.invalidate(vehicleListProvider);

        if (mounted) {
          ShadToaster.of(context).show(
            ShadToast(
              title: const Text('Vehicle Updated'),
              description: Text(
                '${result.brand} ${result.model} (${result.vehicleNumber}) updated successfully.',
              ),
            ),
          );
          widget.onSuccess?.call(result);
        }
      } else {
        final request = CreateVehicleRequest(
          vehicleNumber: _vehicleNumberController.text.trim(),
          vehicleType: _selectedType!,
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          manufacturingYear: yearText.isNotEmpty
              ? int.tryParse(yearText)
              : null,
          color: _colorController.text.trim().isNotEmpty
              ? _colorController.text.trim()
              : null,
          fuelType: _selectedFuel!,
          seatingCapacity: seatingText.isNotEmpty
              ? int.tryParse(seatingText)
              : null,
          driverName: _driverNameController.text.trim().isNotEmpty
              ? _driverNameController.text.trim()
              : null,
          driverPhone: _driverPhoneController.text.trim().isNotEmpty
              ? _driverPhoneController.text.trim()
              : null,
        );

        result = await repository.createVehicle(request);

        ref.invalidate(vehicleListProvider);

        if (mounted) {
          ShadToaster.of(context).show(
            ShadToast(
              title: const Text('Vehicle Registered'),
              description: Text(
                '${result.brand} ${result.model} (${result.vehicleNumber}) added successfully.',
              ),
            ),
          );
          widget.onSuccess?.call(result);
        }
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;

        if (e.statusCode == 409) {
          final number = _vehicleNumberController.text.trim();
          _vehicleNumberError =
              'A vehicle with number "$number" already exists.';
          _globalError = 'Conflict: A vehicle with this vehicle number is already registered in the system.';
        } else if (e.fieldErrors != null && e.fieldErrors!.isNotEmpty) {
          _vehicleNumberError = e.fieldErrors!['vehicleNumber'];
          _typeError = e.fieldErrors!['vehicleType'];
          _brandError = e.fieldErrors!['brand'];
          _modelError = e.fieldErrors!['model'];
          _fuelError = e.fieldErrors!['fuelType'];
          _yearError = e.fieldErrors!['manufacturingYear'];
          _seatingError = e.fieldErrors!['seatingCapacity'];
          _phoneError = e.fieldErrors!['driverPhone'];
          _globalError = e.message;
        } else {
          _globalError = e.message;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _globalError = 'An unexpected error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ShadTheme.of(context).colorScheme;
    final breakpoint = context.breakpoint;
    final isDesktop = !widget.isDialog && breakpoint >= ShadBreakpointLG(1024);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_globalError != null) ...[
            _buildGlobalError(),
            const SizedBox(height: 16),
          ],
          _buildSectionTitle('Vehicle Specifications'),
          const SizedBox(height: 16),
          _buildTwoColumnRow(
            isDesktop: isDesktop,
            first: _buildInputItem(
              label: 'Vehicle Number',
              isRequired: true,
              errorText: _vehicleNumberError,
              child: ShadInput(
                controller: _vehicleNumberController,
                placeholder: const Text('e.g. DM-GA-11-2041'),
                onChanged: (_) {
                  if (_vehicleNumberError != null) {
                    setState(() => _vehicleNumberError = null);
                  }
                },
              ),
            ),
            second: _buildInputItem(
              label: 'Vehicle Type',
              isRequired: true,
              errorText: _typeError,
              child: ShadSelect<VehicleType>(
                placeholder: const Text('Select vehicle type'),
                initialValue: _selectedType,
                selectedOptionBuilder: (context, value) => Text(value.label),
                onChanged: (val) => setState(() {
                  _selectedType = val;
                  _typeError = null;
                }),
                options: VehicleType.values
                    .map(
                      (type) => ShadOption<VehicleType>(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildTwoColumnRow(
            isDesktop: isDesktop,
            first: _buildInputItem(
              label: 'Brand',
              isRequired: true,
              errorText: _brandError,
              child: ShadInput(
                controller: _brandController,
                placeholder: const Text('e.g. Toyota, Mitsubishi'),
                onChanged: (_) {
                  if (_brandError != null) {
                    setState(() => _brandError = null);
                  }
                },
              ),
            ),
            second: _buildInputItem(
              label: 'Model',
              isRequired: true,
              errorText: _modelError,
              child: ShadInput(
                controller: _modelController,
                placeholder: const Text('e.g. Corolla, Pajero Sport'),
                onChanged: (_) {
                  if (_modelError != null) {
                    setState(() => _modelError = null);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildTwoColumnRow(
            isDesktop: isDesktop,
            first: _buildInputItem(
              label: 'Manufacturing Year',
              errorText: _yearError,
              child: ShadInput(
                controller: _yearController,
                placeholder: const Text('e.g. 2022 (1900 - 2100)'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                onChanged: (_) {
                  if (_yearError != null) {
                    setState(() => _yearError = null);
                  }
                },
              ),
            ),
            second: _buildInputItem(
              label: 'Color',
              child: ShadInput(
                controller: _colorController,
                placeholder: const Text('e.g. Pearl White, Silver'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildTwoColumnRow(
            isDesktop: isDesktop,
            first: _buildInputItem(
              label: 'Fuel Type',
              isRequired: true,
              errorText: _fuelError,
              child: ShadSelect<FuelType>(
                placeholder: const Text('Select fuel type'),
                initialValue: _selectedFuel,
                selectedOptionBuilder: (context, value) => Text(value.label),
                onChanged: (val) => setState(() {
                  _selectedFuel = val;
                  _fuelError = null;
                }),
                options: FuelType.values
                    .map(
                      (fuel) => ShadOption<FuelType>(
                        value: fuel,
                        child: Text(fuel.label),
                      ),
                    )
                    .toList(),
              ),
            ),
            second: _buildInputItem(
              label: 'Seating Capacity',
              errorText: _seatingError,
              child: ShadInput(
                controller: _seatingController,
                placeholder: const Text('e.g. 5'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                onChanged: (_) {
                  if (_seatingError != null) {
                    setState(() => _seatingError = null);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 28),
          _buildSectionTitle('Driver Assignment (Optional)'),
          const SizedBox(height: 16),
          _buildTwoColumnRow(
            isDesktop: isDesktop,
            first: _buildInputItem(
              label: 'Driver Name',
              child: ShadInput(
                controller: _driverNameController,
                placeholder: const Text('e.g. Rafiqul Islam'),
              ),
            ),
            second: _buildInputItem(
              label: 'Driver Phone',
              errorText: _phoneError,
              child: ShadInput(
                controller: _driverPhoneController,
                placeholder: const Text('e.g. +880 1712-345678'),
                keyboardType: TextInputType.phone,
                onChanged: (_) {
                  if (_phoneError != null) {
                    setState(() => _phoneError = null);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 28),
          _buildBottomActionBar(colorScheme),
        ],
      ),
    );
  }

  Widget _buildGlobalError() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            LucideIcons.triangleAlert,
            size: 18,
            color: Color(0xFFDC2626),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _globalError!,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFB91C1C),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final colorScheme = ShadTheme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: colorScheme.foreground,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        Container(height: 1, color: colorScheme.border.withAlpha(120)),
      ],
    );
  }

  Widget _buildTwoColumnRow({
    required bool isDesktop,
    required Widget first,
    required Widget second,
  }) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: first),
          const SizedBox(width: 16),
          Expanded(child: second),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [first, const SizedBox(height: 16), second],
    );
  }

  Widget _buildInputItem({
    required String label,
    required Widget child,
    bool isRequired = false,
    String? errorText,
  }) {
    final colorScheme = ShadTheme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.foreground,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFDC2626),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        child,
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                LucideIcons.circleAlert,
                size: 12,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  errorText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBottomActionBar(ShadColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ShadButton.outline(
          enabled: !_isSubmitting,
          onPressed: widget.onCancel,
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        ShadButton(
          enabled: !_isSubmitting,
          onPressed: _handleSubmit,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isSubmitting) ...[
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(widget.isEditing ? 'Updating...' : 'Saving...'),
              ] else ...[
                const Icon(LucideIcons.check, size: 16),
                const SizedBox(width: 6),
                Text(widget.isEditing ? 'Save Changes' : 'Save Vehicle'),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
