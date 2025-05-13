import 'package:app/data/datasources/rewards_datasource.dart';

// Clase per a conectar amb el back
class RewardsController {

  final FirebaseRewardsDatasource datasource;

  RewardsController(this.datasource);

  Future<List<Map<String, dynamic>>> fetchTrophies() async {
    return await datasource.getTrophies();
  }

  //faltaria un get trophies user


}