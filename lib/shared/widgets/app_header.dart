import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const AppHeader({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ShadTheme.of(context).colorScheme;
    final routerState = GoRouterState.of(context);
    final pageTitle = _pageTitleFromLocation(routerState.uri.toString());

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.card,
        border: Border(bottom: BorderSide(color: colorScheme.border)),
      ),
      child: Row(
        children: [
          if (onMenuTap != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ShadButton.ghost(
                onPressed: onMenuTap,
                size: ShadButtonSize.sm,
                child: const Icon(LucideIcons.menu, size: 18),
              ),
            ),
          Text(
            pageTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.foreground,
              letterSpacing: -0.2,
            ),
          ),
          const Spacer(),
          ShadTooltip(
            builder: (_) => const Text('Account'),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'FL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.foreground,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _pageTitleFromLocation(String location) {
    if (location.contains('/vehicles/') && location.endsWith('/edit')) {
      return 'Edit Vehicle';
    }
    if (location.startsWith('/vehicles/new')) return 'Add Vehicle';
    if (location.startsWith('/vehicles')) return 'Vehicles';
    if (location.startsWith('/settings')) return 'Settings';
    return 'Fleetora';
  }
}
