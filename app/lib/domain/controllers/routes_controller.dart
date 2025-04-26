import 'package:app/domain/models/routes.dart';
import 'package:app/data/datasources/routes_datasource.dart';

// Clase per a conectar amb el back
class RoutesController {

  final FirebaseRoutesDatasource datasource;

  RoutesController(this.datasource);

  // get of a route in de bbdd
  Future<RouteData?> fetchRouteData(String routeId) async {
    return await datasource.getRouteData(routeId);
  }

}