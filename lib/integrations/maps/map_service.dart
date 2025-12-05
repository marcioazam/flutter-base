import 'package:flutter/widgets.dart';

import 'package:flutter_base_2025/core/utils/result.dart';

/// Map provider type.
enum MapProvider { google, mapbox }

/// Geographic coordinates.
class LatLng {

  const LatLng(this.latitude, this.longitude);

  factory LatLng.fromJson(Map<String, dynamic> json) => LatLng(
      (json['latitude'] as num).toDouble(),
      (json['longitude'] as num).toDouble(),
    );
  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LatLng &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() => 'LatLng($latitude, $longitude)';

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}

/// Map marker configuration.
class MapMarker {

  const MapMarker({
    required this.id,
    required this.position,
    this.title,
    this.snippet,
    this.iconAsset,
    this.onTap,
  });
  final String id;
  final LatLng position;
  final String? title;
  final String? snippet;
  final String? iconAsset;
  final void Function()? onTap;
}

/// Map polyline configuration.
class MapPolyline {

  const MapPolyline({
    required this.id,
    required this.points,
    this.color = const Color(0xFF0000FF),
    this.width = 3.0,
  });
  final String id;
  final List<LatLng> points;
  final Color color;
  final double width;
}

/// Map configuration.
class MapConfig {

  const MapConfig({
    required this.initialCenter,
    this.initialZoom = 14.0,
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = false,
    this.zoomControlsEnabled = true,
    this.compassEnabled = true,
  });
  final LatLng initialCenter;
  final double initialZoom;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final bool zoomControlsEnabled;
  final bool compassEnabled;
}

/// Abstract map service interface.
abstract interface class MapService {
  /// Initializes the map service.
  Future<Result<void>> initialize();

  /// Builds a map widget.
  Widget buildMap({
    required MapConfig config,
    List<MapMarker> markers = const [],
    List<MapPolyline> polylines = const [],
    void Function(LatLng)? onTap,
    void Function(LatLng)? onCameraMove,
  });

  /// Gets a route between two points.
  Future<Result<List<LatLng>>> getRoute(LatLng from, LatLng to);

  /// Calculates distance between two points in meters.
  double calculateDistance(LatLng from, LatLng to);
}

/// Google Maps implementation.
/// Note: Requires google_maps_flutter package.
class GoogleMapService implements MapService {
  @override
  Future<Result<void>> initialize() async {
    // Placeholder - requires google_maps_flutter package
    return const Success(null);
  }

  @override
  Widget buildMap({
    required MapConfig config,
    List<MapMarker> markers = const [],
    List<MapPolyline> polylines = const [],
    void Function(LatLng)? onTap,
    void Function(LatLng)? onCameraMove,
  }) {
    // Placeholder - requires google_maps_flutter package
    // return GoogleMap(
    //   initialCameraPosition: CameraPosition(
    //     target: google_maps.LatLng(
    //       config.initialCenter.latitude,
    //       config.initialCenter.longitude,
    //     ),
    //     zoom: config.initialZoom,
    //   ),
    //   markers: markers.map((m) => Marker(...)).toSet(),
    //   polylines: polylines.map((p) => Polyline(...)).toSet(),
    //   onTap: onTap != null ? (pos) => onTap(LatLng(pos.latitude, pos.longitude)) : null,
    //   myLocationEnabled: config.myLocationEnabled,
    //   myLocationButtonEnabled: config.myLocationButtonEnabled,
    //   zoomControlsEnabled: config.zoomControlsEnabled,
    //   compassEnabled: config.compassEnabled,
    // );

    return const Center(child: Text('Google Maps placeholder'));
  }

  @override
  Future<Result<List<LatLng>>> getRoute(LatLng from, LatLng to) async {
    // Placeholder - requires Google Directions API
    return const Success([]);
  }

  @override
  double calculateDistance(LatLng from, LatLng to) {
    // Haversine formula
    const earthRadius = 6371000.0; // meters
    final dLat = _toRadians(to.latitude - from.latitude);
    final dLon = _toRadians(to.longitude - from.longitude);

    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(from.latitude)) *
            _cos(_toRadians(to.latitude)) *
            _sin(dLon / 2) *
            _sin(dLon / 2);

    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * 3.141592653589793 / 180;
  double _sin(double x) => _taylorSin(x);
  double _cos(double x) => _taylorSin(x + 3.141592653589793 / 2);
  double _sqrt(double x) => _newtonSqrt(x);
  double _atan2(double y, double x) => _approximateAtan2(y, x);

  double _taylorSin(double x) {
    // Normalize to [-pi, pi]
    while (x > 3.141592653589793) {
      x -= 2 * 3.141592653589793;
    }
    while (x < -3.141592653589793) {
      x += 2 * 3.141592653589793;
    }
    // Taylor series approximation
    final x2 = x * x;
    return x * (1 - x2 / 6 * (1 - x2 / 20 * (1 - x2 / 42)));
  }

  double _newtonSqrt(double x) {
    if (x <= 0) return 0;
    var guess = x / 2;
    for (var i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  double _approximateAtan2(double y, double x) {
    if (x == 0) return y > 0 ? 1.5707963267948966 : -1.5707963267948966;
    final atan = _approximateAtan(y / x);
    if (x > 0) return atan;
    return y >= 0 ? atan + 3.141592653589793 : atan - 3.141592653589793;
  }

  double _approximateAtan(double x) {
    // Approximation for atan
    if (x.abs() > 1) {
      return (x > 0 ? 1 : -1) * 1.5707963267948966 - _approximateAtan(1 / x);
    }
    return x - x * x * x / 3 + x * x * x * x * x / 5;
  }
}

/// Mapbox implementation placeholder.
/// Note: Requires mapbox_gl package.
class MapboxService implements MapService {
  @override
  Future<Result<void>> initialize() async => const Success(null);

  @override
  Widget buildMap({
    required MapConfig config,
    List<MapMarker> markers = const [],
    List<MapPolyline> polylines = const [],
    void Function(LatLng)? onTap,
    void Function(LatLng)? onCameraMove,
  }) => const Center(child: Text('Mapbox placeholder'));

  @override
  Future<Result<List<LatLng>>> getRoute(LatLng from, LatLng to) async => const Success([]);

  @override
  double calculateDistance(LatLng from, LatLng to) => GoogleMapService().calculateDistance(from, to);
}

/// Map service factory.
MapService createMapService(MapProvider provider) => switch (provider) {
    MapProvider.google => GoogleMapService(),
    MapProvider.mapbox => MapboxService(),
  };
