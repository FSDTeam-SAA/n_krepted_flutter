import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import 'categories_screen.dart';

/// Legacy route delegates to the same database category discovery flow.
class AllDishesScreen extends StatelessWidget {
  final String categoryName;
  const AllDishesScreen({super.key, required this.categoryName});
  @override
  Widget build(BuildContext context) {
    final category = context.watch<CategoryProvider>().categories.where((item) => item.categoryName == categoryName).firstOrNull;
    return CategoriesScreen(initialCategoryId: category?.id);
  }
}
