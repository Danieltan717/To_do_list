import 'package:flutter/material.dart';
import 'package:todolist/services/firestore_service.dart';
import '../../services/task_model.dart';

class EditLongTermTaskPage extends StatefulWidget {
  final String taskId;
  final String userId;
  final String name;
  final DateTime? deadline;
  final List<Map<String, dynamic>> subtasks;

  const EditLongTermTaskPage({
    super.key,
    required this.taskId,
    required this.userId,
    required this.name,
    required this.deadline,
    required this.subtasks,
  });

  @override
  State<EditLongTermTaskPage> createState() => _EditLongTermTaskPageState();
}

class _EditLongTermTaskPageState extends State<EditLongTermTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  bool _isSubmitting = false;
  bool _parentCompleted = false;

  late List<Subtask> _subtasks;

  // Originals for change detection
  late String _originalName;
  DateTime? _originalDeadline;
  late List<Subtask> _originalSubtasks;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
    _nameController.addListener(() {
      setState(() {}); // triggers rebuild on name change
    });
    _selectedDate = widget.deadline;
    _subtasks = widget.subtasks.map((s) => Subtask.fromMap(s)).toList();
    _parentCompleted = _subtasks.isNotEmpty && _subtasks.every((s) => s.completed);

    _originalName = widget.name;
    _originalDeadline = widget.deadline;
    _originalSubtasks = List<Subtask>.from(_subtasks);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectSubtaskDate(int index) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _subtasks[index].deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _subtasks[index] = Subtask(
          name: _subtasks[index].name,
          deadline: picked,
          completed: _subtasks[index].completed,
        );
      });
    }
  }

  void _showEditSubtaskNameDialog(int index) {
    final controller = TextEditingController(text: _subtasks[index].name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Subtask Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Subtask Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _subtasks[index] = Subtask(
                  name: controller.text.trim(),
                  deadline: _subtasks[index].deadline,
                  completed: _subtasks[index].completed,
                );
              });
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddSubtaskDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Subtask'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Subtask Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                setState(() {
                  _subtasks.add(Subtask(name: newName));
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeSubtask(int index) {
    setState(() {
      _subtasks.removeAt(index);
      _parentCompleted = _subtasks.isNotEmpty && _subtasks.every((s) => s.completed);
    });
  }

  void _toggleParentComplete(bool complete) {
    setState(() {
      _parentCompleted = complete;
      _subtasks = _subtasks
          .map((s) => Subtask(
        name: s.name,
        deadline: s.deadline,
        completed: complete,
      ))
          .toList();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirestoreService().updateLongTermTask(
        taskId: widget.taskId,
        userId: widget.userId,
        name: _nameController.text.trim(),
        deadline: _selectedDate!,
        subtasks: _subtasks.map((s) => s.toMap()).toList(),
        completed: _parentCompleted,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task updated!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  bool get _hasChanges {
    if (_nameController.text.trim() != _originalName) return true;
    if (_selectedDate != _originalDeadline) return true;
    if (_subtasks.length != _originalSubtasks.length) return true;

    for (int i = 0; i < _subtasks.length; i++) {
      final s1 = _subtasks[i];
      final s2 = i < _originalSubtasks.length ? _originalSubtasks[i] : null;
      if (s2 == null ||
          s1.name != s2.name ||
          s1.completed != s2.completed ||
          s1.deadline != s2.deadline) {
        return true;
      }
    }

    if (_parentCompleted !=
        (_originalSubtasks.isNotEmpty && _originalSubtasks.every((s) => s.completed))) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Long-term Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Task Name',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _selectDate,
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                if (_selectedDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: Text('Deadline: ${_formatDate(_selectedDate!)}'),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: _parentCompleted,
                      onChanged: (value) => _toggleParentComplete(value ?? false),
                    ),
                    const Text('Mark entire task as complete'),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Subtasks:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _subtasks.length,
                  itemBuilder: (context, index) {
                    final subtask = _subtasks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: Checkbox(
                          value: subtask.completed,
                          onChanged: (checked) {
                            setState(() {
                              _subtasks[index] = Subtask(
                                name: subtask.name,
                                deadline: subtask.deadline,
                                completed: checked ?? false,
                              );
                              _parentCompleted =
                                  _subtasks.isNotEmpty && _subtasks.every((s) => s.completed);
                            });
                          },
                        ),
                        title: Text(subtask.name),
                        subtitle: subtask.deadline != null
                            ? Text('Due: ${_formatDate(subtask.deadline!)}')
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditSubtaskNameDialog(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => _selectSubtaskDate(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeSubtask(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (!_hasChanges || _isSubmitting) ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSubtaskDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add New Subtask',
      ),
    );
  }
}