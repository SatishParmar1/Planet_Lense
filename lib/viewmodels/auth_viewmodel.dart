import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel _user = UserModel.empty();
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  // Getters
  UserModel get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get isSignedIn => _user.isSignedIn;

  // Initialize user state and check if user is already logged in
  Future<void> initializeAuth() async {
    try {
      _setLoading(true);
      
      // Check if user data exists in local storage
      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null && currentUser.isSignedIn) {
        _user = currentUser;
        if (kDebugMode) {
          print('User restored from local storage: ${_user.email}');
        }
      }
      
      // Check with Google Sign-In if user is still signed in
      final isStillSignedIn = await _authService.isSignedIn();
      if (!isStillSignedIn && _user.isSignedIn) {
        // User was signed out externally, clear local data
        await _authService.signOut();
        _user = UserModel.empty();
        if (kDebugMode) {
          print('User was signed out externally, clearing local data');
        }
      }
      
      _isInitialized = true;
      _setLoading(false);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize authentication: $e');
      }
      _setError('Failed to initialize authentication: $e');
      _isInitialized = true;
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();
      
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        _user = user;
        if (kDebugMode) {
          print('User signed in successfully: ${_user.email}');
          print('User data saved to local storage');
        }
      }
      
      _setLoading(false);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to sign in: $e');
      }
      _setError('Failed to sign in: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();
      
      await _authService.signOut();
      _user = UserModel.empty();
      
      if (kDebugMode) {
        print('User signed out successfully');
        print('Local user data cleared');
      }
      
      _setLoading(false);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to sign out: $e');
      }
      _setError('Failed to sign out: $e');
    }
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    if (!_user.isSignedIn) return;
    
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null) {
        _user = currentUser;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to refresh user data: $e');
      }
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
