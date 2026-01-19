import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

abstract class FirebaseAuthService {
  Future<User> signInWithEmail(String email, String password);
  Future<User> signUpWithEmail(String name, String email, String password);
  Future<User> signInWithGoogle();
  Future<User> signInWithFacebook();
  Future<void> signOut();
  User? getCurrentUser();
}

class FirebaseAuthServiceImpl implements FirebaseAuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;

  FirebaseAuthServiceImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required FacebookAuth facebookAuth,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn,
        _facebookAuth = facebookAuth;

  @override
  Future<User> signInWithEmail(String email, String password) async {
    try {
      print('DEBUG AUTH SERVICE: Signing in with email: $email');
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('DEBUG AUTH SERVICE: Sign in successful. User: ${userCredential.user?.uid}');
      print('DEBUG AUTH SERVICE: User email: ${userCredential.user?.email}');

      if (userCredential.user == null) {
        throw Exception('User is null after sign in');
      }

      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      print('DEBUG AUTH SERVICE: FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      print('DEBUG AUTH SERVICE: General exception: $e');
      rethrow;
    }
  }

  @override
  Future<User> signUpWithEmail(String name, String email, String password) async {
    try {
      print('DEBUG AUTH SERVICE: Signing up with email: $email, name: $name');
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('DEBUG AUTH SERVICE: Sign up successful. User: ${userCredential.user?.uid}');

      if (userCredential.user == null) {
        throw Exception('User is null after sign up');
      }

      await userCredential.user!.updateDisplayName(name);
      await userCredential.user!.reload();

      final updatedUser = _firebaseAuth.currentUser;
      print('DEBUG AUTH SERVICE: Updated user: ${updatedUser?.uid}, name: ${updatedUser?.displayName}');

      return updatedUser!;
    } on FirebaseAuthException catch (e) {
      print('DEBUG AUTH SERVICE: FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      print('DEBUG AUTH SERVICE: General exception: $e');
      rethrow;
    }
  }

  @override
  Future<User> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in aborted');
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await _firebaseAuth.signInWithCredential(credential);
      return userCredential.user!;
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  @override
  Future<User> signInWithFacebook() async {
    try {
      final LoginResult result = await _facebookAuth.login();

      if (result.status != LoginStatus.success) {
        throw Exception('Facebook sign in failed');
      }

      final OAuthCredential credential =
      FacebookAuthProvider.credential(result.accessToken!.tokenString);

      final userCredential =
      await _firebaseAuth.signInWithCredential(credential);
      return userCredential.user!;
    } catch (e) {
      throw Exception('Failed to sign in with Facebook: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
      _facebookAuth.logOut(),
    ]);
  }

  @override
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email');
      case 'wrong-password':
        return Exception('Incorrect password');
      case 'email-already-in-use':
        return Exception('An account already exists with this email');
      case 'invalid-email':
        return Exception('Invalid email address');
      case 'weak-password':
        return Exception('Password is too weak');
      default:
        return Exception('Authentication failed: ${e.message}');
    }
  }
}