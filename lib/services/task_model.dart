import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String name;
  final DateTime deadline;

  Task({required this.name, required this.deadline});
}

class Subtask {
  final String name;
  final DateTime? deadline;
  final bool completed;

  Subtask({
    required this.name,
    this.deadline,
    this.completed = false,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
    'completed': completed,
  };

  static Subtask fromMap(Map<String, dynamic> map) => Subtask(
    name: map['name'],
    deadline: map['deadline'] != null ? (map['deadline'] as Timestamp).toDate() : null,
    completed: map['completed'] ?? false,
  );
}


class LongTermTask extends Task {
  final List<Subtask> subtasks;

  LongTermTask({
    required super.name,
    required super.deadline,
    required this.subtasks,
  });

  // Conversion to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'deadline': deadline.millisecondsSinceEpoch,
      'subtasks': subtasks.map((subtask) => subtask.toMap()).toList(),
    };
  }
}