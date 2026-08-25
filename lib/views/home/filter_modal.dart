import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../providers/deal_provider.dart';

class FilterModal extends StatefulWidget {
  const FilterModal({super.key});

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  double _distance = 15;
  int _selectedRating = 4;
  String _selectedCuisine = 'Deutsch';
  late final TextEditingController _locationController;
  bool _initialized = false;

  final List<String> _cuisines = [
    'Deutsch',
    'Italienisch',
    'Indisch',
    'Chinesisch',
    'Japanisch',
    'Mediterran',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final provider = context.read<DealProvider>();
    _distance = provider.radiusKm;
    _selectedRating = provider.minimumRating;
    _selectedCuisine = provider.cuisine ?? '';
    _locationController = TextEditingController(text: provider.locationQuery);
    _initialized = true;
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle & Title
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _distance = 15;
                      _selectedRating = 0;
                      _selectedCuisine = '';
                      _locationController.clear();
                    });
                    context.read<DealProvider>().resetFilters();
                  },
                  child: const Text(
                    'Zurücksetzen',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const Divider(color: AppColors.divider),
            const SizedBox(height: 12),

            const Text(
              'Standort',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Stadt oder Land eingeben',
                prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Distance Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Entfernung',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                Text(
                  '${_distance.toInt()} km',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
            Slider(
              value: _distance,
              min: 1,
              max: 50,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.primaryLight,
              onChanged: (val) => setState(() => _distance = val),
            ),

            const SizedBox(height: 12),

            // Rating Filter
            const Text(
              'Bewertung',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                final rating = index + 1;
                final isSelected = _selectedRating == rating;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRating = rating),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '$rating',
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.star,
                          size: 14,
                          color: isSelected ? Colors.white : AppColors.orangeAccent,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            // Cuisine Category
            const Text(
              'Kategorie',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _cuisines.map((cuisine) {
                final isSelected = _selectedCuisine == cuisine;
                return GestureDetector(
                  onTap: () => setState(() =>
                      _selectedCuisine = isSelected ? '' : cuisine),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFFF9E6) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected ? Border.all(color: AppColors.orangeAccent) : null,
                    ),
                    child: Text(
                      cuisine,
                      style: TextStyle(
                        color: isSelected ? AppColors.textDark : AppColors.textGrey,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Apply Button
            CustomButton(
              text: 'Filter anwenden',
              onPressed: () async {
                await context.read<DealProvider>().applyFilters(
                      location: _locationController.text,
                      radiusKm: _distance,
                      minimumRating: _selectedRating,
                      cuisine: _selectedCuisine,
                    );
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
