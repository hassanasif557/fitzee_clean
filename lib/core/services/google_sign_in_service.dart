import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fitzee_new/firebase_options.dart';

/// Google Sign-In with Firebase Auth.
/// Ensure "Google" sign-in provider is enabled in Firebase Console (Authentication > Sign-in method).
/// On Android: add your SHA-1 in Firebase Console (Project settings > Your apps), then re-download google-services.json.
class GoogleSignInService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Web client ID (client_type 3 in google-services.json) – required on Android to get id token for Firebase.
  /// Must match Firebase Console > Authentication > Sign-in method > Google > Web client ID.
  static const String _androidWebClientId =
      '977549736796-nmvdgm1mu0veiksai91kuciuvpa4pvfl.apps.googleusercontent.com';

  /// Configure GoogleSignIn: request idToken for Firebase; use Web client ID on Android.
  static GoogleSignIn _googleSignIn() {
    final serverClientId = defaultTargetPlatform == TargetPlatform.android
        ? _androidWebClientId
        : null;
    return GoogleSignIn(
      serverClientId: serverClientId,
      scopes: ['email'],
    );
  }

  /// Sign in with Google and return Firebase [UserCredential].
  /// Throws on cancel or error.
  static Future<UserCredential> signInWithGoogle() async {
    final googleSignIn = _googleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign-in was cancelled');
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final String? idToken = googleAuth.idToken;
    if (idToken == null) {
      throw Exception('Google sign-in did not return an id token');
    }
    final credential = GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: googleAuth.accessToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  /// Sign out from Google and Firebase (call when user taps Sign out in app).
  static Future<void> signOut() async {
    await _auth.signOut();
    final googleSignIn = _googleSignIn();
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }
  }

  /// Clear Google's cached account so the next sign-in shows the account picker.
  /// Call when the login screen is shown so user can choose which Google account to use.
  static Future<void> clearCachedAccount() async {
    final googleSignIn = _googleSignIn();
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }
    await googleSignIn.disconnect();
  }
}
