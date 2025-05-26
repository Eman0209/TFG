import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

class FirebaseRewardsDatasource {
  final FirebaseFirestore firestore;

  FirebaseRewardsDatasource(this.firestore);

  final Logger _logger = Logger('FirebaseRoutesDatasource');

  Future<List<Map<String, dynamic>>> getTrophies(String language) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('trophy').get();

      final langKey = language.toLowerCase();

      final trophies = querySnapshot.docs.map((doc) {
        final data = doc.data();

        final nameKey = data.containsKey('name_$langKey') ? 'name_$langKey' : 'name';
        final descriptionKey = data.containsKey('description_$langKey') ? 'description_$langKey' : 'description';

        return {
          'id': doc.id,
          'name': data[nameKey] ?? '',
          'description': data[descriptionKey] ?? '',
          'image': data['image'] ?? '',
        };
      }).toList();

      return trophies;
    } catch (e) {
      _logger.severe('Error getting trophies: $e');
      return [];
    }
  }

  Future<List<String>> getMyOwnTrophies(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('myOwnTrophies')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => doc['trophyId'] as String)
          .toList();
    } catch (e) {
      _logger.severe('Error fetching user trophies: $e');
      return [];
    }
  }

  Future<void> addUserTrophy(String userId, String trophyId) async {
    try {
      final userTrophyRef = firestore.collection('myOwnTrophies');

      final existing = await userTrophyRef
          .where('userId', isEqualTo: userId)
          .where('trophyId', isEqualTo: trophyId)
          .get();

      if (existing.docs.isEmpty) {
        await userTrophyRef.add({
          'userId': userId,
          'trophyId': trophyId
        });
        _logger.info('Trophy $trophyId added for user $userId.');
      } else {
        _logger.info('Trophy $trophyId already exists for user $userId.');
      }
    } catch (e) {
      _logger.severe('Error adding user trophy: $e');
    }
  }

}
