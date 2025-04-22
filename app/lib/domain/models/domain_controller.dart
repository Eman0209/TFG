import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/domain/models/routes.dart';

// Clase per a conectar amb el back
class DomainController {

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Create an instance of GoogleSignIn
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // User canceled the sign-in

      // Obtain authentication details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a credential from the Google account details
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Use the credential to sign in to Firebase
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Google sign-in failed: $e');
      return null;
    }
  }

  void createUser(User? user, String username) async {
    if (user != null) {
      // Reference to the "users" collection
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Check if user already exists
      final userDoc = await userDocRef.get();
      if (!userDoc.exists) {
        // Create a new document with user info
        await userDocRef.set({
          'uid': user.uid,
          'email': user.email,
          'name': username,
          'routes': []
        });
      }
    }
  }

  void editUsername(User? user, String username) async {
    if (user != null) {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      final userDoc = await userDocRef.get();
      if (userDoc.exists) {
        // Update only the 'name' field
        await userDocRef.update({
          'name': username,
        });
      } else {
        // Optionally: handle the case where the user doesn't exist
        print("User document does not exist. Can't update username.");
      }
    }
  }

  Future<bool> accountExists(User? user) async {
    if (user == null) return false;
    
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return doc.exists;
  }

  /*
  Future<bool> usernameUnique(String username) async {
    final respuesta = await http.get(Uri.parse(
        'https://culturapp-back.onrender.com/users/uniqueUsername?username=${username}'));

    if (respuesta.statusCode == 200) {
      print(respuesta);
      return (respuesta.body == "unique");
    } else {
      throw Exception('Fallo la obtención de datos');
    }
  }
  */

  Future<List<Map<String, dynamic>>> getTrophies() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('trophy').get();

      final trophies = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'name': data['name'] ?? '',
          'description': data['description'] ?? '',
          'image': data['image'] ?? '',
        };
      }).toList();

      return trophies;
    } catch (e) {
      print('Error getting trophies: $e');
      return [];
    }
  }

  //faltaria un get trophies user


  // get of a route in de bbdd
  Future<RouteData?> getRouteData(String routeId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('routes').doc(routeId).get();
      if (!doc.exists) return null;
      return RouteData.fromMap(doc.data()!);
    } catch (e) {
      print('Error fetching route: $e');
      return null;
    }
  }

}