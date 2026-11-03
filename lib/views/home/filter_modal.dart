import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/app_dropdown.dart';
import '../../core/widgets/bottom_action_bar.dart';
import '../../core/widgets/custom_button.dart';
import '../../providers/category_provider.dart';
import '../../providers/deal_provider.dart';
import '../../providers/location_provider.dart';

Future<void> showDiscoveryFilters(BuildContext context) async {
  final deals = context.read<DealProvider>();
  final categories = context.read<CategoryProvider>();
  final location = context.read<LocationProvider>();
  await showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: const Color(0xFFF6F8F9),
    constraints: const BoxConstraints(maxWidth: 640),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (_) => MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: deals),
        ChangeNotifierProvider.value(value: categories),
        ChangeNotifierProvider.value(value: location),
      ],
      child: const FractionallySizedBox(
        heightFactor: .92,
        child: FilterModal(),
      ),
    ),
  );
}

/// One entry point for the same filter sheet in Home, Search and Categories.
class DiscoveryFilterButton extends StatelessWidget {
  const DiscoveryFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.watch<DealProvider>().activeFilterCount;
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      onPressed: () => showDiscoveryFilters(context),
      icon: const Icon(Icons.tune_rounded, size: 18),
      label: Text(count == 0 ? 'Filter' : 'Filter · $count'),
    );
  }
}

class FilterModal extends StatefulWidget {
  const FilterModal({super.key});

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  final _scroll = ScrollController();
  late String _city, _sort;
  late double _distance;
  String? _category, _cuisine, _priceRange, _locationError;
  int _rating = 0;
  bool _openNow = false, _nearby = false, _saving = false, _locating = false;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    final provider = context.read<DealProvider>();
    _city = provider.locationQuery;
    _distance = provider.radiusKm.clamp(1, 50);
    _sort = provider.sort;
    _category = provider.selectedCategory;
    _cuisine = provider.cuisine;
    _priceRange = provider.priceRange;
    _rating = provider.minimumRating;
    _openNow = provider.openNow;
    _tags = [...provider.tags];
    _nearby = provider.latitude != null || _sort == 'nearest';
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  int get _count =>
      (_nearby || _city.isNotEmpty ? 1 : 0) +
      (_rating > 0 ? 1 : 0) +
      (_category != null ? 1 : 0) +
      (_cuisine != null ? 1 : 0) +
      (_priceRange != null ? 1 : 0) +
      (_openNow ? 1 : 0) +
      _tags.length +
      (_sort != 'rating' ? 1 : 0);

  void _reset() => setState(() {
    _city = '';
    _distance = 10;
    _sort = 'rating';
    _category = null;
    _cuisine = null;
    _priceRange = null;
    _rating = 0;
    _openNow = false;
    _tags = [];
    _nearby = false;
    _locationError = null;
  });

  void _setNearby(bool nearby) {
    setState(() {
      _nearby = nearby;
      _locationError = null;
      if (!nearby && _sort == 'nearest') _sort = 'rating';
    });
    _scrollToLocation();
  }

