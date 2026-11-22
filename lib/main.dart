import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: FleetoraApp()));
}

class FleetoraApp extends StatelessWidget {
  const FleetoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.router(
      title: 'Fleetora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}

typedef StarkGroupVmsApp = FleetoraApp;
