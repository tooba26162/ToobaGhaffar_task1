import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/task_model.dart';
import '../../viewmodels/task_viewmodel.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late bool _isEditing;
  final _formKey = GlobalKey<FormState>();

  late String _title;
  late String _description;
  late DateTime _dueDate;
  late String _priority;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _isEditing = false;
    _title = widget.task.title;
    _description = widget.task.description;
    _dueDate = widget.task.dueDate;
    _priority = widget.task.priority;
    _isCompleted = widget.task.isCompleted;
  }

  Future<void> _pickDueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _saveTask(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final updatedTask = widget.task.copyWith(
      title: _title,
      description: _description,
      dueDate: _dueDate,
      priority: _priority,
      isCompleted: _isCompleted,
    );

    await Provider.of<TaskViewModel>(context, listen: false).updateTask(updatedTask);

    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Task updated successfully")),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDetailItem({required IconData icon, required String label, required String value, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: color ?? Colors.black87),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    )),
                const SizedBox(height: 4),
                Text(value,
                    style: TextStyle(
                      fontSize: 16,
                      color: color ?? Colors.black87,
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            initialValue: _title,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            onSaved: (value) => _title = value ?? '',
            validator: (value) => value == null || value.isEmpty ? 'Please enter title' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _description,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onSaved: (value) => _description = value ?? '',
            validator: (value) => value == null || value.isEmpty ? 'Please enter description' : null,
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Due Date'),
            subtitle: Text(DateFormat('yyyy-MM-dd').format(_dueDate)),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () => _pickDueDate(context),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _priority,
            decoration: const InputDecoration(
              labelText: 'Priority',
              border: OutlineInputBorder(),
            ),
            items: ['Low', 'Medium', 'High']
                .map((level) => DropdownMenuItem(
                      value: level,
                      child: Text(level),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _priority = value!),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Mark as Completed'),
            value: _isCompleted,
            onChanged: (value) => setState(() => _isCompleted = value),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _saveTask(context),
            icon: const Icon(Icons.save),
            label: const Text('Save Task'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[800],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskDetails(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        elevation: 5,
        color: const Color(0xFFFFF9DB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem(
                icon: Icons.title,
                label: 'Title',
                value: widget.task.title,
              ),
              _buildDetailItem(
                icon: Icons.description,
                label: 'Description',
                value: widget.task.description,
              ),
              _buildDetailItem(
                icon: Icons.calendar_today,
                label: 'Due Date',
                value: DateFormat('yyyy-MM-dd').format(widget.task.dueDate),
              ),
              _buildDetailItem(
                icon: Icons.flag,
                label: 'Priority',
                value: widget.task.priority,
                color: _getPriorityColor(widget.task.priority),
              ),
              _buildDetailItem(
                icon: Icons.check_circle,
                label: 'Status',
                value: widget.task.isCompleted ? 'Completed' : 'Incomplete',
                color: widget.task.isCompleted ? Colors.green : Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9DB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFEBA1),
        title: Text(_isEditing ? 'Edit Task' : 'Task Details',
            style: const TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            tooltip: _isEditing ? 'Cancel' : 'Edit',
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isEditing ? _buildEditForm() : _buildTaskDetails(context),
      ),
    );
  }
}
