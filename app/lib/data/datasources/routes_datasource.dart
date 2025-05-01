import 'package:app/domain/models/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

class FirebaseRoutesDatasource {
  final FirebaseFirestore firestore;

  FirebaseRoutesDatasource(this.firestore);

  final Logger _logger = Logger('FirebaseRoutesDatasource');

  Future<List<RouteData?>> getAllRoutesData() async {
    try {
      QuerySnapshot snapshot = await firestore.collection('routes').get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return RouteData.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      _logger.severe('Error fetching routes: $e');
      return [];
    }
  }

  Future<RouteData?> getRouteData(String routeId) async {
    try {
      final doc = await firestore.collection('routes').doc(routeId).get();
      if (!doc.exists) return null;
      return RouteData.fromMap(doc.data()!, doc.id);
    } catch (e) {
      _logger.severe('Error fetching route: $e');
      return null;
    }
  }
}
