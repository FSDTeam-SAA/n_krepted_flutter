import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class RestaurantLocationSelection {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String country;
  final String displayName;

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
  final double initialLatitude;
  final double initialLongitude;
  final String initialAddress;
  final String initialCity;
  final String initialCountry;

  const RestaurantLocationPickerScreen({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
    this.initialAddress = '',
    this.initialCity = '',
    this.initialCountry = '',
  });

  @override
  State<RestaurantLocationPickerScreen> createState() =>
      _RestaurantLocationPickerScreenState();
}

class _RestaurantLocationPickerScreenState
    extends State<RestaurantLocationPickerScreen> {
  static const _geocoderBaseUrl = 'https://nominatim.openstreetmap.org';
  static const _userAgentPackage = 'com.example.n_krepted_flutter';

  final _mapController = MapController();
  final _searchController = TextEditingController();
  final _dio = Dio();

  late LatLng _selectedPoint;
  RestaurantLocationSelection? _selection;
  List<_PlaceCandidate> _searchResults = const [];

  bool _isSearching = false;
  bool _isResolving = false;
  bool _isLocating = false;
  int _reverseRequestId = 0;

  // The public Nominatim service allows at most one request per second.
  Future<void> _geocoderTail = Future<void>.value();
  DateTime? _lastGeocoderRequest;

  @override
  void initState() {
    super.initState();
    _selectedPoint = LatLng(widget.initialLatitude, widget.initialLongitude);

    final initialDisplay = [
      widget.initialAddress,
      widget.initialCity,
      widget.initialCountry,
    ].where((part) => part.trim().isNotEmpty).join(', ');

    _selection = RestaurantLocationSelection(
      latitude: widget.initialLatitude,
      longitude: widget.initialLongitude,
      address: widget.initialAddress,
      city: widget.initialCity,
      country: widget.initialCountry,
      displayName: initialDisplay.isEmpty
          ? _formatCoordinates(_selectedPoint)
          : initialDisplay,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dio.close(force: true);
    super.dispose();
  }

  Future<Response<dynamic>> _getFromGeocoder(
    String path,
    Map<String, dynamic> queryParameters,
  ) {
    final completer = Completer<Response<dynamic>>();

    _geocoderTail = _geocoderTail.then((_) async {
      final previousRequest = _lastGeocoderRequest;
      if (previousRequest != null) {
        final elapsed = DateTime.now().difference(previousRequest);
        const minimumGap = Duration(milliseconds: 1100);
        if (elapsed < minimumGap) {
          await Future<void>.delayed(minimumGap - elapsed);
        }
      }

      try {
        _lastGeocoderRequest = DateTime.now();
        final response = await _dio.get<dynamic>(
          '$_geocoderBaseUrl$path',
          queryParameters: queryParameters,
          options: Options(
            headers: const {
              'User-Agent': 'N-Krepted/1.0 ($_userAgentPackage)',
              'Accept-Language': 'de,en',
            },
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
          ),
        );
        completer.complete(response);
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });

    return completer.future;
  }

  Future<void> _searchPlaces() async {
    final query = _searchController.text.trim();
    if (query.length < 2 || _isSearching) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isSearching = true;
      _searchResults = const [];
    });

    try {
      final response = await _getFromGeocoder('/search', {
        'q': query,
        'format': 'jsonv2',
        'addressdetails': 1,
        'limit': 5,
        'accept-language': 'de,en',
      });

      final data = response.data;
      final results = data is List
          ? data
                .whereType<Map>()
                .map(
                  (item) =>
                      _PlaceCandidate.fromJson(Map<String, dynamic>.from(item)),
                )
                .whereType<_PlaceCandidate>()
                .toList()
          : <_PlaceCandidate>[];

      if (!mounted) return;
      setState(() => _searchResults = results);
      if (results.isEmpty) {
        _showMessage('Kein Standort gefunden. Bitte anders suchen.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Die Standortsuche ist gerade nicht verfügbar.');
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _selectSearchResult(_PlaceCandidate candidate) {
    _reverseRequestId++;
    final point = LatLng(candidate.latitude, candidate.longitude);
    setState(() {
      _selectedPoint = point;
      _selection = candidate.toSelection();
      _searchResults = const [];
      _searchController.text = candidate.displayName;
      _isResolving = false;
    });
    _mapController.move(point, 16);
  }

  Future<void> _selectMapPoint(LatLng point) async {
    final requestId = ++_reverseRequestId;
    setState(() {
      _selectedPoint = point;
      _selection = RestaurantLocationSelection(
        latitude: point.latitude,
        longitude: point.longitude,
        address: '',
        city: '',
        country: '',
        displayName: _formatCoordinates(point),
      );
      _searchResults = const [];
      _isResolving = true;
    });

    try {
      final response = await _getFromGeocoder('/reverse', {
        'lat': point.latitude,
        'lon': point.longitude,
        'format': 'jsonv2',
        'addressdetails': 1,
        'zoom': 18,
        'accept-language': 'de,en',
      });

      if (!mounted || requestId != _reverseRequestId) return;
      final data = response.data;
      if (data is Map) {
        final candidate = _PlaceCandidate.fromJson(
          Map<String, dynamic>.from(data),
        );
        if (candidate != null) {
          setState(() {
            _selection = RestaurantLocationSelection(
              latitude: point.latitude,
              longitude: point.longitude,
              address: candidate.address,
              city: candidate.city,
              country: candidate.country,
              displayName: candidate.displayName,
            );
          });
        }
      }
    } catch (_) {
      if (mounted && requestId == _reverseRequestId) {
        _showMessage(
          'Koordinaten ausgewählt. Die Adresse konnte nicht geladen werden.',
        );
      }
    } finally {
      if (mounted && requestId == _reverseRequestId) {
        setState(() => _isResolving = false);
      }
    }
  }

  Future<void> _useCurrentLocation() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Bitte aktivieren Sie die Standortdienste.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw Exception('Standortberechtigung wurde nicht erteilt.');
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Bitte erlauben Sie den Standort in den App-Einstellungen.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      if (!mounted) return;

      final point = LatLng(position.latitude, position.longitude);
      _mapController.move(point, 17);
      await _selectMapPoint(point);
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _confirmSelection() {
    final selection = _selection;
    if (selection != null) Navigator.pop(context, selection);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.textDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static String _formatCoordinates(LatLng point) =>
      '${point.latitude.toStringAsFixed(6)}, '
      '${point.longitude.toStringAsFixed(6)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Restaurantstandort auswählen',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: AppFontSizes.title,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _searchPlaces(),
                decoration: InputDecoration(
                  hintText: 'Adresse, Restaurant oder Ort suchen',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(13),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          onPressed: _searchPlaces,
                          icon: const Icon(Icons.arrow_forward),
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            if (_searchResults.isNotEmpty)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 230),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  itemCount: _searchResults.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      leading: const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        result.displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: AppFontSizes.labelSmall,
                        ),
                      ),
                      onTap: () => _selectSearchResult(result),
                    );
                  },
                ),
              ),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _selectedPoint,
                      initialZoom: 14,
                      minZoom: 3,
                      maxZoom: 19,
                      onTap: (_, point) => _selectMapPoint(point),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: _userAgentPackage,
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedPoint,
                            width: 52,
                            height: 52,
                            alignment: Alignment.bottomCenter,
                            child: const Icon(
                              Icons.location_pin,
                              color: AppColors.badgeRed,
                              size: 48,
                              shadows: [
                                Shadow(color: Colors.black38, blurRadius: 4),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    right: 14,
                    bottom: 40,
                    child: FloatingActionButton.small(
                      heroTag: 'restaurant-location-button',
                      onPressed: _isLocating ? null : _useCurrentLocation,
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      child: _isLocating
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location),
                    ),
                  ),
                  Positioned(
                    left: 6,
                    bottom: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      color: Colors.white.withValues(alpha: 0.85),
                      child: const Text(
                        '© OpenStreetMap contributors',
                        style: TextStyle(
                          fontSize: AppFontSizes.micro,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 12,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Ausgewählter Standort',
                    style: TextStyle(
                      fontSize: AppFontSizes.small,
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: _isResolving
                            ? const Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Adresse wird geladen ...'),
                                ],
                              )
                            : Text(
                                _selection?.displayName ??
                                    _formatCoordinates(_selectedPoint),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: AppFontSizes.labelSmall,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: FilledButton.icon(
                      onPressed: _selection == null || _isResolving
                          ? null
                          : _confirmSelection,
                      icon: const Icon(Icons.add_location_alt_outlined),
                      label: const Text('Diesen Standort hinzufügen'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceCandidate {
  final double latitude;
  final double longitude;
  final String displayName;
  final String address;
  final String city;
  final String country;

  const _PlaceCandidate({
    required this.latitude,
    required this.longitude,
    required this.displayName,
    required this.address,
    required this.city,
    required this.country,
  });

  static _PlaceCandidate? fromJson(Map<String, dynamic> json) {
    final latitude = double.tryParse(json['lat']?.toString() ?? '');
    final longitude = double.tryParse(json['lon']?.toString() ?? '');
    if (latitude == null || longitude == null) return null;

    final rawAddress = json['address'];
    final address = rawAddress is Map
        ? Map<String, dynamic>.from(rawAddress)
        : <String, dynamic>{};

    final road = _firstValue(address, const [
      'road',
      'pedestrian',
      'street',
      'residential',
      'footway',
      'path',
    ]);
    final houseNumber = _firstValue(address, const ['house_number']);
    final placeName = _firstValue(address, const [
      'restaurant',
      'amenity',
      'shop',
      'building',
    ]);

    final streetAddress = [
      road.isNotEmpty ? road : placeName,
      houseNumber,
    ].where((part) => part.isNotEmpty).join(' ');

    final city = _firstValue(address, const [
      'city',
      'town',
      'village',
      'municipality',
      'county',
      'state_district',
    ]);
    final country = _firstValue(address, const ['country']);
    final displayName = json['display_name']?.toString().trim() ?? '';

    return _PlaceCandidate(
      latitude: latitude,
      longitude: longitude,
      displayName: displayName.isEmpty
          ? '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}'
          : displayName,
      address: streetAddress,
      city: city,
      country: country,
    );
  }

  RestaurantLocationSelection toSelection() => RestaurantLocationSelection(
    latitude: latitude,
    longitude: longitude,
    address: address,
    city: city,
    country: country,
    displayName: displayName,
  );

  static String _firstValue(Map<String, dynamic> values, List<String> keys) {
    for (final key in keys) {
      final value = values[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return '';
  }
}
