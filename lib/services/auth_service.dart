import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Creates the Firebase Auth account AND the matching Firestore user
  /// document (which is where role, fullName etc. actually live).
  /// Firebase Authentication itself only ever stores auth fields
  /// (email/uid/provider) — it will never show "role" in its console,
  /// that's expected. Role lives in Firestore under users/{uid}.
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Also set the display name so it's at least visible in the Firebase
    // Auth console, even though role itself is a Firestore-only field.
    await cred.user!.updateDisplayName(fullName);

    final user = UserModel(
      uid: cred.user!.uid,
      email: email,
      fullName: fullName,
      role: role,
    );

    // set() with the uid as the doc id guarantees this write completes
    // (and is awaited) before signUp() returns, so by the time the UI
    // reacts to the new auth state, the role document already exists.
    await _firestore.collection('users').doc(cred.user!.uid).set(user.toMap());
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<UserModel?> userDocStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromFirestore(doc.data()!, doc.id);
    });
  }
}
