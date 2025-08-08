import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import 'dart:developer' as developer;

class TaskService {
  final CollectionReference taskCollection =
      FirebaseFirestore.instance.collection('tasks');

 
  Stream<List<Task>> getTasks(String userId) {
    return taskCollection
        .where('userId', isEqualTo: userId)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }

  Future<List<Task>> fetchTasks(String userId) async {
    try {
      final snapshot = await taskCollection
          .where('userId', isEqualTo: userId)
          .orderBy('dueDate')
          .get();

      return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
    } catch (e) {
      developer.log(" Failed to fetch tasks", error: e);
      throw Exception("Failed to fetch tasks: $e");
    }
  }

 
  Future<String> addTask(Task task) async {
    try {
      developer.log(" [TaskService] Preparing task for Firestore");
      Map<String, dynamic> taskData = task.toMap();
      taskData.remove('id'); // Firestore auto-generates ID

      // Add to Firestore
      final docRef = await taskCollection.add(taskData);

      // Update the document with its ID (optional)
      await docRef.update({'id': docRef.id});

      developer.log(" [TaskService] Task saved with ID: ${docRef.id}");
      return docRef.id;
    } catch (e) {
      developer.log(" [TaskService] Failed to add task", error: e);
      throw Exception("Failed to add task: $e");
    }
  }

 
  Future<void> updateTask(Task task) async {
    try {
      await taskCollection.doc(task.id).update(task.toMap());
      developer.log("🔁 Task updated: ${task.id}");
    } catch (e) {
      developer.log(" Failed to update task", error: e);
      throw Exception("Failed to update task: $e");
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await taskCollection.doc(taskId).delete();
      developer.log("🗑️ Task deleted: $taskId");
    } catch (e) {
      developer.log(" Failed to delete task", error: e);
      throw Exception("Failed to delete task: $e");
    }
  }

 
  Future<void> toggleTaskComplete(String taskId, bool isCompleted) async {
    try {
      await taskCollection.doc(taskId).update({'isCompleted': isCompleted});
      developer.log(" Completion updated for task: $taskId");
    } catch (e) {
      developer.log(" Failed to toggle completion", error: e);
      throw Exception("Failed to update completion: $e");
    }
  }
}
