import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _userKey = 'user_data';
  static const String _isSignedInKey = 'is_signed_in';
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final user = UserModel.fromGoogleSignIn(googleUser);
        await _saveUserData(user);
        await _setSignedInStatus(true);
        
        if (kDebugMode) {
          print('Google Sign-In successful for: ${user.email}');
        }
        
        return user;
      }
      return null;
    } catch (error) {
      if (kDebugMode) {
        print('Google Sign-In error: $error');
      }
      throw Exception('Failed to sign in with Google: $error');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _clearUserData();
      await _setSignedInStatus(false);
      
      if (kDebugMode) {
        print('User signed out and local data cleared');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Sign out error: $error');
      }
      throw Exception('Failed to sign out: $error');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      final isSignedIn = prefs.getBool(_isSignedInKey) ?? false;
      
      if (userData != null && isSignedIn) {
        final userJson = jsonDecode(userData);
        final user = UserModel.fromJson(userJson);
        
        if (kDebugMode) {
          print('Retrieved user from local storage: ${user.email}');
        }
        
        return user;
      }
      
      return null;
    } catch (error) {
      if (kDebugMode) {
        print('Error retrieving current user: $error');
      }
      return null;
    }
  }

  Future<bool> isSignedIn() async {
    try {
      // Check local storage first
      final prefs = await SharedPreferences.getInstance();
      final localSignedIn = prefs.getBool(_isSignedInKey) ?? false;
      
      if (!localSignedIn) {
        return false;
      }
      
      // Also check with Google Sign-In service
      final googleUser = await _googleSignIn.signInSilently();
      final googleSignedIn = googleUser != null;
      
      // If there's a mismatch, clear local data
      if (localSignedIn && !googleSignedIn) {
        await _clearUserData();
        await _setSignedInStatus(false);
        return false;
      }
      
      return localSignedIn && googleSignedIn;
    } catch (error) {
      if (kDebugMode) {
        print('Error checking sign-in status: $error');
      }
      return false;
    }
  }

  Future<void> _saveUserData(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      await prefs.setString(_userKey, userJson);
      
      if (kDebugMode) {
        print('User data saved to local storage');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error saving user data: $error');
      }
      throw Exception('Failed to save user data: $error');
    }
  }

  Future<void> _clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      
      if (kDebugMode) {
        print('User data cleared from local storage');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error clearing user data: $error');
      }
      throw Exception('Failed to clear user data: $error');
    }
  }

  Future<void> _setSignedInStatus(bool isSignedIn) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isSignedInKey, isSignedIn);
      
      if (kDebugMode) {
        print('Sign-in status set to: $isSignedIn');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error setting sign-in status: $error');
      }
    }
  }

  // Method to refresh user data from Google
  Future<UserModel?> refreshUserData() async {
    try {
      final googleUser = await _googleSignIn.signInSilently();
      if (googleUser != null) {
        final user = UserModel.fromGoogleSignIn(googleUser);
        await _saveUserData(user);
        return user;
      }
      return null;
    } catch (error) {
      if (kDebugMode) {
        print('Error refreshing user data: $error');
      }
      return null;
    }
  }
}
