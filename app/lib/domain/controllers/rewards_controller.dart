import 'package:app/data/datasources/rewards_datasource.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Clase per a conectar amb el back
class RewardsController {

  final FirebaseRewardsDatasource datasource;

  RewardsController(this.datasource);

  Future<List<Map<String, dynamic>>> fetchTrophies(String language) async {
    return await datasource.getTrophies(language);
  }

  Future<List<String>> fetchMyOwnTrophies(User? user) async {
    return await datasource.getMyOwnTrophies(user!.uid);
  }

  Future<void> addUserTrophy(User? user, String trophyId) async {
    await datasource.addUserTrophy(user!.uid, trophyId);
  }

}