  void _scrollToLocation() {
    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<bool> _locate() async {
    if (_locating) return false;
    setState(() {
      _locating = true;
      _locationError = null;
    });
    final location = context.read<LocationProvider>();
    final success = await location.locate();
    if (!mounted) return false;
    setState(() {
      _locating = false;
      _locationError = success
          ? null
          : location.errorMessage ?? 'Standort konnte nicht ermittelt werden.';
    });
    return success;
  }

  Future<void> _apply() async {
    if (_saving || _locating) return;
    setState(() => _saving = true);
    final provider = context.read<DealProvider>();
    final location = context.read<LocationProvider>();
    if (_nearby && !await _locate()) {
      if (mounted) setState(() => _saving = false);
      if (mounted) _scrollToLocation();
      return;
    }
    if (!mounted) return;
    provider.latitude = _nearby ? location.position!.latitude : null;
    provider.longitude = _nearby ? location.position!.longitude : null;
    provider.sort = _sort;
    provider.priceRange = _priceRange;
    provider.openNow = _openNow;
    provider.tags = [..._tags];
    provider.setCategoryFilter(_category);
    await provider.applyFilters(
      location: _nearby ? '' : _city,
      radiusKm: _distance,
      minimumRating: _rating,
      cuisine: _cuisine,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>();
    final location = context.watch<LocationProvider>();
    final tags = {...categories.tags, ..._tags}.toList();
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8F9),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF6F8F9),
          toolbarHeight: 72,
          leading: IconButton(
            tooltip: 'Filter schließen',
            onPressed: _saving ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              Text(
                _count == 0
                    ? 'Deine Suche, dein Geschmack'
                    : '$_count Filter ausgewählt',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _saving || _count == 0 ? null : _reset,
              child: const Text('Zurücksetzen', style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 4),
          ],
        ),
        bottomNavigationBar: BottomActionBar(
          child: CustomButton(
            key: const ValueKey('apply-discovery-filters'),
            text: 'Ergebnisse anzeigen',
            icon: const Icon(
              Icons.search_rounded,
              color: Colors.white,
              size: 20,
            ),
            isLoading: _saving,
            onPressed: _locating ? null : _apply,
          ),
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: AbsorbPointer(
            absorbing: _saving,
            child: ListView(
              controller: _scroll,
              padding: AppSpacing.pagePadding,
              children: [
                _section(
                  Icons.place_outlined,
                  'Wo möchtest du essen?',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _locationMode(
                              'Stadt',
                              Icons.location_city_rounded,
                              false,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _locationMode(
                              'In der Nähe',
                              Icons.near_me_outlined,
                              true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (!_nearby)
                        AppDropdown<String>(
                          key: const ValueKey('filter-city'),
                          value: _city,
                          items: [
                            const DropdownMenuItem(
                              value: '',
                              child: Text('Alle Städte'),
                            ),
                            for (final city in {
                              ...categories.cities,
                              if (_city.isNotEmpty) _city,
                            })
                              DropdownMenuItem(value: city, child: Text(city)),
                          ],
                          onChanged: (value) =>
                              setState(() => _city = value ?? ''),
                        )
                      else ...[
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Umkreis',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              '${_distance.round()} km',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _distance,
                          min: 1,
                          max: 50,
                          divisions: 49,
                          label: '${_distance.round()} km',
                          onChanged: (value) =>
                              setState(() => _distance = value),
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('1 km', style: _caption),
                            Text('50 km', style: _caption),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (location.position != null && _locationError == null)
                          const Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Dein Standort ist bereit.',
                                  style: _caption,
                                ),
                              ),
                            ],
                          )
                        else if (_locationError == null)
                          OutlinedButton.icon(
                            onPressed: _locating ? null : _locate,
                            icon: _locating
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.my_location_rounded,
                                    size: 18,
                                  ),
                            label: Text(
                              _locating
                                  ? 'Standort wird ermittelt …'
                                  : 'Standort verwenden',
                            ),
                          ),
                        if (_locationError != null) _locationNotice(),
                      ],
                    ],
                  ),
                  description:
                      'Wähle eine Stadt oder suche in deiner Umgebung.',
                ),
                _section(
                  Icons.schedule_rounded,
                  'Jetzt geöffnet',
                  SwitchListTile.adaptive(
                    key: const ValueKey('filter-open-now'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Nur geöffnete Restaurants',
                      style: TextStyle(fontSize: 14),
                    ),
                    value: _openNow,
                    activeTrackColor: AppColors.primary,
                    onChanged: (value) => setState(() => _openNow = value),
                  ),
                ),
                _section(
                  Icons.restaurant_menu_rounded,
                  'Worauf hast du Lust?',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppDropdown<String>(
                        value: _cuisine ?? '',
                        decoration: const InputDecoration(
                          labelText: 'Küchenart',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('Alle Küchenarten'),
                          ),
                          for (final cuisine in {
                            ...categories.cuisines,
                            ?_cuisine,
                          })
                            DropdownMenuItem(
                              value: cuisine,
                              child: Text(cuisine),
                            ),
                        ],
                        onChanged: (value) => setState(
                          () => _cuisine = value == '' ? null : value,
                        ),
                      ),
                      const SizedBox(height: 20),
                      AppDropdown<String>(
                        value: _category ?? '',
                        decoration: const InputDecoration(
                          labelText: 'Kategorie',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('Alle Kategorien'),
                          ),
                          for (final category in categories.categories)
                            DropdownMenuItem(
                              value: category.id,
                              child: Text(category.categoryName),
                            ),
                          if (_category != null &&
                              !categories.categories.any(
                                (category) => category.id == _category,
                              ))
                            DropdownMenuItem(
                              value: _category,
                              child: const Text('Ausgewählte Kategorie'),
                            ),
                        ],
                        onChanged: (value) => setState(
                          () => _category = value == '' ? null : value,
                        ),
                      ),
                    ],
                  ),
                ),
                _section(
                  Icons.payments_outlined,
                  'Preisklasse',
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _choice(
                        'Alle',
                        _priceRange == null,
                        () => setState(() => _priceRange = null),
                      ),
                      for (var i = 1; i <= 4; i++)
                        _choice(
                          List.filled(i, '€').join(),
                          _priceRange == List.filled(i, r'$').join(),
                          () => setState(
                            () => _priceRange = List.filled(i, r'$').join(),
                          ),
                        ),
                    ],
                  ),
                  description: 'Von günstig bis gehoben.',
                ),
                _section(
                  Icons.star_outline_rounded,
                  'Mindestbewertung',
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          mainAxisExtent: 48,
                        ),
                    children: [
                      for (var i = 0; i <= 5; i++)
                        _choice(
                          i == 0
                              ? 'Alle'
                              : i == 5
                              ? '5 ★'
                              : '$i ★+',
                          _rating == i,
                          () => setState(() => _rating = i),
                        ),
                    ],
                  ),
                  description: 'Zeige Restaurants ab deiner Wunschbewertung.',
                ),
                if (tags.isNotEmpty)
                  _section(
                    Icons.eco_outlined,
                    'Ernährung & Merkmale',
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final tag in tags)
                          _choice(
                            _tagLabel(tag),
                            _tags.contains(tag),
                            () => setState(() {
                              if (!_tags.remove(tag)) _tags.add(tag);
                            }),
                            multiple: true,
                          ),
                      ],
                    ),
                    description: 'Mehrere Optionen sind möglich.',
                  ),
                _section(
                  Icons.sort_rounded,
                  'Sortieren nach',
                  AppDropdown<String>(
                    value: _sort,
                    items: const [
                      DropdownMenuItem(
                        value: 'rating',
                        child: Text('Am besten bewertet'),
                      ),
                      DropdownMenuItem(
                        value: 'nearest',
                        child: Text('Nächste zuerst'),
                      ),
                      DropdownMenuItem(
                        value: 'priceAsc',
                        child: Text('Preis aufsteigend'),
                      ),
                      DropdownMenuItem(
                        value: 'priceDesc',
                        child: Text('Preis absteigend'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _sort = value!;
                        if (value == 'nearest') _nearby = true;
                      });
                      if (value == 'nearest') _scrollToLocation();
                    },
                  ),
                ),
                if (categories.isLoading) const LinearProgressIndicator(),
                if (categories.errorMessage != null)
                  TextButton.icon(
                    onPressed: categories.fetchCategories,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Filteroptionen erneut laden'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _locationMode(String label, IconData icon, bool nearby) {
    final selected = _nearby == nearby;
    return OutlinedButton(
      key: ValueKey(nearby ? 'filter-nearby-mode' : 'filter-city-mode'),
      onPressed: () => _setNearby(nearby),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        backgroundColor: selected ? AppColors.primaryLight : Colors.white,
        foregroundColor: selected ? AppColors.primaryDark : AppColors.textGrey,
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.cardBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationNotice() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.cardYellow,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Standort nicht verfügbar',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(_locationError!, style: _caption),
        const SizedBox(height: 8),
        const Text(
          'Du kannst auch ohne Standort nach einer Stadt suchen.',
          style: _caption,
        ),
        Wrap(
          spacing: 8,
          children: [
            TextButton(
              onPressed: () => _setNearby(false),
              child: const Text('Stadt auswählen'),
            ),
            TextButton(
              onPressed: _locating ? null : _locate,
              child: const Text('Erneut versuchen'),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _choice(
    String label,
    bool selected,
    VoidCallback onTap, {
    bool multiple = false,
  }) => FilterChip(
    label: Text(
      label,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    ),
    selected: selected,
    showCheckmark: multiple,
    onSelected: (_) => onTap(),
    selectedColor: AppColors.primaryLight,
    backgroundColor: const Color(0xFFF4F6F7),
    checkmarkColor: AppColors.primaryDark,
    labelStyle: TextStyle(
      color: selected ? AppColors.primaryDark : AppColors.textBody,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    side: BorderSide(color: selected ? AppColors.primary : Colors.transparent),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  Widget _section(
    IconData icon,
    String title,
    Widget child, {
    String? description,
  }) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.cardBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: AppFontSizes.subtitle,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: 6),
          Text(description, style: _caption),
        ],
        const SizedBox(height: 14),
        child,
      ],
    ),
  );

  static const _caption = TextStyle(
    fontSize: 12,
    color: AppColors.textGrey,
    height: 1.5,
  );

  static String _tagLabel(String value) =>
      const {
        'Contains nuts': 'Mit Nüssen',
        'Gluten-free': 'Glutenfrei',
        'Low-carb': 'Low Carb',
        'New': 'Neu',
        'Spicy': 'Scharf',
        'Vegetarian': 'Vegetarisch',
      }[value] ??
      value;
}
