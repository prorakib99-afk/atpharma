import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/location/google_geocoding_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/storage_keys.dart';

class AddressMapPickerResult {
  const AddressMapPickerResult(this.address, this.position);
  final String address;
  final LatLng position;
}

class AddressMapPickerScreen extends StatefulWidget {
  const AddressMapPickerScreen({super.key});
  @override
  State<AddressMapPickerScreen> createState() => _AddressMapPickerScreenState();
}

class _AddressMapPickerScreenState extends State<AddressMapPickerScreen> {
  static const _fallback = LatLng(23.8103, 90.4125);
  final _geocoder = GoogleGeocodingService();
  final MapController _controller = MapController();
  LatLng _position = _fallback;
  String _address = 'Move the map to choose your address';
  bool _locating = true;
  bool _resolving = false;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    final LocalStorageService storage = sl<LocalStorageService>();
    final double? latitude = storage.readDouble(StorageKeys.lastKnownLatitude);
    final double? longitude = storage.readDouble(
      StorageKeys.lastKnownLongitude,
    );
    if (latitude != null && longitude != null) {
      _position = LatLng(latitude, longitude);
      _locating = false;
    }
    unawaited(_useCurrentLocation());
  }

  Future<void> _useCurrentLocation() async {
    if (mounted) setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _message('Turn on location to find where you are.');
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _message('Location permission is required.');
        return;
      }
      final value = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      _position = LatLng(value.latitude, value.longitude);
      _controller.move(_position, 17);
      await _resolve(_position);
    } catch (_) {
      _message('Could not get your current location.');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _resolve(LatLng value) async {
    final request = ++_request;
    if (mounted) setState(() => _resolving = true);
    String? address = await _geocoder.reverseGeocode(
      latitude: value.latitude,
      longitude: value.longitude,
    );
    if (address == null) {
      try {
        final places = await Geocoding().placemarkFromCoordinates(
          value.latitude,
          value.longitude,
        );
        if (places.isNotEmpty) {
          final p = places.first;
          address =
              <String>[
                    p.street ?? '',
                    p.subLocality ?? '',
                    p.locality ?? '',
                    p.administrativeArea ?? '',
                    p.country ?? '',
                  ]
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toSet()
                  .take(4)
                  .join(', ');
        }
      } catch (_) {}
    }
    if (!mounted || request != _request) return;
    setState(() {
      _address = address?.trim().isNotEmpty == true
          ? address!.trim()
          : '${value.latitude.toStringAsFixed(5)}, ${value.longitude.toStringAsFixed(5)}';
      _resolving = false;
    });
  }

  void _message(String value) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(value)));
    }
  }

  void _selectPosition(LatLng value) {
    setState(() => _position = value);
    unawaited(_resolve(value));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: _position,
            initialZoom: 16,
            maxZoom: 19,
            onTap: (_, LatLng point) => _selectPosition(point),
          ),
          children: <Widget>[
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.atpharma',
              maxNativeZoom: 19,
            ),
            DragMarkers(
              markers: <DragMarker>[
                DragMarker(
                  point: _position,
                  size: const Size.square(64),
                  offset: const Offset(0, -22),
                  dragOffset: const Offset(0, -28),
                  builder: (_, _, bool isDragging) => Icon(
                    isDragging
                        ? Icons.edit_location_rounded
                        : Icons.location_on_rounded,
                    color: const Color(0xFF079BE5),
                    size: isDragging ? 62 : 54,
                  ),
                  onDragEnd: (_, LatLng point) => _selectPosition(point),
                  scrollMapNearEdge: true,
                ),
              ],
            ),
            const RichAttributionWidget(
              attributions: <SourceAttribution>[
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MapButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(22)),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 12),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                    child: Text(
                      'Choose delivery location',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                _MapButton(
                  icon: Icons.my_location_rounded,
                  loading: _locating,
                  onTap: _useCurrentLocation,
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            minimum: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected address',
                    style: TextStyle(fontSize: 12, color: Color(0xFF667085)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF079BE5),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _resolving
                            ? const LinearProgressIndicator(minHeight: 2)
                            : Text(
                                _address,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: _resolving
                          ? null
                          : () {
                              final LocalStorageService storage =
                                  sl<LocalStorageService>();
                              unawaited(
                                storage.write<double>(
                                  key: StorageKeys.lastKnownLatitude,
                                  value: _position.latitude,
                                ),
                              );
                              unawaited(
                                storage.write<double>(
                                  key: StorageKeys.lastKnownLongitude,
                                  value: _position.longitude,
                                ),
                              );
                              Navigator.pop(
                                context,
                                AddressMapPickerResult(_address, _position),
                              );
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF079BE5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: const Text('Confirm location'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.icon,
    required this.onTap,
    this.loading = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool loading;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: const CircleBorder(),
    elevation: 3,
    child: InkWell(
      onTap: loading ? null : onTap,
      customBorder: const CircleBorder(),
      child: SizedBox.square(
        dimension: 46,
        child: loading
            ? const Padding(
                padding: EdgeInsets.all(13),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, color: const Color(0xFF101828)),
      ),
    ),
  );
}
