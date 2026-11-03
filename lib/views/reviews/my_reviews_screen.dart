import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/review_card.dart';
import '../../data/models/review_model.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});
  @override
  State<MyReviewsScreen> createState() => _MyReviewsState();
}

class _MyReviewsState extends State<MyReviewsScreen> {
  final _api = ApiClient();
  List<ReviewModel> _reviews = [];
  bool _loading = true, _more = true;
  int _page = 0;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool more = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = more ? _page + 1 : 1;
      final response = await _api.get(
        '/reviews',
        queryParameters: {'mine': 'true', 'page': page, 'limit': 20},
      );
      final reviews = (response.data['data'] as List)
          .map((v) => ReviewModel.fromJson(v))
          .toList();
      if (mounted) {
        setState(() {
          _reviews = more ? [..._reviews, ...reviews] : reviews;
          _page = page;
          _more = page < (response.data['meta']['totalPages'] as num);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Bewertungen konnten nicht geladen werden.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _remove(ReviewModel review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Bewertung löschen?'),
        content: const Text('Ihre Bewertung wird aus der App entfernt.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _api.delete('/reviews/${review.id}');
      if (mounted) _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Löschen fehlgeschlagen.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Meine Bewertungen')),
    body: RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          if (_loading) const LinearProgressIndicator(),
          if (_error != null)
            TextButton(
              onPressed: _load,
              child: Text('$_error Erneut versuchen'),
            ),
          for (final r in _reviews)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  r.restaurantName ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ReviewCard(review: r),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _remove(r),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Löschen'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          if (!_loading && _reviews.isEmpty && _error == null)
            const Text('Noch keine Bewertungen.'),
          if (_more && !_loading && _reviews.isNotEmpty)
            TextButton(
              onPressed: () => _load(more: true),
              child: const Text('Mehr laden'),
            ),
        ],
      ),
    ),
  );
}
