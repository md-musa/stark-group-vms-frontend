import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppSidebar extends StatelessWidget {
  final bool collapsed;
  final VoidCallback? onToggle;

  const AppSidebar({super.key, required this.collapsed, this.onToggle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ShadTheme.of(context).colorScheme;
    final currentLocation = GoRouterState.of(context).uri.toString();
    final sidebarWidth = collapsed ? 64.0 : 240.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: sidebarWidth,
      decoration: BoxDecoration(
        color: colorScheme.card,
        border: Border(right: BorderSide(color: colorScheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SidebarBranding(collapsed: collapsed),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              children: [
                _NavItem(
                  icon: LucideIcons.car,
                  label: 'Vehicles',
                  path: '/vehicles',
                  collapsed: collapsed,
                  isActive: currentLocation.startsWith('/vehicles'),
                ),
                _NavItem(
                  icon: LucideIcons.settings,
                  label: 'Settings',
                  path: '/settings',
                  collapsed: collapsed,
                  isActive: currentLocation.startsWith('/settings'),
                ),
              ],
            ),
          ),
          if (onToggle != null)
            _CollapseButton(collapsed: collapsed, onToggle: onToggle!),
        ],
      ),
    );
  }
}

class _SidebarBranding extends StatelessWidget {
  final bool collapsed;

  const _SidebarBranding({required this.collapsed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ShadTheme.of(context).colorScheme;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(LucideIcons.truck, size: 18, color: Colors.white),
            ),
          ),
          if (!collapsed) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fleetora',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.foreground,
                      letterSpacing: -0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Vehicle Management',
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.mutedForeground,
                      letterSpacing: 0.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;
  final bool collapsed;
  final bool isActive;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.collapsed,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = ShadTheme.of(context).colorScheme;

    final bgColor = isActive ? colorScheme.accent : Colors.transparent;
    final fgColor = isActive
        ? colorScheme.accentForeground
        : colorScheme.mutedForeground;
    final iconColor = isActive
        ? colorScheme.foreground
        : colorScheme.mutedForeground;

    final item = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () {
            if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
              Navigator.of(context).pop();
            }
            context.go(path);
          },
          hoverColor: colorScheme.accent.withAlpha(128),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 0 : 10,
              vertical: 9,
            ),
            child: collapsed
                ? Center(child: Icon(icon, size: 18, color: iconColor))
                : Row(
                    children: [
                      Icon(icon, size: 18, color: iconColor),
                      const SizedBox(width: 10),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: fgColor,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );

    if (collapsed) {
      return ShadTooltip(builder: (_) => Text(label), child: item);
    }

    return item;
  }
}

class _CollapseButton extends StatelessWidget {
  final bool collapsed;
  final VoidCallback onToggle;

  const _CollapseButton({required this.collapsed, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ShadTheme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colorScheme.border)),
      ),
      child: ShadTooltip(
        builder: (_) => Text(collapsed ? 'Expand sidebar' : 'Collapse sidebar'),
        child: ShadButton.ghost(
          onPressed: onToggle,
          size: ShadButtonSize.sm,
          child: Row(
            mainAxisAlignment: collapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                collapsed
                    ? LucideIcons.panelLeftOpen
                    : LucideIcons.panelLeftClose,
                size: 16,
              ),
              if (!collapsed) ...[
                const SizedBox(width: 8),
                const Text('Collapse', style: TextStyle(fontSize: 13)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
