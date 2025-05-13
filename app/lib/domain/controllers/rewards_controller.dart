import 'package:app/data/datasources/rewards_datasource.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Clase per a conectar amb el back
class RewardsController {

  final FirebaseRewardsDatasource datasource;

  RewardsController(this.datasource);

  Future<List<Map<String, dynamic>>> fetchTrophies() async {
    return await datasource.getTrophies();
  }

  Future<List<String>> fetchMyOwnTrophies(User? user) async {
    return await datasource.getMyOwnTrophies(user);
  }


}