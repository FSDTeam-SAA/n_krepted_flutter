import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/owner_page_background.dart';
import '../../providers/deal_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/location_provider.dart';
import '../../core/constants/app_text_styles.dart';

Future<void> showDiscoveryFilters(BuildContext context) async {
  final provider = context.read<DealProvider>();
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: const FilterModal(),
      ),
    ),
  );
}

class FilterModal extends StatefulWidget {
  const FilterModal({super.key});
  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late final TextEditingController _location;
  late double _distance;
  late String _sort;
  String? _category;
  String? _cuisine;
  bool _useDistance = false, _saving = false;
  @override
  void initState() {
    super.initState();
    final provider = context.read<DealProvider>();
    _location = TextEditingController(text: provider.locationQuery);
    _distance = provider.radiusKm.clamp(1, 50);
    _sort = provider.sort;
    _category = provider.selectedCategory;
    _useDistance = provider.latitude != null;
    _cuisine = provider.cuisine;
  }

  @override
  void dispose() {
    _location.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    if (_saving) return;
    final provider = context.read<DealProvider>();
    final location = context.read<LocationProvider>();
    setState(() => _saving = true);
    if (_useDistance && !await location.locate()) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(location.errorMessage ?? 'Standort nicht verfügbar.'),
          ),
        );
      }
      return;
    }
    if (!mounted) return;
    provider.latitude = _useDistance ? location.position!.latitude : null;
    provider.longitude = _useDistance ? location.position!.longitude : null;
    provider.sort = _sort;
    provider.setCategoryFilter(_category);
    await provider.applyFilters(
      location: _location.text,
      radiusKm: _distance,
      minimumRating: 0,
      cuisine: _cuisine,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Filter'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _location.clear();
                _distance = 10;
                _sort = 'rating';
                _category = null;
                _cuisine = null;
                _useDistance = false;
              });
            },
            child: const Text('Zurücksetzen'),
          ),
        ],
      ),
      body: OwnerPageBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _section(
              'Stadt auswählen',
              DropdownButtonFormField<String>(
                key: ValueKey(_location.text),
                initialValue: _location.text,
                isExpanded: true,
                decoration: const InputDecoration(border: InputBorder.none),
                items: [
                  const DropdownMenuItem(value: '', child: Text('Alle Städte')),
                  for (final city in {
                    ...categories.cities,
                    if (_location.text.isNotEmpty) _location.text,
                  })
                    DropdownMenuItem(value: city, child: Text(city)),
                ],
                onChanged: (value) =>
                    setState(() => _location.text = value ?? ''),
              ),
            ),
            _section(
              'Entfernung von Ihrem Standort',
              Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'In meiner Nähe',
                      style: TextStyle(fontSize: AppFontSizes.body),
                    ),
                    value: _useDistance,
                    onChanged: (value) => setState(() => _useDistance = value),
                  ),
                  Slider(
                    value: _distance,
                    min: 1,
                    max: 50,
                    divisions: 49,
                    label: '${_distance.round()} km',
                    onChanged: (value) => setState(() {
                      _distance = value;
                      _useDistance = true;
                    }),
                  ),
                  Text(
                    '${_distance.round()} km',
                    style: const TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            _section(
              'Sortieren nach',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in {
                    'rating': 'Am besten bewertet',
                    'priceAsc': 'Am günstigsten',
                    'priceDesc': 'Am teuersten',
                  }.entries)
                    ChoiceChip(
                      label: Text(entry.value),
                      selected: _sort == entry.key,
                      onSelected: (_) => setState(() => _sort = entry.key),
                    ),
                ],
              ),
            ),
            _section(
              'Küchenart',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Alle'),
                    selected: _cuisine == null,
                    onSelected: (_) => setState(() => _cuisine = null),
                  ),
                  for (final cuisine in categories.cuisines)
                    ChoiceChip(
                      label: Text(cuisine),
                      selected: _cuisine == cuisine,
                      onSelected: (_) => setState(() => _cuisine = cuisine),
                    ),
                ],
              ),
            ),
            if (categories.errorMessage != null)
              TextButton.icon(
                onPressed: categories.fetchCategories,
                icon: const Icon(Icons.refresh),
                label: const Text('Filteroptionen neu laden'),
              ),
            _section(
              'Kategorien',
              categories.isLoading
                  ? const LinearProgressIndicator()
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Alle'),
                          selected: _category == null,
                          onSelected: (_) => setState(() => _category = null),
                        ),
                        for (final category in categories.categories)
                          ChoiceChip(
                            label: Text(category.categoryName),
                            selected: _category == category.id,
                            onSelected: (_) =>
                                setState(() => _category = category.id),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Filter anwenden',
              isLoading: _saving,
              onPressed: _apply,
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, Widget child) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: AppFontSizes.body,
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}
