import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../branding/theme/brand_theme.dart';
import '../../../../shared/theme/spacing.dart';
import '../models/task.dart';
import '../viewmodel/planner_viewmodel.dart';
import 'widgets/add_edit_task_bottom_sheet.dart';
import 'widgets/task_card.dart';

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolled = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) {
        ref.read(plannerViewModelProvider.notifier).checkMidnight();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentHour() {
    if (_hasScrolled) return;
    final currentHour = DateTime.now().hour;
    // Account for Next section height roughly
    final tasks = ref.read(plannerViewModelProvider);
    final untimedCount = tasks.where((t) => t.time == null).length;
    final nextSectionHeight = untimedCount > 0 ? (untimedCount * 100.0 + 50.0) : 0.0;
    
    final targetOffset = (currentHour * 80.0) + nextSectionHeight;
    
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
      _hasScrolled = true;
    }
  }

  void _showAddEditSheet([Task? task]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: AddEditTaskBottomSheet(task: task),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brandTheme = theme.extension<BrandThemeExtension>()!;
    final tasks = ref.watch(plannerViewModelProvider);
    final nextTaskId = ref.watch(nextTaskProvider);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentHour();
    });

    final now = DateTime.now();
    
    final pastTasks = tasks.where((t) {
      if (t.isCompleted) return true;
      if (t.time != null && t.time!.isBefore(now)) return true;
      return false;
    }).toList();

    final activeTasks = tasks.where((t) => !pastTasks.contains(t)).toList();
    final untimedTasks = activeTasks.where((t) => t.time == null).toList();
    final timedTasks = activeTasks.where((t) => t.time != null).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(SharedSpacing.md),
              child: Text(
                'Today',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            if (tasks.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task_alt, size: 64, color: brandTheme.borderColor),
                      const SizedBox(height: SharedSpacing.md),
                      Text(
                        'No tasks today',
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontSize: 24,
                          color: brandTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: SharedSpacing.sm),
                      Text(
                        'Tap + to add your first task',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: brandTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    if (pastTasks.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: SharedSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Past',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: brandTheme.textMuted,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: SharedSpacing.xs),
                              SizedBox(
                                height: 80, // Increased for taller compact cards
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: pastTasks.length,
                                  itemBuilder: (context, index) {
                                    final t = pastTasks[index];
                                    return TaskCard(
                                      task: t,
                                      isCompact: true,
                                      onTap: () => _showAddEditSheet(t),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: SharedSpacing.md),
                            ],
                          ),
                        ),
                      ),
                      
                    if (untimedTasks.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: SharedSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Next',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: brandTheme.textMuted,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: SharedSpacing.xs),
                              ...untimedTasks.map((t) => TaskCard(
                                    task: t,
                                    isNextTask: t.id == nextTaskId,
                                    onComplete: () => ref.read(plannerViewModelProvider.notifier).completeTask(t.id),
                                    onTap: () => _showAddEditSheet(t),
                                  )),
                              const SizedBox(height: SharedSpacing.lg),
                            ],
                          ),
                        ),
                      ),
                      
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final hour = index;
                          final hourTasks = timedTasks.where((t) => t.time!.hour == hour).toList();
                          final now = DateTime.now();
                          final isCurrentHour = now.hour == hour;
                          final isPastHour = hour < now.hour;

                          return Opacity(
                            opacity: isPastHour ? 0.4 : 1.0,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: SharedSpacing.md),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 65, // Slightly wider for bigger typography
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _formatHour(hour),
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: isCurrentHour ? brandTheme.primaryColor : brandTheme.textMuted.withAlpha(150),
                                            fontWeight: isCurrentHour ? FontWeight.bold : FontWeight.normal,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        constraints: const BoxConstraints(minHeight: 100), // Better breathing room
                                        decoration: BoxDecoration(
                                          color: hour.isEven ? brandTheme.cardBackground.withAlpha(15) : Colors.transparent, // Alternating subtle shade
                                          border: Border(
                                            top: BorderSide(
                                              color: brandTheme.borderColor.withAlpha(60), // Lighter separator
                                              width: 0.5,
                                            ),
                                          ),
                                        ),
                                        padding: const EdgeInsets.only(bottom: SharedSpacing.lg, top: SharedSpacing.md),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            if (hourTasks.isEmpty)
                                              const SizedBox(height: 30) // Taller empty gap internally matching standard vertical row rhythm
                                            else
                                              ...hourTasks.map((t) => TaskCard(
                                                    task: t,
                                                    isNextTask: t.id == nextTaskId,
                                                    onComplete: () => ref.read(plannerViewModelProvider.notifier).completeTask(t.id),
                                                    onTap: () => _showAddEditSheet(t),
                                                  )),
                                          ],
                                        ),
                                      ),
                                      if (isCurrentHour)
                                        Positioned(
                                          top: ((now.minute / 60) * 100.0) - 8, // Shift up half-height to center over the exact offset
                                          left: -12, // Align directly over dot origin
                                          right: 0,
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  color: brandTheme.primaryColor,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: brandTheme.primaryColor.withAlpha(100),
                                                      blurRadius: 6,
                                                      spreadRadius: 2,
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  height: 1.5,
                                                  decoration: BoxDecoration(
                                                    color: brandTheme.primaryColor.withAlpha(200),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: brandTheme.primaryColor.withAlpha(100),
                                                        blurRadius: 4,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                DateFormat('h:mm a').format(now),
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: brandTheme.primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                           ),
                          );
                        },
                        childCount: 24,
                      ),
                    ),
                    const SliverPadding(padding: EdgeInsets.only(bottom: 120)), // Further offset layout padding for large scolls to avoid squircle FAB
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEditSheet,
        backgroundColor: brandTheme.primaryColor.withAlpha(220),
        foregroundColor: Colors.white,
        elevation: 3, // slightly stepped shadow for integration
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }
}
