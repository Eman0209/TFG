import 'package:app/data/datasources/user_datasource.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Clase per a conectar amb el back
class UserController {

  final FirebaseUserDatasource datasource;

  UserController(this.datasource);

  Future<UserCredential?> signInWithGoogle() async {
    return await datasource.signInWithGoogle();
  }

  Future<void> createUser(User? user, String username) async {
    await datasource.createUser(user!, username);
  }

  Future<void> editUsername(User? user, String username) async {
    await datasource.editUsername(user!, username);
  }

  Future<bool> accountExists(User? user) async {
    return await datasource.accountExists(user!);
  }

}