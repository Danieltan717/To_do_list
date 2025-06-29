import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user's tasks collection reference
  CollectionReference get _userTasks {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(user.uid).collection('tasks');
  }

  Future<void> addTask({
    required String name,
    required DateTime deadline,
    required String type,
    String? userEmail,
    String? userId,
    List<Map<String, dynamic>>? subtasks,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .add({
      'name': name,
      'deadline': Timestamp.fromDate(deadline),
      'type': type,
      'userEmail': userEmail,
      'userId': userId,
      'completed': false,
      'createdAt': FieldValue.serverTimestamp(),
      'subtasks': subtasks?.map((s) => {
        'name': s['name'],
        'deadline': s['deadline'] != null
            ? Timestamp.fromDate(s['deadline'])
            : null,
        'completed': s['completed'] ?? false,
      }).toList() ??
          [],
    });
  }

  Future<void> updateTask({
    required String taskId,
    required String userId,
    required String name,
    required DateTime? deadline,
    List<Map<String, dynamic>>? subtasks,
  }) async {
    final taskRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId);

    final data = {
      'name': name,
      'deadline': Timestamp.fromDate(deadline!),
      if (subtasks != null)
        'subtasks': subtasks.map((s) {
          return {
            'name': s['name'],
            'deadline': s['deadline'] != null
                ? Timestamp.fromDate(s['deadline'])
                : null,
            'completed': s['completed'] ?? false,
          };
        }).toList(),
    };

    await taskRef.update(data);
  }

  Future<void> updateLongTermTask({
    required String taskId,
    required String userId,
    required String name,
    required DateTime deadline,
    required List<Map<String, dynamic>> subtasks,
    required bool completed,
  }) async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId);

    await docRef.update({
      'name': name,
      'deadline': Timestamp.fromDate(deadline),
      'subtasks': subtasks,
      'completed': completed,
    });
  }


  Future<void> markTasksAsComplete({
    required List<String> taskIds,
    required String userId,
    required bool complete,
  }) async {
    final batch = _firestore.batch();
    final tasksCollection =
    _firestore.collection('users').doc(userId).collection('tasks');

    for (final id in taskIds) {
      final docRef = tasksCollection.doc(id);
      final snapshot = await docRef.get();

      if (!snapshot.exists) continue;

      final data = snapshot.data() as Map<String, dynamic>;

      // Check if this is a long-term task with subtasks
      if (data.containsKey('subtasks') && data['subtasks'] is List) {
        final List<dynamic> subtasks = data['subtasks'] ?? [];

        final updatedSubtasks = subtasks.map((s) {
          return {
            'name': s['name'],
            'deadline': s['deadline'],
            'completed': complete,
          };
        }).toList();

        batch.update(docRef, {
          'completed': complete,
          'subtasks': updatedSubtasks,
        });
      } else {
        // Short-term tasks: just update completed status
        batch.update(docRef, {'completed': complete});
      }
    }

    await batch.commit();
  }

  // Future<void> markTasksAsComplete({
  //   required List<String> taskIds,
  //   required String userId,
  //   required bool complete,
  // }) async {

  Stream<QuerySnapshot> getUserTasks() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return _firestore
        .collectionGroup('tasks')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }
}