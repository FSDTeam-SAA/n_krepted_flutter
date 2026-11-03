import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl/intl.dart';
import '../../data/models/deal_model.dart';
import '../utils/open_external_link.dart';
import '../utils/currency_formatter.dart';
import 'discovery_widgets.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
export '../utils/description_text.dart' show plainDescription;

class FormattedText extends StatelessWidget {
  final String value;
  const FormattedText(this.value, {super.key});
  @override
  Widget build(BuildContext context) => HtmlWidget(
    value.contains(RegExp(r'<[a-zA-Z]'))
        ? value
        : '<p>${value.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('\n', '<br>')}</p>',
    textStyle: const TextStyle(
      fontSize: AppFontSizes.body,
      height: 1.6,
      color: AppColors.textBody,
    ),
    customStylesBuilder: (element) {
      final styles = <String, String>{};
      if (element.localName == 'p') {
        styles['margin'] = '0 0 8px';
      }
      for (final align in ['center', 'right', 'justify']) {
        if (element.classes.contains('ql-align-$align')) {
          styles['text-align'] = align;
        }
      }
      return styles.isEmpty ? null : styles;
    },
    onTapUrl: (url) async {
      await openExternalLink(context, url);
      return true;
    },
  );
}

class SignatureBadge extends StatelessWidget {
  const SignatureBadge({super.key});
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    widthFactor: 1,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1B8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD49D22)),
      ),
      child: const Text(
        '★ Signature Dish',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF755100),
        ),
      ),
    ),
  );
}

class FoodTags extends StatelessWidget {
  final List<String> tags;
  const FoodTags(this.tags, {super.key});
  @override
  Widget build(BuildContext context) => tags.isEmpty
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: 12),
          child: LayoutBuilder(
            builder: (context, constraints) => Wrap(
              spacing: 6,
              runSpacing: 4,
              children: tags
                  .map(
                    (tag) => ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth,
                      ),
                      child: Chip(
                        label: Text(
                          tag,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
}

class PromotionList extends StatefulWidget {
  final DealModel restaurant;
  final DealDish? dish;
  const PromotionList(this.restaurant, {super.key, this.dish});
  @override
  State<PromotionList> createState() => _PromotionListState();
}

class _PromotionListState extends State<PromotionList> {
  final List<Timer> _timers = [];
  final Set<PromotionModel> _expired = {};
  @override
  void initState() {
    super.initState();
    _scheduleExpiry();
  }

  @override
  void didUpdateWidget(covariant PromotionList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleExpiry();
  }

  void _scheduleExpiry() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
    _expired.clear();
    final now = DateTime.now();
    for (final promotion in widget.restaurant.promotions) {
      final end = promotion.endsAt;
      if (end == null) continue;
      if (!end.isAfter(now)) {
        _expired.add(promotion);
        continue;
      }
      _timers.add(
        Timer(end.difference(now), () {
          if (mounted) setState(() => _expired.add(promotion));
        }),
      );
    }
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: widget.restaurant.promotions
        .where(
          (p) =>
              !_expired.contains(p) &&
              (widget.dish == null ||
                  p.dishId.isEmpty ||
                  p.dishId == widget.dish!.id),
        )
        .map(
          (p) => Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8DD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (p.bannerUrl.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: RemotePhoto(p.bannerUrl),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  p.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (p.text.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(p.text, style: const TextStyle(height: 1.5)),
                ],
                if (p.discountType != 'none')
                  Text(
                    p.discountType == 'percent'
                        ? '${p.discountValue.toStringAsFixed(0)} % Rabatt'
                        : '${formatEuro(context, p.discountValue)} Rabatt',
                  ),
                if (widget.dish != null && p.discountType != 'none')
                  Text(
                    '${formatEuro(context, widget.dish!.price)} → ${formatEuro(context, p.price(widget.dish!.price))}',
                  ),
                if (p.endsAt != null)
                  Text(
                    'Gültig bis ${DateFormat('dd.MM.yyyy HH:mm').format(p.endsAt!.toLocal())}',
                    style: const TextStyle(fontSize: 11),
                  ),
              ],
            ),
          ),
        )
        .toList(),
  );
}
