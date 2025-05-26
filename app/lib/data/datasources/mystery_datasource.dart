import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';
import 'package:app/domain/models/steps.dart';

class FirebaseMysteryDatasource {
  final FirebaseFirestore firestore;

  FirebaseMysteryDatasource(this.firestore);

  final Logger _logger = Logger('FirebaseMysteryDatasource');

  Future<StepData?> getStepInfo(String mysteryId, int order, String step) async {
    try {
      final stepsCollection = firestore
        .collection('mystery')
        .doc(mysteryId)
        .collection(step);
      
      final querySnapshot = await stepsCollection
        .where('order', isEqualTo: order+1)
        .limit(1)
        .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        return StepData.fromMap(data);
      } else {
      _logger.warning('No step found with order $order');
      return null;
    }

    } catch (e) {
      _logger.severe('Error fetching step info: $e');
      return null;
    }
  }

  Future<List<StepData>> getCompletedSteps(String userId, String mysteryId, String step) async {
    try {
      // Get the completed step IDs from the 'doneSteps' collection
      final querySnapshot = await firestore
          .collection('doneSteps')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        _logger.warning('No doneSteps document found for user $userId');
        return [];
      }

      final docData = querySnapshot.docs.first.data();
      final List<dynamic> completedStepIds = docData[step] ?? [];

      if (completedStepIds.isEmpty) return [];

      // Fetch all steps that match the completed step IDs
      final stepsCollection = firestore
        .collection('mystery')
        .doc(mysteryId)
        .collection(step);

      // Get each step by ID
      final futures = completedStepIds.map((stepId) async {
        final doc = await stepsCollection.doc(stepId).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          return StepData.fromMap(data);
        } else {
          return null;
        }
      });

      final results = await Future.wait(futures);

      // Filter out nulls and sort by the 'order' field
      final completedSteps = results
          .whereType<StepData>()
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));

      return completedSteps;
      
    } catch (e) {
      _logger.severe('Error fetching steps: $e');
      return [];
    }
  }

  Future<String?> getIntroduction(String mysteryId,  String language) async {
    try {
      final doc = await firestore.collection('mystery').doc(mysteryId).get();

      if (!doc.exists) {
        _logger.severe('Mystery not found');
        return null;
      }

      final data = doc.data()!;
      final langKey = language.toLowerCase();
      final introKey = data.containsKey('introduction_$langKey')
          ? 'introduction_$langKey'
          : 'introduction'; // fallback

      return data[introKey] as String?;
    } catch (e) {
      _logger.severe('Error fetching introduction: $e');
      return null;
    }
  }

  Future<int> getStepsLength(String mysteryId) async {
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('mystery')
          .doc(mysteryId)
          .collection('steps')
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.size;
      } else {
        _logger.severe('Mystery not found or no introduction');
        return 0;
      }
    } catch (e) {
      _logger.severe('Error fetching introduction: $e');
      return 0;
    }
  }

}
