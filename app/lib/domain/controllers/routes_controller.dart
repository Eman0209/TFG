import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;
import 'package:app/consts.dart';
import 'package:app/domain/models/routes.dart';
import 'package:app/data/datasources/routes_datasource.dart';

// Clase per a conectar amb el back
class RoutesController {

  final FirebaseRoutesDatasource datasource;

  RoutesController(this.datasource);

  final Logger _logger = Logger('RoutesController');

  // get all routes
  Future<List<RouteData?>> fetchAllRoutesData(String language) async {
    return await datasource.getAllRoutesData(language);
  }

  // get of a route in de bbdd
  Future<RouteData?> fetchRouteData(String routeId, String language) async {
    return await datasource.getRouteData(routeId, language);
  }

  // Donde irian estas funciones?
  Future<List<LatLng>> getRouteCoordinatesFromNames(List<String> names) async {
    List<LatLng> coords = [];
    for (String name in names) {
      //final coord = await getLatLngFromAddress(name);
      final coord = await getLatLngFromGoogle(name, apiKey);
      if (coord != null) coords.add(coord);
    }
    return coords;
  }

  Future<LatLng?> getLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations[0].latitude, locations[0].longitude);
      } 
    } catch (e) {
      _logger.severe("Geocoding failed: $e");
    }
    return null;
  }

  Future<LatLng?> getLatLngFromGoogle(String address, String apiKey) async {
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$apiKey',
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].length > 0) {
        final location = data['results'][0]['geometry']['location'];
        return LatLng(location['lat'], location['lng']);
      }
    }
    return null;
  }

  Future<List<String>> fetchDoneRoutes(User? user) async {
    return await datasource.getDoneRoutes(user!.uid);
  }

  Future<void> addDoneRoute(User? user, String routeId, Duration timeSpent) async {
    await datasource.addDoneRoute(user!.uid, routeId, timeSpent);
  }

  Future<void> addStardtedRoute(User? user, String routeId) async {
    await datasource.addStardtedRoute(user!.uid, routeId);
  }

  Future<void> deleteStartedRoute(User? user, String routeId) async {
    await datasource.deleteStartedRoute(user!.uid, routeId);
  }

  Future<bool> isRouteStarted(User? user, String routeId) async {
    return await datasource.isRouteStarted(user!.uid, routeId);
  }

  Future<bool> isRouteFinished(User? user, String routeId) async {
    return await datasource.isRouteFinished(user!.uid, routeId);
  }
  
  Future<Duration?> fetchStartedRouteDuration(User? user, String routeId) async {
    return await datasource.getStartedRouteDuration(user!.uid, routeId);
  }

   Future<void> updateStartedRouteDuration(User? user, String routeId, Duration newDuration) async {
    await datasource.updateStartedRouteDuration(user!.uid, routeId, newDuration);
  }

  Future<Duration?> fetchRouteDuration(User? user, String routeId) async {
    return await datasource.getRouteDuration(user!.uid, routeId);
  }

}