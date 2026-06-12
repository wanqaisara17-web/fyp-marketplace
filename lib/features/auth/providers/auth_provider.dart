import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  static final RegExp studentEmailPattern = RegExp(
    r'^\d{10}@student\.uitm\.edu\.my$',
  );

  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _isAwaitingSecondFactor = false;
  String? _error;
  String? _pendingEmail;
  String? _verificationId;
  firebase_auth.ConfirmationResult? _webConfirmationResult;

  AuthProvider() {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null && firebaseUser.emailVerified) {
      _user = _fromFirebaseUser(firebaseUser);
      _isAuthenticated = true;
    }
  }

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isAwaitingSecondFactor => _isAwaitingSecondFactor;
  String? get error => _error;
  String? get pendingEmail => _pendingEmail;

  Future<bool> login(String email, String password) async {
    if (!_isStudentEmail(email)) {
      _setError('Use your 10-digit UiTM student email.');
      return false;
    }

    _setLoading(true);

    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        _setError('Login failed. Please try again.');
        return false;
      }

      await firebaseUser.reload();
      final refreshedUser = _firebaseAuth.currentUser;

      if (refreshedUser == null || !refreshedUser.emailVerified) {
        await refreshedUser?.sendEmailVerification();
        await _firebaseAuth.signOut();
        _setError('Please verify your email. We sent a new link to $email.');
        return false;
      }

      _pendingEmail = email;
      _isAuthenticated = false;
      _isAwaitingSecondFactor = true;
      _user = _fromFirebaseUser(refreshedUser);
      _error = null;
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _setError(_friendlyFirebaseError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String email, String password) async {
    if (!_isStudentEmail(email)) {
      _setError('Use your 10-digit UiTM student email.');
      return false;
    }

    _setLoading(true);

    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.sendEmailVerification();
      await _firebaseAuth.signOut();

      _pendingEmail = email;
      _isAuthenticated = false;
      _isAwaitingSecondFactor = false;
      _user = null;
      _error = null;
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _setError(_friendlyFirebaseError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resendEmailVerification(String email, String password) async {
    _setLoading(true);

    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.sendEmailVerification();
      await _firebaseAuth.signOut();
      _error = null;
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _setError(_friendlyFirebaseError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendSecondFactorCode(String phoneNumber) async {
    if (_pendingEmail == null) {
      _setError('Please sign in before requesting a 2FA code.');
      return false;
    }

    _setLoading(true);

    try {
      if (kIsWeb) {
        _webConfirmationResult = await _firebaseAuth.signInWithPhoneNumber(
          phoneNumber,
        );
        _error = null;
        return true;
      }

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) async {
          await _finishSecondFactor();
        },
        verificationFailed: (e) {
          _setError(_friendlyFirebaseError(e));
        },
        codeSent: (verificationId, _) {
          _verificationId = verificationId;
          _error = null;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _setError(_friendlyFirebaseError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyOtp(String otp) async {
    if (_pendingEmail == null) {
      _setError('Your login session expired. Please sign in again.');
      return false;
    }

    _setLoading(true);

    try {
      if (kIsWeb) {
        final result = await _webConfirmationResult?.confirm(otp);
        if (result == null) {
          _setError('Request a 2FA code before verifying.');
          return false;
        }
      } else {
        if (_verificationId == null) {
          _setError('Request a 2FA code before verifying.');
          return false;
        }

        final credential = firebase_auth.PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: otp,
        );
        await _firebaseAuth.signInWithCredential(credential);
      }

      await _finishSecondFactor();
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _setError(_friendlyFirebaseError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    await _firebaseAuth.signOut();
    _user = null;
    _isAuthenticated = false;
    _isAwaitingSecondFactor = false;
    _pendingEmail = null;
    _verificationId = null;
    _webConfirmationResult = null;
    _error = null;
    _setLoading(false);
  }

  Future<bool> updateUserProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    if (_user == null) return false;

    _user = _user!.copyWith(name: name, phone: phone, address: address);
    notifyListeners();
    return true;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _finishSecondFactor() async {
    final firebaseUser = _firebaseAuth.currentUser;
    _user = firebaseUser != null
        ? _fromFirebaseUser(firebaseUser)
        : User(
            id: _pendingEmail.hashCode,
            name: _pendingEmail!.split('@').first,
            email: _pendingEmail!,
          );
    _isAuthenticated = true;
    _isAwaitingSecondFactor = false;
    _pendingEmail = null;
    _verificationId = null;
    _webConfirmationResult = null;
    _error = null;
    notifyListeners();
  }

  User _fromFirebaseUser(firebase_auth.User firebaseUser) {
    final email = firebaseUser.email ?? _pendingEmail ?? '';
    return User(
      id: firebaseUser.uid.hashCode,
      name: firebaseUser.displayName ?? email.split('@').first,
      email: email,
      profilePicture: firebaseUser.photoURL,
      phone: firebaseUser.phoneNumber,
    );
  }

  bool _isStudentEmail(String email) {
    return studentEmailPattern.hasMatch(email.trim().toLowerCase());
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    _isLoading = false;
    notifyListeners();
  }

  String _friendlyFirebaseError(firebase_auth.FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Use a stronger password.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'invalid-verification-code':
        return 'The 2FA code is incorrect.';
      case 'invalid-phone-number':
        return 'Enter a valid phone number with country code.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }
}
