import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomGoogleMap extends StatelessWidget {
  final LatLng currentPosition;
  final Set<Polyline> polylines;
  final void Function(LatLng tappedPoint, LatLng? selectedPoint)? onPolylineTap;
  final Completer<GoogleMapController> mapControllerCompleter;

  const CustomGoogleMap({
    super.key,
    required this.currentPosition,
    required this.polylines,
    required this.mapControllerCompleter,
    this.onPolylineTap,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (controller) => mapControllerCompleter.complete(controller),
      initialCameraPosition: CameraPosition(
        target: currentPosition,
        zoom: 16,
      ),
      markers: {
        Marker(
          markerId: MarkerId("_currentLocation"),
          icon: BitmapDescriptor.defaultMarker,
          position: currentPosition,
        ),
      },
      polylines: polylines,
      onTap: (LatLng tappedPoint) {
        bool isNearPolyline = false;
        LatLng? selectedPoint;

        for (Polyline polyline in polylines) {
          for (LatLng point in polyline.points) {
            final distance = Geolocator.distanceBetween(
              tappedPoint.latitude,
              tappedPoint.longitude,
              point.latitude,
              point.longitude,
            );
            if (distance < 50) {
              isNearPolyline = true;
              selectedPoint = point;
              break;
            }
          }
          if (isNearPolyline) break;
        }

        if (onPolylineTap != null) {
          onPolylineTap!(tappedPoint, isNearPolyline ? selectedPoint : null);
        }
      },
    );
  }
}