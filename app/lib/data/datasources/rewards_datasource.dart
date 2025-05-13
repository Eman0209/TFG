import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';

class FirebaseRewardsDatasource {
  final FirebaseFirestore firestore;

  FirebaseRewardsDatasource(this.firestore);

  final Logger _logger = Logger('FirebaseRoutesDatasource');

  Future<List<Map<String, dynamic>>> getTrophies() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('trophy').get();

      final trophies = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'description': data['description'] ?? '',
          'image': data['image'] ?? '',
        };
      }).toList();

      return trophies;
    } catch (e) {
      _logger.severe('Error getting trophies: $e');
      return [];
    }
  }

  Future<List<String>> getMyOwnTrophies(User? user) async {
    try {
      final querySnapshot = await firestore
          .collection('myOwnTrophies')
          .where('userId', isEqualTo: user!.uid)
          .get();

      return querySnapshot.docs
          .map((doc) => doc['trophyId'] as String)
          .toList();
    } catch (e) {
      _logger.severe('Error fetching user trophies: $e');
      return [];
    }
  }

}
