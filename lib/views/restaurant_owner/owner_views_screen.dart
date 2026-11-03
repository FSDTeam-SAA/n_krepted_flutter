import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/owner_page_background.dart';

class OwnerViewsScreen extends StatefulWidget {
  const OwnerViewsScreen({super.key});
  @override
  State<OwnerViewsScreen> createState() => _ViewsState();
}

class _ViewsState extends State<OwnerViewsScreen> {
  List<Map<String, dynamic>> _views = [];
  bool _loading = true, _more = true;
  String? _error;
  int _page = 0;
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
      final response = await ApiClient().get(
        '/owner/views',
        queryParameters: {'page': page, 'limit': 50},
      );
      final rows = (response.data['data'] as List)
          .map((v) => Map<String, dynamic>.from(v))
          .toList();
      if (mounted) {
        setState(() {
          _views = more ? [..._views, ...rows] : rows;
          _page = page;
          _more = page < (response.data['meta']['totalPages'] as num);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Aufrufe konnten nicht geladen werden.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Restaurantaufrufe')),
    body: OwnerPageBackground(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.pagePadding,
          children: [
            if (_loading) const LinearProgressIndicator(),
            if (_error != null)
              TextButton(
                onPressed: _load,
                child: Text('$_error Erneut versuchen'),
              ),
            for (final v in _views)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.cardBorder),
                  ),
                  leading: const Icon(Icons.visibility_outlined),
                  title: Text(v['name'].toString()),
                  subtitle: Text(
                    DateFormat(
                      'dd.MM.yyyy HH:mm',
                    ).format(DateTime.parse(v['viewedAt']).toLocal()),
                  ),
                ),
              ),
            if (!_loading && _views.isEmpty && _error == null)
              const ListTile(title: Text('Noch keine Aufrufe.')),
            if (_more && !_loading && _views.isNotEmpty)
              TextButton(
                onPressed: () => _load(more: true),
                child: const Text('Mehr laden'),
              ),
          ],
        ),
      ),
    ),
  );
}
