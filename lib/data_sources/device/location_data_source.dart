import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String? address;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    this.address,
  });
}

/// Wraps geolocator (coordinates) + geocoding (reverse lookup to a
/// human-readable address, best-effort).
class LocationDataSource {
  final Geocoding _geocoding = Geocoding();

  Future<bool> hasPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return false;
    if (permission == LocationPermission.denied) return false;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    return serviceEnabled;
  }

  /// Returns null if permission/service is unavailable or the fix fails.
  Future<LocationResult?> getCurrentLocation() async {
    final granted = await hasPermission();
    if (!granted) return null;

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    String? address;
    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        address = [p.street, p.locality, p.administrativeArea, p.country]
            .where((part) => part != null && part.isNotEmpty)
            .join(', ');
      }
    } catch (_) {
      // Reverse geocoding is best-effort — coordinates alone are enough
      // to satisfy the "store location" requirement.
    }

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      address: address,
    );
  }
}
