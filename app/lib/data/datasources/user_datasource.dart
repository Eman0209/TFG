import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';

class FirebaseUserDatasource {

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  FirebaseUserDatasource({
    required this.auth,
    required this.firestore,
    required this.googleSignIn,
  });

  final Logger _logger = Logger('FirebaseUserDatasource');

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await auth.signInWithCredential(credential);
    } catch (e) {
      _logger.severe('Google sign-in failed: $e');
      return null;
    }
  }

  Future<void> createUser(User user, String username) async {
    final userDocRef = firestore.collection('users').doc(user.uid);
    final userDoc = await userDocRef.get();

    if (!userDoc.exists) {
      await userDocRef.set({
        'uid': user.uid,
        'email': user.email,
        'name': username,
      });
    }
  }

  Future<void> editUsername(User user, String username) async {
    final userDocRef = firestore.collection('users').doc(user.uid);
    final userDoc = await userDocRef.get();

    if (userDoc.exists) {
      // Update only the 'name' field
      await userDocRef.update({
        'name': username,
      });
    } else {
      _logger.severe("User document does not exist. Can't update username.");
    }
  }

  Future<bool> accountExists(User user) async {
    final doc = await firestore.collection('users').doc(user.uid).get();
    return doc.exists;
  }

  /*
  Future<bool> usernameUnique(String username) async {
    final respuesta = await http.get

    if (respuesta.statusCode == 200) {
      print(respuesta);
      return (respuesta.body == "unique");
    } else {
      throw Exception('Fallo la obtención de datos');
    }
  }
  */
  
}
