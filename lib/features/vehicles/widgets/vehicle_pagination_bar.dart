import 'package:material_ui/material_ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class VehiclePaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;

  const VehiclePaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    required this.onPageChanged,
    required this.onPageSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = ShadTheme.of(context).colorScheme;
    final startItem = totalItems == 0 ? 0 : (currentPage * pageSize) + 1;
    final endItem = ((currentPage + 1) * pageSize).clamp(0, totalItems);

    final canGoPrev = currentPage > 0;
    final canGoNext = currentPage < totalPages - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.card,
        border: Border(top: BorderSide(color: colorScheme.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'Showing $startItem-$endItem of $totalItems vehicles',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.mutedForeground,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Rows per page:',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.mutedForeground,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 72,
                    child: ShadSelect<int>(
                      initialValue: pageSize,
                      selectedOptionBuilder: (context, value) =>
                          Text('$value', style: const TextStyle(fontSize: 12)),
                      onChanged: (val) {
                        if (val != null) onPageSizeChanged(val);
                      },
                      options: const [
                        ShadOption<int>(value: 5, child: Text('5')),
                        ShadOption<int>(value: 10, child: Text('10')),
                        ShadOption<int>(value: 20, child: Text('20')),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'Page ${totalItems == 0 ? 0 : currentPage + 1} of ${totalPages == 0 ? 1 : totalPages}',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.mutedForeground,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              ShadButton.outline(
                size: ShadButtonSize.sm,
                enabled: canGoPrev,
                onPressed: canGoPrev
                    ? () => onPageChanged(currentPage - 1)
                    : null,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.chevronLeft, size: 14),
                    SizedBox(width: 4),
                    Text('Previous'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ShadButton.outline(
                size: ShadButtonSize.sm,
                enabled: canGoNext,
                onPressed: canGoNext
                    ? () => onPageChanged(currentPage + 1)
                    : null,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Next'),
                    SizedBox(width: 4),
                    Icon(LucideIcons.chevronRight, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
