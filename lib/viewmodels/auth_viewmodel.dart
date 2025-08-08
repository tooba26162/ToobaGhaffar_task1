// lib/viewmodels/auth_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthViewModel() {
    // Listen to Firebase auth state changes and update _user accordingly
    _firebaseService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  // 🔐 Login User
  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      _user = await _firebaseService.login(email, password);
      _errorMessage = null;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Authentication failed.';
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
    }
    _setLoading(false);
  }

  // 🧾 Sign Up User (create account, save info, then logout and redirect to login)
  Future<void> signup(String email, String password, String name, String phone) async {
    _setLoading(true);
    try {
      _user = await _firebaseService.signup(email, password, name, phone);
      _errorMessage = null;

      // ✅ Force logout right after signup
      await _firebaseService.logout();
      _user = null;
      notifyListeners(); // 🔁 Notify that user is now logged out

    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Sign up failed.';
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
    }
    _setLoading(false);
  }

  // 🔁 Reset Password
  Future<void> resetPassword(String email) async {
    _setLoading(true);
    try {
      await _firebaseService.resetPassword(email);
      _errorMessage = null;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Reset password failed.';
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
    }
    _setLoading(false);
  }

  // 🔓 Logout
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _firebaseService.logout();
      _user = null;
      _errorMessage = null;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Logout failed.';
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
    }
    _setLoading(false);
  }

  // 🌀 Internal helper to manage loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
