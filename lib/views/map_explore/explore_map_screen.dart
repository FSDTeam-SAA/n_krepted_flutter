import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/restaurant_card.dart';
import '../../core/widgets/app_brand_logo.dart';
import '../../core/widgets/app_dropdown.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/open_external_link.dart';
import '../../data/models/deal_model.dart';
import '../../providers/deal_provider.dart';
import '../../providers/location_provider.dart';
import '../restaurant_details/restaurant_details_screen.dart';
import '../dish_details/dish_details_screen.dart';

class ExploreMapScreen extends StatefulWidget {
  final DealModel? initialRestaurant;
  final bool active;
  const ExploreMapScreen({
    super.key,
    this.initialRestaurant,
    this.active = true,
  });
  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen>
    with WidgetsBindingObserver {
  GoogleMapController? _map;
  StreamSubscription<Position>? _positions;
  bool _returningFromSettings = false;
  bool _optionsFailed = false;
  List<DealModel> _restaurants = [];
  DealModel? _selected;
  late bool _loading;
  String? _error;
  String _sort = 'nearest';
  String? _cuisine;
  List<String> _cuisines = [];
  double _radius = 10;
  int _request = 0;
  static const _enabled = bool.fromEnvironment('GOOGLE_MAPS_ENABLED');
  @override
  void initState() {
    super.initState();
    _loading = widget.active;
    WidgetsBinding.instance.addObserver(this);
    _selected = widget.initialRestaurant?.location.hasCoordinates == true
        ? widget.initialRestaurant
        : null;
    _radius = context.read<DealProvider>().radiusKm.clamp(1, 50);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.active) _load(locate: widget.initialRestaurant == null);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _options());
  }

  Future<void> _options() async {
    try {
      final options = await context
          .read<DealProvider>()
          .dealRepository
          .getDiscoveryOptions();
      if (mounted) {
        setState(() {
          _cuisines = (options['cuisines'] as List? ?? [])
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

  Future<void> _load({bool locate = false}) async {
    if (!widget.active || !mounted) return;
    final request = ++_request;
    final location = context.read<LocationProvider>();
    final repository = context.read<DealProvider>().dealRepository;
    setState(() {
      _loading = true;
      _error = null;
    });
    if (locate) await location.locate();
    if (!mounted || request != _request) return;
    try {
      final all = <DealModel>[];
      var page = 1;
      while (true) {
        final batch = await repository.getAllDeals(
          latitude: location.position?.latitude,
          longitude: location.position?.longitude,
          radiusKm: _radius,
          sort: _sort,
          cuisine: _cuisine,
          limit: 100,
          page: page++,
        );
        if (!mounted || request != _request) return;
        all.addAll(batch.where((r) => r.location.hasCoordinates));
        if (batch.length < 100) break;
      }
      if (_cuisine == null &&
          _selected != null &&
          _selected!.location.hasCoordinates &&
          !all.any((r) => r.id == _selected!.id)) {
        all.add(_selected!);
      }
      setState(() {
        _restaurants = all;
        _loading = false;
        _error = locate ? location.errorMessage : null;
      });
      final r = _selected ?? all.firstOrNull;
      if (r != null) {
        _map?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(r.location.latitude!, r.location.longitude!),
            13,
          ),
        );
      }
      if (widget.active && location.position != null) _track();
    } catch (e) {
      if (mounted && request == _request) {
        setState(() {
          _error = 'Restaurants konnten nicht geladen werden.';
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _positions?.cancel();
    ++_request;
    _map?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ExploreMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.active) {
      _loading = false;
      ++_request;
      _positions?.cancel();
      _positions = null;
    } else if (!oldWidget.active) {
      _load();
    }
  }

  void _track() {
    if (_positions != null || !widget.active) return;
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
            if (mounted && widget.active) {
              setState(
                () => _error = 'Standort konnte nicht aktualisiert werden.',
              );
            }
          },
        );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _positions?.cancel();
      _positions = null;
    }
    if (state == AppLifecycleState.resumed && widget.active) {
      if (_returningFromSettings) {
        _returningFromSettings = false;
        _load(locate: true);
      } else if (context.read<LocationProvider>().position != null) {
        _track();
      }
    }
  }

  Future<void> _openLocationSettings() async {
    _returningFromSettings = true;
    await context.read<LocationProvider>().openSettings();
  }

  Future<void> _zoom(double amount) async {
    final map = _map;
    if (map == null) return;
    try {
      final level = await map.getZoomLevel();
      await map.animateCamera(
        CameraUpdate.zoomTo((level + amount).clamp(2, 19)),
      );
    } catch (_) {
      /* A detached native map needs no camera update. */
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationProvider>();
    final point = _selected ?? _restaurants.firstOrNull;
    final center = point != null && point.location.hasCoordinates
        ? LatLng(point.location.latitude!, point.location.longitude!)
        : location.position != null
        ? LatLng(location.position!.latitude, location.position!.longitude)
        : const LatLng(51.1657, 10.4515);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.yellow,
        title: const AppBrandLogo(width: 78),
        actions: [
          IconButton(
            tooltip: 'Aktualisieren',
            onPressed: () => _load(),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Mein Standort',
            onPressed: () => _load(locate: true),
            icon: const Icon(Icons.my_location),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: AppDropdown<String>(
                    decoration: const InputDecoration(labelText: 'Sortierung'),
                    value: _sort,
                    items: const [
                      DropdownMenuItem(
                        value: 'nearest',
                        child: Text('Nächste zuerst'),
                      ),
                      DropdownMenuItem(
                        value: 'rating',
                        child: Text('Am besten bewertet'),
                      ),
                      DropdownMenuItem(
                        value: 'priceAsc',
                        child: Text('Am günstigsten'),
                      ),
                      DropdownMenuItem(
                        value: 'priceDesc',
                        child: Text('Am teuersten'),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() => _sort = v!);
                      _load();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppDropdown<double>(
                    decoration: const InputDecoration(labelText: 'Umkreis'),
                    value: _radius,
                    items:
                        ({1.0, 5.0, 10.0, 25.0, 50.0, _radius}.toList()..sort())
                            .map(
                              (r) => DropdownMenuItem(
                                value: r,
                                child: Text('${r.round()} km'),
                              ),
                            )
                            .toList(),
                    onChanged: (v) {
                      setState(() => _radius = v!);
                      _load(locate: true);
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_cuisines.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: AppDropdown<String>(
                decoration: const InputDecoration(labelText: 'Küchenart'),
                value: _cuisine ?? '',
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('Alle Küchenarten'),
                  ),
                  ..._cuisines.map(
                    (v) => DropdownMenuItem(value: v, child: Text(v)),
                  ),
                ],
                onChanged: (v) {
                  setState(() {
                    _cuisine = v?.isEmpty == true ? null : v;
                    _selected = null;
                  });
                  _load();
                },
              ),
            ),
          if (_loading) const LinearProgressIndicator(),
          if (_optionsFailed)
            TextButton(
              onPressed: _options,
              child: const Text('Küchenarten erneut laden'),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(_error!, textAlign: TextAlign.center),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => _load(locate: true),
                        child: const Text('Erneut versuchen'),
                      ),
                      if (location.errorMessage != null)
                        TextButton.icon(
                          onPressed: _openLocationSettings,
                          icon: const Icon(Icons.settings_outlined),
                          label: const Text('Standort aktivieren'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                if (_enabled)
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: center,
                      zoom: 12,
                    ),
                    myLocationEnabled: location.position != null,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    rotateGesturesEnabled: false,
                    minMaxZoomPreference: const MinMaxZoomPreference(2, 19),
                    circles: {
                      if (location.position != null)
                        Circle(
                          circleId: const CircleId('radius'),
                          center: LatLng(
                            location.position!.latitude,
                            location.position!.longitude,
                          ),
                          radius: _radius * 1000,
                          fillColor: AppColors.primary.withValues(alpha: .06),
                          strokeColor: AppColors.primary.withValues(alpha: .3),
                          strokeWidth: 1,
                        ),
                    },
                    onMapCreated: (controller) => _map = controller,
                    markers: _restaurants
                        .map(
                          (r) => Marker(
                            markerId: MarkerId(r.id),
                            position: LatLng(
                              r.location.latitude!,
                              r.location.longitude!,
                            ),
                            infoWindow: InfoWindow(title: r.title),
                            onTap: () => setState(() => _selected = r),
                          ),
                        )
                        .toSet(),
                  )
                else
                  const Center(
                    child: Text('Die Karte ist momentan nicht verfügbar.'),
                  ),
                if (_enabled)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Column(
                      children: [
                        IconButton.filledTonal(
                          tooltip: 'Vergrößern',
                          onPressed: () => _zoom(1),
                          icon: const Icon(Icons.add),
                        ),
                        const SizedBox(height: 8),
                        IconButton.filledTonal(
                          tooltip: 'Verkleinern',
                          onPressed: () => _zoom(-1),
                          icon: const Icon(Icons.remove),
                        ),
                      ],
                    ),
                  ),
                if (_selected != null)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: _selectedPreview(context),
                  ),
              ],
            ),
          ),
          if (!_loading && _restaurants.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Keine Restaurants in diesem Bereich.'),
            ),
        ],
      ),
    );
  }

  Widget _selectedPreview(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * .42,
    ),
    child: SingleChildScrollView(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'Auswahl schließen',
                  onPressed: () => setState(() => _selected = null),
                  icon: const Icon(Icons.close),
                ),
              ),
              RestaurantCard(
                deal: _selected!,
                compact: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RestaurantDetailsScreen(deal: _selected!),
                  ),
                ),
                onDishTap: (dish) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        DishDetailsScreen(deal: _selected!, dish: dish),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () =>
                    openExternalLink(context, googleMapsDirections(_selected!)),
                icon: const Icon(Icons.directions_walk),
                label: const Text('Route in Google Maps'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
