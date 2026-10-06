import 'package:arpicoiam/iam.dart';
import 'package:flutter/material.dart';

import '../../services/database/db_columns.dart';
import '../../services/database/db_constants.dart';
import '../../services/database/repositories/task_db_repository.dart';
import '../../shared/components/app/app_scaffold.dart';

class TasksView extends StatefulWidget {
  const TasksView({super.key});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  final _taskCtrl = TextEditingController();
  final _taskFocus = FocusNode();
  final _mainScroll = ScrollController();

  List<Map<String, dynamic>> _tasks = [];
  String _selectedStatus = 'All';
  Map<String, int> _counts = {};

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _taskCtrl.dispose();
    _taskFocus.dispose();
    _mainScroll.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    try {
      final currentUser = await IAMService.instance.currentUser();

      final tasks = await TaskDbRepository.getAll(
        currentUser,
        status: _selectedStatus,
      );
      final counts = await TaskDbRepository.getStatusCounts(currentUser);

      if (mounted) {
        setState(() {
          _tasks = tasks;
          _counts = counts;
        });
      }
    } catch (e) {
      debugPrint('Load tasks error: $e');
    }
  }

  Future<void> _addTask() async {
    if (_taskCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task')),
      );
      return;
    }

    try {
      final currentUser = await IAMService.instance.currentUser();

      await TaskDbRepository.insert(
        currentUser,
        remark: _taskCtrl.text.trim(),
      );

      _taskCtrl.clear();
      await _loadTasks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task added')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      final currentUser = await IAMService.instance.currentUser();

      await TaskDbRepository.updateStatus(
        id: id,
        status: status,
        currentUser,
      );
      await _loadTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteTask(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await TaskDbRepository.delete(id);
        await _loadTasks();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case DBConstants.TASK_OPEN:
        return Colors.blue;
      case DBConstants.TASK_IN_PROGRESS:
        return Colors.orange;
      case DBConstants.TASK_CLOSED:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case DBConstants.TASK_OPEN:
        return Icons.radio_button_unchecked;
      case DBConstants.TASK_IN_PROGRESS:
        return Icons.hourglass_bottom;
      case DBConstants.TASK_CLOSED:
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppScaffold(
      title: 'Tasks',
      scrollController: _mainScroll,
      scrollableBody: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stats row
          Row(
            children: [
              Expanded(child: _buildStatChip('Open', _counts[DBConstants.TASK_OPEN] ?? 0, Colors.blue)),
              const SizedBox(width: 8),
              Expanded(child: _buildStatChip('In Progress', _counts[DBConstants.TASK_IN_PROGRESS] ?? 0, Colors.orange)),
              const SizedBox(width: 8),
              Expanded(child: _buildStatChip('Done', _counts[DBConstants.TASK_CLOSED] ?? 0, Colors.green)),
            ],
          ),
          const SizedBox(height: 16),

          // Add task section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add New Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cs.onSurface)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _taskCtrl,
                    focusNode: _taskFocus,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'What needs to be done?',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _addTask,
                      child: const Text('Add Task'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Filter
          Row(
            children: [
              Text('Filter: ', style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface)),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedStatus,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All Tasks')),
                    DropdownMenuItem(value: 'OPEN', child: Text('Open')),
                    DropdownMenuItem(value: 'IN_PROGRESS', child: Text('In Progress')),
                    DropdownMenuItem(value: 'CLOSED', child: Text('Completed')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedStatus = val);
                      _loadTasks();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Task list
          Text(
            '${_tasks.length} tasks',
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          if (_tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.task_alt, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    Text('No tasks found', style: TextStyle(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tasks.length,
              itemBuilder: (ctx, i) {
                final task = _tasks[i];
                final status = task[DBColumns.MSTAT] ?? DBConstants.TASK_OPEN;
                final statusColor = _getStatusColor(status);

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(_getStatusIcon(status), color: statusColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task[DBColumns.REMARK] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  decoration: status == DBConstants.TASK_CLOSED ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${task[DBColumns.CREATED_BY] ?? ''}  •  ${task[DBColumns.CREATED_AT] ?? ''}',
                                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (action) {
                            if (action == 'delete') {
                              _deleteTask(task[DBColumns.ID]);
                            } else {
                              _updateStatus(task[DBColumns.ID], action);
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(value: 'OPEN', child: Text('Mark as Open')),
                            const PopupMenuItem(value: 'IN_PROGRESS', child: Text('Mark as In Progress')),
                            const PopupMenuItem(value: 'CLOSED', child: Text('Mark as Completed')),
                            const PopupMenuDivider(),
                            const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }
}
