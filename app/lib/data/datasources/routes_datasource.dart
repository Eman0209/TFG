import 'package:app/domain/models/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseRoutesDatasource {
  final FirebaseFirestore firestore;

  FirebaseRoutesDatasource(this.firestore);

  Future<RouteData?> getRouteData(String routeId) async {
    try {
      final doc = await firestore.collection('routes').doc(routeId).get();
      if (!doc.exists) return null;
      return RouteData.fromMap(doc.data()!);
    } catch (e) {
      print('Error fetching route: $e');
      return null;
    }
  }
}
