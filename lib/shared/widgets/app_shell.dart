import 'package:material_ui/material_ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:frontend/shared/widgets/app_sidebar.dart';
import 'package:frontend/shared/widgets/app_header.dart';

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _sidebarCollapsed = false;

  void _toggleSidebar() {
    setState(() => _sidebarCollapsed = !_sidebarCollapsed);
  }

  @override
  Widget build(BuildContext context) {
    final breakpoint = context.breakpoint;
    final isMobile = breakpoint < ShadBreakpointMD(768);
    final isTablet =
        breakpoint >= ShadBreakpointMD(768) &&
        breakpoint < ShadBreakpointLG(1024);

    final showDrawer = isMobile || isTablet;

    if (showDrawer) {
      return _MobileLayout(child: widget.child);
    }

    return _DesktopLayout(
      collapsed: _sidebarCollapsed,
      onToggle: _toggleSidebar,
      child: widget.child,
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final bool collapsed;
  final VoidCallback onToggle;
  final Widget child;

  const _DesktopLayout({
    required this.collapsed,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = ShadTheme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Row(
        children: [
          AppSidebar(collapsed: collapsed, onToggle: onToggle),
          Expanded(
            child: Column(
              children: [
                AppHeader(onMenuTap: onToggle),
                Expanded(
                  child: ColoredBox(
                    color: const Color(0xFFF9FAFB),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileLayout extends StatefulWidget {
  final Widget child;

  const _MobileLayout({required this.child});

  @override
  State<_MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<_MobileLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = ShadTheme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colorScheme.background,
      drawer: const Drawer(width: 240, child: AppSidebar(collapsed: false)),
      body: Column(
        children: [
          AppHeader(onMenuTap: () => _scaffoldKey.currentState?.openDrawer()),
          Expanded(
            child: ColoredBox(
              color: const Color(0xFFF9FAFB),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
