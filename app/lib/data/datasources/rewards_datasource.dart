import 'package:cloud_firestore/cloud_firestore.dart';
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

  //faltaria un get trophies user

}
