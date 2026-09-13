import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/check_in_model.dart';
import '../../providers/check_in_provider.dart';
import '../../core/constants/app_text_styles.dart';

enum OwnerActivityType { checkIns, viewers }

class OwnerActivityScreen extends StatefulWidget {
  final OwnerActivityType type;

  const OwnerActivityScreen({super.key, required this.type});

  @override
  State<OwnerActivityScreen> createState() => _OwnerActivityScreenState();
}

class _OwnerActivityScreenState extends State<OwnerActivityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<CheckInProvider>().fetchOwnerCheckIns(),
    );
  }

  List<CheckInModel> _items(List<CheckInModel> source) {
    if (widget.type == OwnerActivityType.checkIns) return source;
    final unique = <String, CheckInModel>{};
    for (final item in source) {
      if (item.userId.isNotEmpty) unique.putIfAbsent(item.userId, () => item);
    }
    return unique.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckInProvider>();
    final items = _items(provider.checkIns);
    final isCheckIns = widget.type == OwnerActivityType.checkIns;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isCheckIns ? 'Einchecken' : 'Zuschauer',
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: AppFontSizes.titleLarge,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          const Positioned(
            right: -40,
            top: -45,
            child: _PageDecoration(
              asset: AppAssets.homeDecoHerbs,
              width: 120,
              opacity: .28,
            ),
          ),
          const Positioned(
            left: -45,
            top: 140,
            child: _PageDecoration(
              asset: AppAssets.homeDecoCoffee,
              width: 112,
              opacity: .12,
            ),
          ),
          const Positioned(
            right: -35,
            bottom: -20,
            child: _PageDecoration(
              asset: AppAssets.decoSkewers,
              width: 142,
              opacity: .32,
            ),
          ),
          if (provider.isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          else if (items.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  provider.errorMessage ??
                      (isCheckIns
                          ? 'Noch keine Check-ins vorhanden.'
                          : 'Noch keine Besucher vorhanden.'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textGrey),
                ),
              ),
            )
          else
            RefreshIndicator(
              color: AppColors.primary,
              onRefresh: provider.fetchOwnerCheckIns,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, index) => _OwnerPersonTile(
                  item: items[index],
                  showPartySize: isCheckIns,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OwnerPersonTile extends StatelessWidget {
  final CheckInModel item;
  final bool showPartySize;

  const _OwnerPersonTile({required this.item, required this.showPartySize});

  @override
  Widget build(BuildContext context) {
    final user = item.user;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFEAF8FA),
            backgroundImage: user?.avatar?.isNotEmpty == true
                ? CachedNetworkImageProvider(user!.avatar!)
                : null,
            child: user?.avatar?.isNotEmpty == true
                ? null
                : const Icon(
                    Icons.person_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name.trim().isNotEmpty == true
                      ? user!.name
                      : 'Unbekannter Benutzer',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: AppFontSizes.body,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (user?.email.trim().isNotEmpty == true)
                  Text(
                    user!.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: AppFontSizes.tinyPlus,
                      color: AppColors.textGrey,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('dd.MM.yyyy').format(item.checkedInAt.toLocal()),
                style: const TextStyle(
                  fontSize: AppFontSizes.tinyPlus,
                  color: AppColors.textGrey,
                ),
              ),
              if (showPartySize) ...[
                const SizedBox(height: 3),
                Text(
                  '${item.partySize} Personen',
                  style: const TextStyle(
                    fontSize: AppFontSizes.tiny,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PageDecoration extends StatelessWidget {
  final String asset;
  final double width;
  final double opacity;

  const _PageDecoration({
    required this.asset,
    required this.width,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Opacity(
      opacity: opacity,
      child: Image.asset(asset, width: width, fit: BoxFit.contain),
    ),
  );
}
