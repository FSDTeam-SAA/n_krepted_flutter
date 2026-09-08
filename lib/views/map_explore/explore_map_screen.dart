import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/restaurant_card.dart';
import '../../core/widgets/restaurant_map_pin.dart';
import '../../core/widgets/app_brand_logo.dart';
import '../../core/constants/app_assets.dart';
import 'package:flutter/services.dart';
import '../../core/network/api_error.dart';
import '../../data/models/deal_model.dart';
import '../../providers/deal_provider.dart';
import '../../providers/location_provider.dart';
import '../restaurant_details/restaurant_details_screen.dart';

class ExploreMapScreen extends StatefulWidget {
  final bool active;
  final DealModel? initialRestaurant;
  const ExploreMapScreen({
    super.key,
    this.active = true,
    this.initialRestaurant,
  });
  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen>
    with WidgetsBindingObserver {
  final _controller = MapController();
  StreamSubscription<Position>? _positions;
  List<DealModel> _restaurants = [];
  DealModel? _selected;
  bool _loading = true, _ready = false, _tileError = false;
  String? _error;
  String _sort = 'rating';
  String? _cuisine;
  List<String> _cuisines = [];
  bool _optionsFailed = false;
  int _request = 0, _tileGeneration = 0;
  late double _radiusKm;
  bool _returningFromSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _radiusKm = context.read<DealProvider>().radiusKm;
    _selected = widget.initialRestaurant;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOptions();
      _load(requestLocation: widget.initialRestaurant == null);
    });
  }

  @override
  void didUpdateWidget(covariant ExploreMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.active) {
      _positions?.cancel();
      _positions = null;
    } else if (!oldWidget.active) {
      _load();
    }
  }

  Future<void> _loadOptions() async {
    try {
      final data = await context
          .read<DealProvider>()
          .dealRepository
          .getDiscoveryOptions();
      if (mounted) {
        setState(() {
          _cuisines = (data['cuisines'] as List? ?? [])
              .whereType<String>()
              .where((value) => value.trim().isNotEmpty)
              .toSet()
              .toList();
          _optionsFailed = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _optionsFailed = true);
    }
  }

  Future<void> _load({
    bool requestLocation = false,
    bool selectFirst = false,
  }) async {
    if (!mounted) return;
    final request = ++_request;
    final location = context.read<LocationProvider>();
    final repository = context.read<DealProvider>().dealRepository;
    setState(() {
      _loading = true;
      _error = null;
    });
    if (requestLocation) await location.locate();
    if (!mounted || request != _request) return;
    final position = location.position;
    try {
      final results = <DealModel>[];
      int page = 1;
      while (true) {
        final batch = await repository.getAllDeals(
          latitude: position?.latitude,
          longitude: position?.longitude,
          radiusKm: _radiusKm,
          sort: _sort,
          cuisine: _cuisine,
          limit: 100,
          page: page++,
        );
        if (!mounted || request != _request) return;
        results.addAll(
          batch.where((restaurant) => restaurant.location.hasCoordinates),
        );
        if (batch.length < 100) break;
      }
      if (!mounted || request != _request) return;
      final initial = widget.initialRestaurant;
      if (_cuisine == null &&
          initial != null &&
          initial.location.hasCoordinates &&
          !results.any((item) => item.id == initial.id)) {
        results.add(initial);
      }
      setState(() {
        _restaurants = results;
        _selected = selectFirst
            ? results.firstOrNull
            : results.where((item) => item.id == _selected?.id).firstOrNull;
        _loading = false;
        if (requestLocation && location.errorMessage != null) {
          _error = location.errorMessage;
        }
      });
      _fit();
      if (position != null && widget.active) _track();
    } catch (error) {
      if (mounted && request == _request) {
        setState(() {
          _loading = false;
          _error = friendlyApiError(error);
        });
      }
    }
  }

  void _track() {
    if (_positions != null) return;
    _positions =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 25,
          ),
        ).listen(
          (position) {
            if (mounted && widget.active) {
              context.read<LocationProvider>().update(position);
            }
          },
          onError: (_) {
            if (mounted) {
              setState(
                () => _error = 'Standort konnte nicht aktualisiert werden.',
              );
            }
          },
        );
  }

  void _fit() {
    if (!_ready || !mounted) return;
    final position = context.read<LocationProvider>().position;
    if (_selected?.location.hasCoordinates == true) {
      _controller.move(
        LatLng(_selected!.location.latitude!, _selected!.location.longitude!),
        15,
      );
      return;
    }
    final points = [
      if (position != null) LatLng(position.latitude, position.longitude),
      ..._restaurants.map(
        (item) => LatLng(item.location.latitude!, item.location.longitude!),
      ),
    ];
    if (points.length == 1) {
      _controller.move(points.first, 14);
    } else if (points.length > 1) {
      _controller.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.fromLTRB(45, 135, 45, 170),
          maxZoom: 15,
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ++_request;
    _positions?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _returningFromSettings &&
        widget.active) {
      _returningFromSettings = false;
      _load(requestLocation: true);
    }
  }

  Future<void> _openLocationSettings() async {
    _returningFromSettings = true;
    if (!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openLocationSettings();
    } else {
      await Geolocator.openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationProvider>();
    final position = location.position;
    final initial = _selected ?? _restaurants.firstOrNull;
    final center = position != null
        ? LatLng(position.latitude, position.longitude)
        : initial?.location.hasCoordinates == true
        ? LatLng(initial!.location.latitude!, initial.location.longitude!)
        : const LatLng(
            0,
            0,
          ); // World view until actual coordinates are available.
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Column(
          children: [
            _header(),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _controller,
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: initial != null || position != null ? 13 : 2,
                      minZoom: 2,
                      maxZoom: 19,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                      ),
                      onMapReady: () {
                        _ready = true;
                        _fit();
                      },
                      onTap: (_, _) => setState(() => _selected = null),
                    ),
                    children: [
                      TileLayer(
                        key: ValueKey(_tileGeneration),
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.n_krepted_flutter',
                        maxNativeZoom: 19,
                        errorTileCallback: (_, _, _) {
                          if (!_tileError) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) setState(() => _tileError = true);
                            });
                          }
                        },
                      ),
                      if (position != null)
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: LatLng(
                                position.latitude,
                                position.longitude,
                              ),
                              radius: _radiusKm * 1000,
                              useRadiusInMeter: true,
                              color: Colors.red.withValues(alpha: .06),
                              borderColor: Colors.red.withValues(alpha: .3),
                              borderStrokeWidth: 1,
                            ),
                            CircleMarker(
                              point: LatLng(
                                position.latitude,
                                position.longitude,
                              ),
                              radius: position.accuracy,
                              useRadiusInMeter: true,
                              color: Colors.red.withValues(alpha: .15),
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: [
                          for (final restaurant in _restaurants)
                            Marker(
                              point: LatLng(
                                restaurant.location.latitude!,
                                restaurant.location.longitude!,
                              ),
                              alignment: Alignment.bottomCenter,
                              width: 56,
                              height: 70,
                              child: Semantics(
                                label: restaurant.restaurantName,
                                button: true,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => _selected = restaurant);
                                    _controller.move(
                                      LatLng(
                                        restaurant.location.latitude!,
                                        restaurant.location.longitude!,
                                      ),
                                      _controller.camera.zoom,
                                    );
                                  },
                                  child: RestaurantMapPin(
                                    imageUrl: restaurant.firstImage,
                                    selected: _selected?.id == restaurant.id,
                                  ),
                                ),
                              ),
                            ),
                          if (position != null)
                            Marker(
                              point: LatLng(
                                position.latitude,
                                position.longitude,
                              ),
                              width: 42,
                              height: 42,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red.withValues(alpha: .2),
                                ),
                                padding: const EdgeInsets.all(11),
                                child: const DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(top: 0, left: 0, right: 0, child: _filters()),
                  if (_loading || location.isLoading)
                    const Positioned(
                      top: 93,
                      left: 24,
                      right: 24,
                      child: LinearProgressIndicator(),
                    ),
                  Positioned(
                    right: 16,
                    top: 106,
                    child: Column(
                      children: [
                        _control(
                          Icons.add,
                          () => _zoomMap(1),
                          tooltip: 'Vergrößern',
                        ),
                        const SizedBox(height: 8),
                        _control(
                          Icons.remove,
                          () => _zoomMap(-1),
                          tooltip: 'Verkleinern',
                        ),
                      ],
                    ),
                  ),
                  if (!_loading &&
                      (_error != null || _tileError || _restaurants.isEmpty))
                    Positioned(
                      top: 106,
                      left: 20,
                      right: 76,
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Text(
                                _error ??
                                    (_tileError
                                        ? 'Kartenkacheln konnten nicht geladen werden.'
                                        : 'Keine Restaurants mit Standort gefunden.'),
                                textAlign: TextAlign.center,
                              ),
                              if (_tileError)
                                TextButton(
                                  onPressed: () => setState(() {
                                    _tileError = false;
                                    _tileGeneration++;
                                  }),
                                  child: const Text('Karte neu laden'),
                                ),
                              if (location.errorMessage != null)
                                TextButton.icon(
                                  onPressed: _openLocationSettings,
                                  icon: const Icon(Icons.settings_outlined),
                                  label: const Text('Standort aktivieren'),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (_selected != null)
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 28,
                      child: RestaurantCard(
                        deal: _selected!,
                        compact: true,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RestaurantDetailsScreen(deal: _selected!),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 3,
                    right: 4,
                    child: Container(
                      color: Colors.white.withValues(alpha: .9),
                      padding: const EdgeInsets.all(3),
                      child: const Text(
                        '© OpenStreetMap contributors',
                        style: TextStyle(fontSize: 10),
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

  Widget _header() => Container(
    decoration: const BoxDecoration(
      color: AppColors.yellow,
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
    ),
    clipBehavior: Clip.antiAlias,
    child: Stack(
      children: [
        Positioned(
          right: -8,
          top: -14,
          child: Opacity(
            opacity: .65,
            child: Image.asset(AppAssets.decoHerbs, width: 110),
          ),
        ),
        SafeArea(
          bottom: false,
          child: SizedBox(
            height: 88,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  if (Navigator.canPop(context))
                    IconButton(
                      tooltip: 'Zurück',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textDark,
                      ),
                    ),
                  const AppBrandLogo(width: 78),
                  const Spacer(),
                  _control(
                    Icons.my_location,
                    () => _load(requestLocation: true),
                    tooltip: 'Mein Standort',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _filters() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Material(
        color: Colors.white.withValues(alpha: .87),
        child: Row(
          children: [
            for (final option in const [
              ('rating', 'Am besten bewertet'),
              ('priceAsc', 'Am günstigsten'),
              ('priceDesc', 'Am teuersten'),
            ])
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() => _sort = option.$1);
                    _load(selectFirst: true);
                  },
                  child: Container(
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _sort == option.$1
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      option.$2,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 11,
                        color: _sort == option.$1
                            ? AppColors.textDark
                            : AppColors.textGrey,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      SizedBox(
        height: 52,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          children: [
            for (final cuisine in [null, ..._cuisines])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    cuisine ?? 'Alle',
                    style: const TextStyle(fontSize: 11),
                  ),
                  selected: _cuisine == cuisine,
                  showCheckmark: false,
                  selectedColor: const Color(0xFFFFF5CF),
                  backgroundColor: const Color(0xFFF4F3F2),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (_) {
                    setState(() {
                      _cuisine = cuisine;
                      _selected = null;
                    });
                    _load();
                  },
                ),
              ),
            if (_optionsFailed)
              ActionChip(
                label: const Text('Filter neu laden'),
                onPressed: _loadOptions,
              ),
          ],
        ),
      ),
    ],
  );

  void _zoomMap(double step) {
    if (!_ready) return;
    _controller.move(
      _controller.camera.center,
      (_controller.camera.zoom + step).clamp(2.0, 19.0),
    );
  }

  Widget _control(IconData icon, VoidCallback onTap, {String? tooltip}) =>
      Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 2,
        child: IconButton(
          tooltip: tooltip,
          icon: Icon(icon, color: AppColors.textDark),
          onPressed: onTap,
        ),
      );
}
