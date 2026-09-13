import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/discovery_widgets.dart';
import '../../core/widgets/owner_page_background.dart';
import '../../core/network/api_error.dart';
import '../../data/models/review_model.dart';
import '../../providers/review_provider.dart';
import '../../providers/deal_provider.dart';
import '../booking_checkin/checkin_screen.dart';
import '../../core/constants/app_text_styles.dart';

class WriteReviewScreen extends StatefulWidget {
  final String dealId;
  final String? dishId;
  const WriteReviewScreen({super.key, required this.dealId, this.dishId});
  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  int _rating = 0;
  String? _dishId, _error;
  ReviewEligibility? _eligibility;
  bool _loading = true, _saving = false;
  final _comment = TextEditingController();
  final _form = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _dishId = widget.dishId;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await context
          .read<ReviewProvider>()
          .reviewRepository
          .getEligibility(widget.dealId);
      if (!mounted) return;
      setState(() {
        _eligibility = result;
        if (!result.dishes.any((d) => d.id == _dishId)) _dishId = null;
      });
    } catch (error) {
      if (mounted) setState(() => _error = friendlyApiError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _checkIn() async {
    final restaurant = await context.read<DealProvider>().getDealDetails(
      widget.dealId,
    );
    if (!mounted) return;
    if (restaurant == null) {
      _message('Restaurant konnte nicht geladen werden.');
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CheckinScreen(deal: restaurant)),
    );
    if (mounted) _load();
  }

  void _message(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
  Future<void> _submit() async {
    if (_saving || !_form.currentState!.validate()) return;
    if (_rating < 1) {
      _message('Bitte eine Bewertung auswählen.');
      return;
    }
    final checkIn = _eligibility?.checkIn;
    if (checkIn == null) return;
    setState(() => _saving = true);
    final provider = context.read<ReviewProvider>();
    final success = await provider.addReview(
      dealId: widget.dealId,
      checkInId: checkIn.id,
      dishId: _dishId,
      ratings: _rating.toDouble(),
      reviewComment: _comment.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (success) {
      _message('Vielen Dank für Ihre Bewertung!');
      Navigator.pop(context, true);
    } else {
      _message(
        provider.errorMessage ?? 'Bewertung konnte nicht gespeichert werden.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final visit = _eligibility?.checkIn;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Schildern Sie Ihre Erfahrungen',
          style: TextStyle(fontSize: AppFontSizes.title),
        ),
      ),
      body: OwnerPageBackground(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? DataState(_error!, onRetry: _load)
            : _eligibility?.eligible != true || visit == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Checken Sie zuerst vor Ort ein, um Ihren Besuch zu bewerten.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _checkIn,
                        icon: const Icon(Icons.my_location),
                        label: const Text('Jetzt einchecken'),
                      ),
                      TextButton(
                        onPressed: _load,
                        child: const Text('Erneut prüfen'),
                      ),
                    ],
                  ),
                ),
              )
            : Form(
                key: _form,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _section(
                      'Bewertung',
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          5,
                          (i) => IconButton(
                            tooltip: '${i + 1} Sterne',
                            onPressed: () => setState(() => _rating = i + 1),
                            icon: Icon(
                              i < _rating ? Icons.star : Icons.star_border,
                              color: AppColors.orangeAccent,
                              size: 34,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _section(
                      'Datum des Besuchs',
                      Row(
                        children: [
                          for (final part in ['dd', 'MM', 'yyyy'])
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: _value(
                                  DateFormat(
                                    part,
                                  ).format(visit.checkedInAt.toLocal()),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    _section(
                      'Uhrzeit des Besuchs',
                      Row(
                        children: [
                          Expanded(
                            child: _value(
                              DateFormat(
                                'hh:mm',
                              ).format(visit.checkedInAt.toLocal()),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 95,
                            child: _value(
                              DateFormat(
                                'a',
                              ).format(visit.checkedInAt.toLocal()),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_eligibility!.dishes.isNotEmpty)
                      _section(
                        'Verzehrtes Gericht',
                        DropdownButtonFormField<String>(
                          initialValue: _dishId,
                          isExpanded: true,
                          decoration: _decoration(),
                          hint: const Text('Gericht auswählen'),
                          items: _eligibility!.dishes
                              .map(
                                (dish) => DropdownMenuItem(
                                  value: dish.id,
                                  child: Text(
                                    dish.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(() => _dishId = value),
                          validator: (value) =>
                              value == null ? 'Bitte Gericht auswählen.' : null,
                        ),
                      ),
                    _section(
                      'Anzahl der Personen',
                      _value('${visit.partySize} Personen'),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Datum, Uhrzeit und Personen stammen aus Ihrem verifizierten Check-in.',
                        style: TextStyle(
                          fontSize: AppFontSizes.captionSmall,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),
                    _section(
                      'Ihre Bewertung',
                      TextFormField(
                        controller: _comment,
                        maxLines: 4,
                        maxLength: 4000,
                        decoration: _decoration().copyWith(
                          hintText: 'Hier schreiben!',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Bitte Bewertung eingeben.'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Bestätigen',
                      isLoading: _saving,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  InputDecoration _decoration() => InputDecoration(
    contentPadding: const EdgeInsets.all(12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.cyan),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.cyan),
    ),
  );
  Widget _value(String text) => InputDecorator(
    decoration: _decoration(),
    child: Text(text, style: const TextStyle(color: AppColors.textGrey)),
  );
  Widget _section(String title, Widget child) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.cardBorder),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: AppFontSizes.body,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}
