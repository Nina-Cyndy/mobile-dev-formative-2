import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  UserModel? _userModel;
  StreamSubscription<UserModel?>? _userDocSub;

  bool _isLoading = false; // auth action loading (login/register)
  bool _profileLoading = false; // fetching the Firestore role doc
  String? _error;
  String? _profileError;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  String get role => _userModel?.role ?? 'student';
  bool get isLoading => _isLoading;
  bool get loading => _isLoading;
  bool get profileLoading => _profileLoading;
  String? get error => _error;
  String? get profileError => _profileError;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  AuthProvider() {
    _authService.authStateChanges.listen((user) {
      _user = user;
      _userDocSub?.cancel();
      _profileError = null;
      if (user == null) {
        _userModel = null;
        _profileLoading = false;
        notifyListeners();
        return;
      }
      // Listen (not just fetch-once) so the app immediately reflects the
      // role as soon as the signup write lands, and stays in sync if it
      // ever changes later (e.g. an admin edits it in Firestore).
      _profileLoading = true;
      notifyListeners();
      _userDocSub = _authService.userDocStream(user.uid).listen(
        (model) {
          _userModel = model;
          _profileLoading = false;
          _profileError = null;
          notifyListeners();
        },
        onError: (e) {
          // Without this handler a blocked read (e.g. Firestore rules not
          // published yet) would leave profileLoading stuck at true
          // forever, which is exactly what showed up as an infinite
          // loading spinner after login.
          _profileLoading = false;
          _profileError = e is FirebaseException && e.code == 'permission-denied'
              ? "Can't load your profile: Firestore rules are blocking access. "
                  "Make sure firestore.rules has been published in the Firebase Console."
              : "Couldn't load your profile: $e";
          notifyListeners();
        },
      );
    });
  }

  Future<bool> register(
    String email,
    String password,
    String fullName,
    String role,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );
      return true;
    } catch (e) {
      _error = _friendlyError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.signIn(email, password);
    } catch (e) {
      _error = _friendlyError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() => _authService.signOut();

  String _friendlyError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'That email is already registered. Try logging in instead.';
        case 'invalid-email':
          return 'That email address looks invalid.';
        case 'weak-password':
          return 'Password should be at least 6 characters.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';
        default:
          return e.message ?? 'Something went wrong. Please try again.';
      }
    }
    return e.toString();
  }

  @override
  void dispose() {
    _userDocSub?.cancel();
    super.dispose();
  }
}
