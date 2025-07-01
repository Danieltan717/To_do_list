import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todolist/screens/task_pages/long_term_tasks_page.dart';
import 'package:todolist/screens/task_pages/short_term_tasks_page.dart';
import '../screens/login_page.dart';
import 'task_pages/add_short_term_task_page.dart';
import 'task_pages/add_long_term_task_page.dart';
import 'settings_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todolist/services/firestore_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  final int _maxLoad = 10;
  List<Map<String, dynamic>> _shortTermTasks = [];
  List<Map<String, dynamic>> _longTermTasks = [];
  List<Map<String, dynamic>> _selectedTasks = [];

  int get _currentLoad => _selectedTasks.fold(0, (sum, task) => sum + ((task['load'] ?? 1) as int));

  Color get _loadColor {
    final count = _selectedTasks.length;
    if (count <= 2) return Colors.green;
    if (count <= 5) return Colors.yellow;
    if (count <= 8) return Colors.orange;
    if (count <= 10) return Colors.red;
    return Colors.red.shade900;
  }

  Future<void> _fetchAvailableTasks() async {
    final uid = user?.uid;
    if (uid == null) return;

    final tasksSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .where('completed', isEqualTo: false)
        .get();

    List<Map<String, dynamic>> shortTasks = [];
    List<Map<String, dynamic>> longTasks = [];

    for (var doc in tasksSnapshot.docs) {
      final data = doc.data();
      if (data['type'] == 'short') {
        final taskMap = {
          'name': data['name'],
          'load': data['load'] ?? 1,
          'docId': doc.id,
          'isSubtask': false,
          'type': 'short'
        };
        if (!_selectedTasks.any((t) => t['name'] == taskMap['name'])) {
          shortTasks.add(taskMap);
        }
      } else if (data['type'] == 'long') {
        final subtasks = (data['subtasks'] as List?)?.map((s) => Map<String, dynamic>.from(s)).toList() ?? [];
        for (var sub in subtasks) {
          if (!(sub['completed'] ?? false)) {
            final subtaskMap = {
              'name': sub['name'],
              'load': sub['load'] ?? 1,
              'docId': doc.id,
              'isSubtask': true,
              'type': 'long'
            };
            if (!_selectedTasks.any((t) => t['name'] == subtaskMap['name'])) {
              longTasks.add(subtaskMap);
            }
          }
        }
      }
    }

    setState(() {
      _shortTermTasks = shortTasks;
      _longTermTasks = longTasks;
    });
  }

  void _selectFocusTask() async {
    await _fetchAvailableTasks();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Short-term Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._shortTermTasks.map((task) => Card(
                  child: ListTile(
                    title: Text(task['name']),
                    subtitle: Text('Load: ${task['load']}'),
                    onTap: () {
                      setState(() {
                        _selectedTasks.add(task);
                        _shortTermTasks.remove(task);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Task successfully added to daily focus')),
                      );
                      Navigator.pop(context);
                    },
                  ),
                )),
                const SizedBox(height: 16),
                const Text('Long-term Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._longTermTasks.map((task) => Card(
                  child: ListTile(
                    title: Text(task['name']),
                    subtitle: Text('Load: ${task['load']}'),
                    onTap: () {
                      setState(() {
                        _selectedTasks.add(task);
                        _longTermTasks.remove(task);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Task successfully added to daily focus')),
                      );
                      Navigator.pop(context);
                    },
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _markTaskComplete(Map<String, dynamic> task) async {
    final uid = user?.uid;
    if (uid == null) return;

    if (task['isSubtask'] == true) {
      final docRef = FirebaseFirestore.instance.collection('users').doc(uid).collection('tasks').doc(task['docId']);
      final snapshot = await docRef.get();
      final data = snapshot.data();
      if (data == null) return;

      final subtasks = (data['subtasks'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [];
      for (var sub in subtasks) {
        if (sub['name'] == task['name']) {
          sub['completed'] = true;
          break;
        }
      }

      await FirestoreService().updateLongTermTask(
        taskId: task['docId'],
        userId: uid,
        name: data['name'],
        deadline: (data['deadline'] as Timestamp).toDate(),
        subtasks: subtasks,
        completed: false,
      );
    } else {
      await FirestoreService().markTasksAsComplete(
        taskIds: [task['docId']],
        userId: uid,
        complete: true,
      );
    }

    setState(() {
      _selectedTasks.remove(task);
    });
  }

  Widget _buildCognitiveLoadMeter() {
    final double percent = (_currentLoad / _maxLoad).clamp(0.0, 1.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Cognitive Load Meter',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                value: percent > 1.0 ? 1.0 : percent,
                strokeWidth: 8,
                color: _loadColor,
              ),
            ),
            Text('${(_currentLoad > _maxLoad) ? _maxLoad : _currentLoad} / $_maxLoad'),
          ],
        ),
        if (_currentLoad > _maxLoad)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Too much workload! Reduce focus.',
              style: TextStyle(color: _loadColor, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          )
        ],
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(child: _buildCognitiveLoadMeter()),
            const SizedBox(height: 30),
            SizedBox(
              height: 550,
              width: 400,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _selectFocusTask,
                          icon: const Icon(Icons.lightbulb_outline),
                          label: const Text("Pick Daily Focus Tasks"),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_selectedTasks.isNotEmpty)
                        Expanded(
                          child: ListView(
                            children: [
                              const Text('Today\'s Short-term Focus Tasks:', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ..._selectedTasks.where((task) => task['type'] == 'short').map((task) => Card(
                                child: ListTile(
                                  title: Text(task['name']),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.check, color: Colors.green),
                                        tooltip: 'Mark as Complete',
                                        onPressed: () => _markTaskComplete(task),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        tooltip: 'Remove from Focus',
                                        onPressed: () => setState(() => _selectedTasks.remove(task)),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                              const SizedBox(height: 16),
                              const Text('Today\'s Long-term Focus Tasks:', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ..._selectedTasks.where((task) => task['type'] == 'long').map((task) => Card(
                                child: ListTile(
                                  title: Text(task['name']),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.check, color: Colors.green),
                                        tooltip: 'Mark as Complete',
                                        onPressed: () => _markTaskComplete(task),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        tooltip: 'Remove from Focus',
                                        onPressed: () => setState(() => _selectedTasks.remove(task)),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskTypeBottomSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Short-term Tasks'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ShortTermTasksPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Long-term Tasks'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LongTermTasksPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showTaskTypeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Short-term task'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddShortTermTask(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Long-term task'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddLongTermTask(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
