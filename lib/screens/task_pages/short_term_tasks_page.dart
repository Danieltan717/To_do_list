import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import 'edit_short_term_task_page.dart';

class ShortTermTasksPage extends StatefulWidget {
  const ShortTermTasksPage({super.key});

  @override
  State<ShortTermTasksPage> createState() => _ShortTermTasksPageState();
}

class _ShortTermTasksPageState extends State<ShortTermTasksPage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  late final TabController _tabController;
  final Set<String> _selectedTasks = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Listen to tab changes and clear selection when switching
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
        .where('type', isEqualTo: 'short')
        .where('completed', isEqualTo: completed)
        .orderBy('deadline')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    // final bool isTodoTab = _tabController.index == 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Short-term Tasks'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'To-Do'),
            Tab(text: 'Completed'),
          ],
          labelColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.white,
          unselectedLabelColor: Theme.of(context).textTheme.bodyLarge?.color,
          indicatorColor: Theme.of(context).colorScheme.primary,
          // labelColor: Theme.of(context).colorScheme.onPrimary,
          // unselectedLabelColor: Theme.of(context).textTheme.bodyLarge?.color,
          // indicatorColor: Theme.of(context).colorScheme.primary,
          // indicatorWeight: 3.0,
          onTap: (_) => setState(() {
            _selectedTasks.clear();
          }),
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
          // Explicitly set text color for error message
          return Center(
            child: Text(
              'Error loading tasks',
              style: TextStyle(
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = snapshot.data?.docs ?? [];

        if (tasks.isEmpty) {
          // Explicitly set text color for empty state message
          return Center(
            child: Text(
              completed ? 'No completed tasks' : 'No tasks to do',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            final data = task.data() as Map<String, dynamic>;
            final deadline = data['deadline']?.toDate();

            final isSelected = _selectedTasks.contains(task.id);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditShortTermTaskPage(
                        taskId: task.id,
                        name: data['name'] ?? '',
                        deadline: deadline ?? DateTime.now(),
                        userId: _user!.uid,
                      ),
                    ),
                  );
                },
                title: Text(data['name'] ?? 'Untitled Task'),
                subtitle: deadline != null
                    ? Text('Due: ${_formatDate(deadline)}')
                    : null,
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
      debugPrint('Marking tasks as complete=$complete for: $_selectedTasks');
      await FirestoreService().markTasksAsComplete(
        taskIds: _selectedTasks.toList(),
        userId: _user.uid,
        complete: complete,
      );
      setState(() {_selectedTasks.clear();});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            complete
                ? 'Marked selected task(s) as completed'
                : 'Unmarked selected task(s) as completed',
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
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }
}