import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/owner_page_background.dart';
import '../../providers/deal_provider.dart';
import '../../providers/category_provider.dart';
import 'discovery_feed.dart';
import 'filter_modal.dart';

class CategoriesScreen extends StatelessWidget {
  final String? initialCategoryId;
  const CategoriesScreen({super.key, this.initialCategoryId});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => DealProvider(
      dealRepository: context.read<DealProvider>().dealRepository,
      autoLoad: false,
    )..selectCategory(initialCategoryId),
    child: const _CategoriesBody(),
  );
}

class _CategoriesBody extends StatelessWidget {
  const _CategoriesBody();
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DealProvider>();
    final categories = context.watch<CategoryProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Kategorien')),
      body: OwnerPageBackground(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  FilledButton.icon(
                    onPressed: () => showDiscoveryFilters(context),
                    icon: const Icon(Icons.tune),
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
                        onSelected: (_) => provider.selectCategory(category.id),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Expanded(child: DiscoveryFeed()),
          ],
        ),
      ),
    );
  }
}
