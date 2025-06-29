import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import 'edit_long_term_task_page.dart';

class LongTermTasksPage extends StatefulWidget {
  const LongTermTasksPage({super.key});

  @override
  State<LongTermTasksPage> createState() => _LongTermTasksPageState();
}

class _LongTermTasksPageState extends State<LongTermTasksPage> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  late final TabController _tabController;
  final Set<String> _selectedTasks = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTasks.clear();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _tasksStream(bool completed) {
    return _firestore
        .collection('users')
        .doc(_user?.uid)
        .collection('tasks')
        .where('type', isEqualTo: 'long')
        .where('completed', isEqualTo: completed)
        .orderBy('deadline')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Long-term Tasks'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'To-Do'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTasksList(completed: false),
                _buildTasksList(completed: true),
              ],
            ),
          ),
          if (_selectedTasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: Icon(
                  _tabController.index == 0 ? Icons.check : Icons.undo,
                ),
                label: Text(
                  _tabController.index == 0
                      ? 'Mark as Complete'
                      : 'Unmark Task',
                ),
                onPressed: () {
                  final isTodoTab = _tabController.index == 0;
                  _markSelectedAsComplete(isTodoTab ? true : false);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTasksList({required bool completed}) {
    return StreamBuilder<QuerySnapshot>(
      stream: _tasksStream(completed),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading tasks'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = snapshot.data?.docs ?? [];

        if (tasks.isEmpty) {
          return Center(
            child: Text(
              completed ? 'No completed tasks' : 'No tasks to do',
              style: const TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            final data = task.data() as Map<String, dynamic>;
            final deadline = data['deadline']?.toDate();
            // final subtasks = data['subtasks'] as List<dynamic>? ?? [];
            final subtasks = (data['subtasks'] as List<dynamic>? ?? [])
                .map((s) => s as Map<String, dynamic>)
                .toList();

            final isSelected = _selectedTasks.contains(task.id);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                onTap: () {
                  final cleanedSubtasks = subtasks.map<Map<String, dynamic>>((s) {
                    final subtaskMap = s as Map<dynamic, dynamic>;
                    return {
                      'name': subtaskMap['name'] ?? '',
                      'deadline': subtaskMap['deadline'] is Timestamp
                          ? (subtaskMap['deadline'] as Timestamp).toDate()
                          : subtaskMap['deadline'] as DateTime?,
                      'completed': subtaskMap['completed'] ?? false,
                    };
                  }).toList();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditLongTermTaskPage(
                        taskId: task.id,
                        name: data['name'] ?? '',
                        deadline: deadline ?? DateTime.now(),
                        subtasks: subtasks,
                        //subtasks: cleanedSubtasks,
                        userId: _user!.uid,
                      ),
                    ),
                  );
                },
                title: Text(data['name'] ?? 'Untitled Task'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (deadline != null)
                      Text('Due: ${_formatDate(deadline)}'),
                    if (subtasks.isNotEmpty)
                      Text(
                        '${subtasks
                            .where((s) => s['completed'] == true)
                            .length}'
                            '/${subtasks.length} subtasks completed',
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: isSelected,
                      onChanged: (selected) =>
                          _toggleSelect(task.id, selected ?? false),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteTask(task.id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _toggleSelect(String taskId, bool selected) {
    setState(() {
      if (selected) {
        _selectedTasks.add(taskId);
      } else {
        _selectedTasks.remove(taskId);
      }
    });
  }

  Future<void> _markSelectedAsComplete(bool complete) async {
    if (_user == null) return;

    try {
      await FirestoreService().markTasksAsComplete(
        taskIds: _selectedTasks.toList(),
        userId: _user.uid,
        complete: complete,
      );
      setState(() {
        _selectedTasks.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            complete
                ? 'Tasks marked as complete'
                : 'Tasks unmarked as complete',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating tasks: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_user?.uid)
          .collection('tasks')
          .doc(taskId)
          .delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: ${e.toString()}')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month
        .toString()
        .padLeft(2, '0')}-${date.year}';
  }
}