import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todolist/services/firestore_service.dart';
import 'package:todolist/services/task_model.dart';

class AddLongTermTask extends StatefulWidget {
  const AddLongTermTask({super.key});

  @override
  State<AddLongTermTask> createState() => _AddLongTermTaskState();
}

class _AddLongTermTaskState extends State<AddLongTermTask> {
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  final _taskNameController = TextEditingController();
  final _subtaskController = TextEditingController();
  DateTime? _selectedDate;
  final List<Subtask> _subtasks = [];

  @override
  void dispose() {
    _taskNameController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
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

  Future<void> _selectSubtaskDate(BuildContext context, int index) async {
    final DateTime? picked = await showDatePicker(
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
        );
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  void _addSubtask() {
    if (_subtaskController.text.isNotEmpty) {
      setState(() {
        _subtasks.add(Subtask(name: _subtaskController.text)); // Create Subtask object
        _subtaskController.clear();
      });
    }
  }

  // Uncomment if that weird bug of not being able to add long-term task if the subtask name has spacing comes back
  // void _addSubtask() {
  //   final trimmed = _subtaskController.text.trim();
  //   if (trimmed.isNotEmpty) {
  //     setState(() {
  //       _subtasks.add(Subtask(name: trimmed)); // trimmed name here
  //       _subtaskController.clear();
  //     });
  //   }
  // }


  void _removeSubtask(int index) {
    setState(() {
      _subtasks.removeAt(index);
    });
  }

  void _submitTask() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final subtasksData = _subtasks.map((subtask) => {
        'name': subtask.name.trim(),
        'deadline': subtask.deadline != null
            ? Timestamp.fromDate(subtask.deadline!)
            : null,
        'completed': false,
        // Removed: 'createdAt': FieldValue.serverTimestamp()
      }).toList();

      await FirestoreService().addTask(
        name: _taskNameController.text.trim(),
        deadline: _selectedDate!,
        type: 'long',
        subtasks: subtasksData,
        userEmail: FirebaseAuth.instance.currentUser?.email,
        userId: FirebaseAuth.instance.currentUser?.uid,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task saved successfully!')),
      );
      if (mounted) Navigator.pop(context);

    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: ${e.message}')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Long-term Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task Name Field with Calendar Button
                TextFormField(
                  controller: _taskNameController,
                  decoration: InputDecoration(
                    labelText: 'Task Name',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                      tooltip: 'Select deadline',
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a task name';
                    }
                    return null;
                  },
                ),

                // Deadline Display
                if (_selectedDate != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                      child: Text(
                        'Deadline: ${_formatDate(_selectedDate!)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Subtasks Section
                const Text(
                  'Subtasks:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _subtasks.length,
                  itemBuilder: (context, index) {
                    final subtask = _subtasks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        title: Text(subtask.name),
                        subtitle: subtask.deadline != null
                            ? Text('Due: ${_formatDate(subtask.deadline!)}')
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.calendar_today, size: 20),
                              onPressed: () => _selectSubtaskDate(context, index),
                              tooltip: 'Set subtask deadline',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              onPressed: () => _removeSubtask(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Add Subtask Field
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _subtaskController,
                        decoration: const InputDecoration(
                          labelText: 'Add subtask',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addSubtask,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Create Task Button
                Center(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitTask,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: _isSubmitting
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text('Create Task', style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}