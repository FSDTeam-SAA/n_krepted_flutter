import 'package:flutter/material.dart';
import '../../core/widgets/bottom_action_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/network/api_client.dart';

class RestaurantLocationSelection {
  final double latitude, longitude;
  final String address, city, country, displayName;
  const RestaurantLocationSelection({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.country,
    required this.displayName,
  });
}

class RestaurantLocationPickerScreen extends StatefulWidget {
  final double? initialLatitude, initialLongitude;
  final String initialAddress, initialCity, initialCountry;
  final bool hasInitialSelection;
  const RestaurantLocationPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress = '',
    this.initialCity = '',
    this.initialCountry = '',
    this.hasInitialSelection = false,
  });
  @override
  State<RestaurantLocationPickerScreen> createState() => _PickerState();
}

class _PickerState extends State<RestaurantLocationPickerScreen> {
  final _search = TextEditingController();
  GoogleMapController? _map;
  RestaurantLocationSelection? _selection;
  List<Map<String, dynamic>> _results = [];
  bool _busy = false;
  String? _error;
  int _request = 0;
  static const _enabled = bool.fromEnvironment('GOOGLE_MAPS_ENABLED');
  @override
  void initState() {
    super.initState();
    if (widget.hasInitialSelection &&
        widget.initialLatitude != null &&
        widget.initialLongitude != null) {
      _selection = RestaurantLocationSelection(
        latitude: widget.initialLatitude!,
        longitude: widget.initialLongitude!,
        address: widget.initialAddress,
        city: widget.initialCity,
        country: widget.initialCountry,
        displayName: widget.initialAddress,
      );
    }
  }

  Future<void> _query({LatLng? point}) async {
    if (point == null && _search.text.trim().isEmpty) return;
    final request = ++_request;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final response = await ApiClient().get(
        '/maps/geocode',
        queryParameters: point == null
            ? {'address': _search.text.trim()}
            : {'latlng': '${point.latitude},${point.longitude}'},
      );
      if (!mounted || request != _request) return;
      final rows = (response.data['data'] as List)
          .map((v) => Map<String, dynamic>.from(v))
          .toList();
      if (point != null) {
        _choose(
          rows.isEmpty
              ? {'latitude': point.latitude, 'longitude': point.longitude}
              : {
                  ...rows.first,
                  'latitude': point.latitude,
                  'longitude': point.longitude,
                },
        );
      } else {
        setState(() {
          _results = rows;
          if (rows.isEmpty) _error = 'Kein Standort gefunden.';
        });
      }
    } catch (_) {
      if (mounted && request == _request) {
        if (point != null) {
          _choose({'latitude': point.latitude, 'longitude': point.longitude});
        }
        setState(
          () => _error =
              'Adresse konnte nicht geladen werden. Sie können Koordinaten bestätigen und die Adresse im Formular ergänzen.',
        );
      }
    } finally {
      if (mounted && request == _request) setState(() => _busy = false);
    }
  }

  void _choose(Map<String, dynamic> row) {
    final selection = RestaurantLocationSelection(
      latitude: (row['latitude'] as num).toDouble(),
      longitude: (row['longitude'] as num).toDouble(),
      address: row['address']?.toString() ?? '',
      city: row['city']?.toString() ?? '',
      country: row['country']?.toString() ?? '',
      displayName: row['address']?.toString() ?? '',
    );
    setState(() {
      _selection = selection;
      _results = [];
    });
    _map?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(selection.latitude, selection.longitude),
        16,
      ),
    );
  }

  Future<void> _locate() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) throw Exception();
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if ([
        LocationPermission.denied,
        LocationPermission.deniedForever,
      ].contains(permission)) {
        throw Exception();
      }
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          timeLimit: Duration(seconds: 20),
        ),
      );
      if (mounted) await _query(point: LatLng(p.latitude, p.longitude));
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _error = 'Bitte Standortdienste und Standortberechtigung prüfen.',
        );
      }
    }
  }

  @override
  void dispose() {
    ++_request;
    _map?.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final point = _selection == null
        ? const LatLng(51.1657, 10.4515)
        : LatLng(_selection!.latitude, _selection!.longitude);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Standort auf Google Maps'),
        actions: [
          IconButton(
            onPressed: _busy ? null : _locate,
            icon: const Icon(Icons.my_location),
            tooltip: 'Mein Standort',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _search,
              onSubmitted: (_) => _query(),
              decoration: InputDecoration(
                hintText: 'Adresse oder Restaurant suchen',
                suffixIcon: IconButton(
                  onPressed: _busy ? null : () => _query(),
                  icon: const Icon(Icons.search),
                ),
              ),
            ),
          ),
          if (_busy) const LinearProgressIndicator(),
          if (_error != null)
            Padding(padding: const EdgeInsets.all(12), child: Text(_error!)),
          for (final r in _results)
            ListTile(
              title: Text(r['address'].toString()),
              onTap: () => _choose(r),
            ),
          Expanded(
            child: _enabled
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: point,
                      zoom: 13,
                    ),
                    onMapCreated: (m) => _map = m,
                    onTap: (p) => _query(point: p),
                    markers: {
                      if (_selection != null)
                        Marker(
                          markerId: const MarkerId('selected'),
                          position: point,
                          draggable: true,
                          onDragEnd: (p) => _query(point: p),
                        ),
                    },
                  )
                : const Center(
                    child: Text('Die Karte ist momentan nicht verfügbar.'),
                  ),
          ),
          if (_selection != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '${_selection!.displayName}\n${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}',
                textAlign: TextAlign.center,
              ),
            ),
          BottomActionBar(
            child: FilledButton(
              onPressed: _selection == null || _busy
                  ? null
                  : () => Navigator.pop(context, _selection),
              child: const Text('Standort bestätigen'),
            ),
          ),
        ],
      ),
    );
  }
}
