import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleComplete;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onDelete,
    this.onToggleComplete,
  });

  // Color coding priority (customize as needed)
  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red.shade700;
      case 'medium':
        return Colors.orange.shade600;
      case 'low':
        return Colors.green.shade600;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(task.priority);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: priorityColor,
          child: Icon(
            task.isCompleted ? Icons.check_circle : Icons.pending,
            color: Colors.white,
            size: 28,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          'Due: ${task.dueDate.toLocal().toString().split(' ')[0]}',
          style: TextStyle(
            color: Colors.grey[700],
            fontStyle: FontStyle.italic,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Toggle completion button
            IconButton(
              icon: Icon(
                task.isCompleted ? Icons.undo : Icons.check,
                color: task.isCompleted ? Colors.blueGrey : Colors.green,
              ),
              tooltip: task.isCompleted ? 'Mark as Incomplete' : 'Mark as Complete',
              onPressed: onToggleComplete,
            ),

            // Delete button
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red.shade700),
              tooltip: 'Delete Task',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
