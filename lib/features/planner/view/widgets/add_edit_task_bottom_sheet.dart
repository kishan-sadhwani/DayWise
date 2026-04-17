import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../branding/theme/brand_theme.dart';
import '../../../../shared/theme/spacing.dart';
import '../../models/task.dart';
import '../../viewmodel/planner_viewmodel.dart';

class AddEditTaskBottomSheet extends ConsumerStatefulWidget {
  final Task? task;

  const AddEditTaskBottomSheet({super.key, this.task});

  @override
  ConsumerState<AddEditTaskBottomSheet> createState() => _AddEditTaskBottomSheetState();
}

class _AddEditTaskBottomSheetState extends ConsumerState<AddEditTaskBottomSheet> {
  late TextEditingController _titleController;
  DateTime? _selectedTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _selectedTime = widget.task?.time;
    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _pickTime() {
    // We use a minimal bottom sheet with CupertinoDatePicker
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Done'),
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: _selectedTime ?? DateTime.now(),
                onDateTimeChanged: (time) {
                  setState(() => _selectedTime = time);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    if (widget.task == null) {
      ref.read(plannerViewModelProvider.notifier).addTask(title, _selectedTime);
    } else {
      ref.read(plannerViewModelProvider.notifier).updateTask(
        widget.task!.copyWith(title: title, time: _selectedTime),
      );
    }
    Navigator.pop(context);
  }

  void _deleteTask() {
    if (widget.task != null) {
      ref.read(plannerViewModelProvider.notifier).deleteTask(widget.task!.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brandTheme = theme.extension<BrandThemeExtension>()!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final isEdit = widget.task != null;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset + SharedSpacing.md, left: SharedSpacing.lg, right: SharedSpacing.lg, top: SharedSpacing.lg),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'What needs to be done?',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(color: brandTheme.textMuted),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: SharedSpacing.md),
            Row(
              children: [
                GestureDetector(
                  onTap: _pickTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: brandTheme.cardBackground,
                      borderRadius: BorderRadius.circular(SharedSpacing.radius),
                      border: Border.all(color: brandTheme.borderColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, size: 18, color: brandTheme.textMuted),
                        const SizedBox(width: 8),
                        Text(
                          _selectedTime != null ? DateFormat.jm().format(_selectedTime!) : 'Any Time',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_selectedTime != null)
                  IconButton(
                    icon: Icon(Icons.close, size: 18, color: brandTheme.textMuted),
                    onPressed: () => setState(() => _selectedTime = null),
                  ),
                const Spacer(),
                if (isEdit)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: _deleteTask,
                  ),
                ElevatedButton(
                  onPressed: _titleController.text.trim().isEmpty ? null : _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: SharedSpacing.xl, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SharedSpacing.radius)),
                    elevation: 0,
                  ),
                  child: Text(
                    isEdit ? 'Update Task' : 'Add Task',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SharedSpacing.lg),
          ],
        ),
      ),
    );
  }
}
