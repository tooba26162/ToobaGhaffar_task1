import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// 🔁 Listen to real-time tasks for the logged-in user
  void listenToTasks() {
    _setLoading(true);

    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      _errorMessage = "User not logged in";
      _setLoading(false);
      return;
    }

    _taskService.getTasks(userId).listen((taskList) {
      _tasks = taskList;
      _errorMessage = null;
      _setLoading(false);
      notifyListeners();
    }, onError: (error) {
      _errorMessage = error.toString();
      _setLoading(false);
      notifyListeners();
    });
  }

  /// ✅ Listen to tasks by userId (used in AuthWrapper)
  void listenToTasksById(String userId) {
    _setLoading(true);
    print("🔁 [TaskViewModel] Listening to tasks for userId: $userId");

    _taskService.getTasks(userId).listen((taskList) {
      _tasks = taskList;
      _errorMessage = null;
      _setLoading(false);
      notifyListeners();
    }, onError: (error) {
      _errorMessage = error.toString();
      _setLoading(false);
      notifyListeners();
    });
  }

  /// 📦 Fetch tasks once (non-realtime)
  Future<void> fetchTasks() async {
    _setLoading(true);

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _errorMessage = "User not logged in";
      _setLoading(false);
      return;
    }

    try {
      final fetchedTasks = await _taskService.fetchTasks(userId);
      _tasks = fetchedTasks;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _setLoading(false);
    notifyListeners();
  }

  /// ➕ Add new task
  Future<bool> addTask(Task task) async {
    _setLoading(true);
    print("🚀 [TaskViewModel] Starting addTask");

    try {
      await _taskService.addTask(task);
      print("✅ Task added successfully");
      _errorMessage = null;
      await fetchTasks(); // Refresh list
      return true; // ✅ Success
    } catch (e) {
      print("❌ Error adding task: $e");
      _errorMessage = e.toString();
      return false; // ❌ Failure
    } finally {
      _setLoading(false);
      print("🏁 Finished addTask");
    }
  }

  /// ✏️ Update existing task
  Future<void> updateTask(Task task) async {
    _setLoading(true);
    try {
      await _taskService.updateTask(task);
      _errorMessage = null;
      await fetchTasks();
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  /// ❌ Delete a task
  Future<void> deleteTask(String taskId) async {
    _setLoading(true);
    try {
      await _taskService.deleteTask(taskId);
      _errorMessage = null;
      await fetchTasks();
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  /// ✅ Toggle completion
  Future<void> toggleCompletion(String taskId, bool isCompleted) async {
    _setLoading(true);
    try {
      await _taskService.toggleTaskComplete(taskId, isCompleted);
      _errorMessage = null;
      await fetchTasks();
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  /// 🔄 Helper: Set loading
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
