import 'package:app/data/datasources/mystery_datasource.dart';
import 'package:app/domain/models/steps.dart';

// Clase per a conectar amb el back
class MysteryController {

  final FirebaseMysteryDatasource datasource;

  MysteryController(this.datasource);

  Future<List<StepData>> fetchCompletedSteps(String mysteryId) async {
    return await datasource.getCompletedSteps(mysteryId);
  }

  Future<String?> fetchIntroduction(String mysteryId) async {
    return await datasource.getIntroduction(mysteryId);
  }

}