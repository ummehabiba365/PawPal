// Dummy classes for Web compatibility
class GoogleMap {
  GoogleMap({dynamic mapType, dynamic initialCameraPosition, dynamic markers, bool? zoomControlsEnabled, bool? scrollGesturesEnabled, bool? rotateGesturesEnabled, bool? tiltGesturesEnabled, bool? myLocationButtonEnabled});
}
class MapType { static var normal; }
class CameraPosition {
  CameraPosition({required dynamic target, required double zoom});
}
class LatLng {
  final double latitude;
  final double longitude;
  LatLng(this.latitude, this.longitude);
}
class Marker {
  Marker({required MarkerId markerId, required LatLng position});
}
class MarkerId {
  MarkerId(String id);
}
