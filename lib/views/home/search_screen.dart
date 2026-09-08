import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/owner_page_background.dart';
import '../../providers/deal_provider.dart';
import '../../providers/category_provider.dart';
import 'discovery_feed.dart';
import 'filter_modal.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => DealProvider(
      dealRepository: context.read<DealProvider>().dealRepository,
    ),
    child: const _SearchBody(),
  );
}

class _SearchBody extends StatefulWidget {
  const _SearchBody();
  @override
  State<_SearchBody> createState() => _SearchBodyState();
}

class _SearchBodyState extends State<_SearchBody> {
  final _search = TextEditingController();
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DealProvider>();
    final categories = context.watch<CategoryProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: OwnerPageBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 10, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _search,
                        autofocus: true,
                        onChanged: provider.setSearchQuery,
                        decoration: InputDecoration(
                          hintText: 'Finde dein Gericht, Restaurants und Bars',
                          prefixIcon: const Icon(Icons.search, size: 18),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: _search.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _search.clear();
                                    provider.setSearchQuery('');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.cardBorder,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    FilledButton.icon(
                      onPressed: () => showDiscoveryFilters(context),
                      icon: const Icon(Icons.tune, size: 16),
                      label: const Text('Filter'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Alle'),
                      selected: provider.selectedCategory == null,
                      onSelected: (_) => provider.selectCategory(null),
                    ),
                    for (final category in categories.categories)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ChoiceChip(
                          label: Text(category.categoryName),
                          selected: provider.selectedCategory == category.id,
                          onSelected: (_) =>
                              provider.selectCategory(category.id),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Expanded(child: DiscoveryFeed(compact: true)),
            ],
          ),
        ),
      ),
    );
  }
}
