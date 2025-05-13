import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';

class FirebaseUserDatasource {

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  FirebaseUserDatasource({
    required this.auth,
    required this.firestore,
  });

  final Logger _logger = Logger('FirebaseUserDatasource');

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
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
        'routes': [],
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

  Future<List<String>> getRoutes(User user) async {
    try {
      final doc = await firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['routes'] is List) {
          return List<String>.from(data['routes']);
        } else {
          _logger.severe('Routes field is missing or not a list');
          return [];
        }
      } else {
        _logger.severe('User document not found');
        return [];
      }
    } catch (e) {
      _logger.severe('Error fetching routes: $e');
      return [];
    }
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

  Future<void> addDoneRoute(User user, String routeId) async {
    final userDocRef = firestore.collection('users').doc(user.uid);
    final userDoc = await userDocRef.get();

    if (userDoc.exists) {
      await userDocRef.update({
        'routes': FieldValue.arrayUnion([routeId]),
      });
    } else {
      _logger.severe("User document does not exist. Can't update routes.");
    }
  }
  
}
