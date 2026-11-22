import 'package:material_ui/material_ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppTheme {
  AppTheme._();

  static ShadThemeData get light => ShadThemeData(
    colorScheme: const ShadZincColorScheme.light(),
    brightness: Brightness.light,
    radius: const BorderRadius.all(Radius.circular(8)),
  );
}
