import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';
import 'package:app/domain/models/steps.dart';

class FirebaseMysteryDatasource {
  final FirebaseFirestore firestore;

  FirebaseMysteryDatasource(this.firestore);

  final Logger _logger = Logger('FirebaseMysteryDatasource');

  Future<List<StepData>> getCompletedSteps(String mysteryId) async {
    try {
      _logger.severe('Entra al get steps');
      QuerySnapshot querySnapshot = await firestore
          .collection('mystery')
          .doc(mysteryId)
          .collection('steps')
          .orderBy('order')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return StepData.fromMap(data);
      }).where((step) => step.completed)
      .toList(); 
    } catch (e) {
      _logger.severe('Error fetching steps: $e');
      return [];
    }
  }

}
