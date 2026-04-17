import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../branding/theme/brand_theme.dart';
import '../../../../shared/theme/spacing.dart';
import '../../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool isNextTask;
  final bool isCompact;
  final VoidCallback? onComplete;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.isNextTask = false,
    this.isCompact = false,
    this.onComplete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brandTheme = theme.extension<BrandThemeExtension>()!;

    return isCompact ? _buildCompactContent(theme, brandTheme) : Dismissible(
      key: Key(task.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => onComplete?.call(),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: SharedSpacing.xs),
        decoration: BoxDecoration(
          color: Colors.green.shade400,
          borderRadius: BorderRadius.circular(SharedSpacing.radius),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: SharedSpacing.lg),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: isNextTask ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: SharedSpacing.sm),
            padding: const EdgeInsets.symmetric(horizontal: SharedSpacing.lg, vertical: SharedSpacing.md),
            constraints: const BoxConstraints(minHeight: 72),
            decoration: BoxDecoration(
              color: isNextTask ? brandTheme.primaryColor.withAlpha(6) : brandTheme.cardBackground,
              borderRadius: BorderRadius.circular(SharedSpacing.radius),
              border: Border.all(
                color: isNextTask ? brandTheme.primaryColor.withAlpha(120) : brandTheme.borderColor,
                width: isNextTask ? 1.0 : 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isNextTask ? 12 : 6),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: isNextTask ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                      if (task.time != null) ...[
                        const SizedBox(height: SharedSpacing.xs),
                        Text(
                          DateFormat.jm().format(task.time!),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: brandTheme.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isNextTask)
                  Icon(
                    Icons.star,
                    color: brandTheme.primaryColor,
                    size: 14,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactContent(ThemeData theme, BrandThemeExtension brandTheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: SharedSpacing.xs).copyWith(right: SharedSpacing.md),
      padding: const EdgeInsets.symmetric(horizontal: SharedSpacing.lg, vertical: SharedSpacing.md),
      constraints: const BoxConstraints(minHeight: 64),
      decoration: BoxDecoration(
        color: brandTheme.cardBackground.withAlpha(180),
        borderRadius: BorderRadius.circular(SharedSpacing.radius),
        border: Border.all(
          color: brandTheme.borderColor,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            task.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted ? brandTheme.textMuted : theme.textTheme.bodyMedium?.color,
            ),
          ),
          if (task.time != null)
            Text(
              DateFormat.jm().format(task.time!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: brandTheme.textMuted,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }
}
