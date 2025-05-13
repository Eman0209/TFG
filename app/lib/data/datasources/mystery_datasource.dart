import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';
import 'package:app/domain/models/steps.dart';

class FirebaseMysteryDatasource {
  final FirebaseFirestore firestore;

  FirebaseMysteryDatasource(this.firestore);

  final Logger _logger = Logger('FirebaseMysteryDatasource');

  Future<List<StepData>> getCompletedSteps(String mysteryId) async {
    try {
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

  Future<String?> getIntroduction(String mysteryId) async {
    try {
      final doc = await firestore.collection('mystery').doc(mysteryId).get();
      if (doc.exists && doc.data()!.containsKey('introduction')) {
        return doc['introduction'] as String;
      } else {
        _logger.severe('Mystery not found or no introduction');
        return null;
      }
    } catch (e) {
      _logger.severe('Error fetching introduction: $e');
      return null;
    }
  }

}
