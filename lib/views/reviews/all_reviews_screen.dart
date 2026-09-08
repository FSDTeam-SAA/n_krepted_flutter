import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/discovery_widgets.dart';
import '../../core/widgets/review_card.dart';
import '../../core/widgets/owner_page_background.dart';
import '../../providers/review_provider.dart';
import '../../providers/auth_provider.dart';
import 'write_review_screen.dart';
import '../home/dessert_suggestion.dart';

class AllReviewsScreen extends StatefulWidget {
  final String dealId;
  final String? dishId;
  const AllReviewsScreen({super.key, required this.dealId, this.dishId});
  @override
  State<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() =>
      context.read<ReviewProvider>().fetchReviewsForDeal(widget.dealId);
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReviewProvider>();
    final reviews = provider
        .reviewsForDeal(widget.dealId)
        .where((r) => widget.dishId == null || r.dishId == widget.dishId)
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Rezensionen')),
      bottomNavigationBar:
          context.watch<AuthProvider>().currentUser?.role == 'user'
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final changed = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WriteReviewScreen(
                          dealId: widget.dealId,
                          dishId: widget.dishId,
                        ),
                      ),
                    );
                    if (changed == true && mounted) {
                      await _load();
                      if (context.mounted) await showDessertSuggestion(context);
                    }
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Schildern Sie Ihre Erfahrungen'),
                ),
              ),
            )
          : null,
      body: OwnerPageBackground(
        child: provider.isLoadingFor(widget.dealId)
            ? const Center(child: CircularProgressIndicator())
            : provider.errorFor(widget.dealId) != null
            ? DataState(provider.errorFor(widget.dealId)!, onRetry: _load)
            : reviews.isEmpty
            ? const DataState('Noch keine Bewertungen vorhanden.')
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: reviews.length,
                  itemBuilder: (_, index) => ReviewCard(review: reviews[index]),
                ),
              ),
      ),
    );
  }
}
