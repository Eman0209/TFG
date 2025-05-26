import 'package:app/data/datasources/mystery_datasource.dart';
import 'package:app/domain/models/steps.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Clase per a conectar amb el back
class MysteryController {

  final FirebaseMysteryDatasource datasource;

  MysteryController(this.datasource);

  Future<StepData?> fetchStepInfo(String mysteryId, int order, String step) async {
    return await datasource.getStepInfo(mysteryId, order, step);
  }

  Future<List<StepData>> fetchCompletedSteps(User user, String mysteryId, String step) async {
    return await datasource.getCompletedSteps(user.uid, mysteryId, step);
  }

  Future<String?> fetchIntroduction(String mysteryId, String language) async {
    return await datasource.getIntroduction(mysteryId, language);
  }

  Future<int> fetchLengthOfSteps(String mysteryId) async {
    return await datasource.getStepsLength(mysteryId);
  }

}