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

  Future<List<String>> getDoneRoutes(String userId) async {
    try {
      final querySnapshot = await firestore
        .collection('doneRoutes')
        .where('userId', isEqualTo: userId)
        .get();

      final routes = querySnapshot.docs
        .map((doc) => doc.data()['routeId'] as String)
        .toList();

      return routes;
    } catch (e) {
      _logger.severe('Error fetching done routes: $e');
      return [];
    }
  }

  Future<void> addDoneRoute(String userId, String routeId, Duration timeSpent) async {
    try {
      final doneRoutesRef = firestore.collection('doneRoutes');

      // Check if this route is already marked as done
      final existing = await doneRoutesRef
          .where('userId', isEqualTo: userId)
          .where('routeId', isEqualTo: routeId)
          .get();
      
      if (existing.docs.isEmpty) {
        await doneRoutesRef.add({
          'userId': userId,
          'routeId': routeId,
          'duration': timeSpent.inSeconds,
        });
        _logger.info("Route $routeId added for user $userId");
      } else {
        _logger.info("Route $routeId already marked as done for user $userId");
      }
      } catch (e) {
      _logger.severe("Error adding done route: $e");
    }
  }

  //get de la duration de una doneRoute
  Future<Duration?> getRouteDuration(String userId, String routeId) async {
    try {
      final doneRoutesRef = firestore.collection('doneRoutes');

      final snapshot = await doneRoutesRef
          .where('userId', isEqualTo: userId)
          .where('routeId', isEqualTo: routeId)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final int timeInSeconds = data['duration'];

        return Duration(seconds: timeInSeconds);
      } else {
        _logger.info('No duration found for route $routeId and user $userId');
        return null;
      }
    } catch (e) {
      _logger.severe('Error fetching route duration: $e');
      return null;
    }
  }

}
