import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock authentication - in real app, validate with server
      if (email == 'admin@hokben.com' && password == 'admin123') {
        _currentUser = User(
          id: '1',
          name: 'Administrator',
          email: email,
          role: UserRole.admin,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (email == 'manager@hokben.com' && password == 'manager123') {
        _currentUser = User(
          id: '2',
          name: 'Manager Operasional',
          email: email,
          role: UserRole.manager,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile(String name, String email) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(name: name, email: email);
      notifyListeners();
    }
  }

  // Auto-login for demo purposes
  void autoLogin() {
    _currentUser = User(
      id: '1',
      name: 'Demo User',
      email: 'demo@hokben.com',
      role: UserRole.manager,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
    notifyListeners();
  }
}
