import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../../data/repositories/site_content_repository.dart';
import 'feature_content.dart';
import 'discovery_widgets.dart';

enum LegalDocumentType { terms, privacy, impressum }

class LegalDocumentBody extends StatefulWidget {
  final LegalDocumentType type;
  const LegalDocumentBody({super.key, required this.type});
  @override
  State<LegalDocumentBody> createState() => _LegalState();
}

class _LegalState extends State<LegalDocumentBody> {
  String? _html;
  bool _failed = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _html = null;
      _failed = false;
    });
    try {
      final c = await SiteContentRepository().getLegalContent();
      if (mounted) {
        setState(
          () => _html = switch (widget.type) {
            LegalDocumentType.terms => c.termsHtml,
            LegalDocumentType.privacy => c.privacyHtml,
            LegalDocumentType.impressum => c.impressumHtml,
          },
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _html = '';
          _failed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: _html == null
        ? const Center(child: CircularProgressIndicator())
        : _html!.isEmpty
        ? DataState(
            _failed
                ? 'Inhalt konnte nicht geladen werden.'
                : 'Dieser Inhalt wurde noch nicht veröffentlicht.',
            onRetry: _failed ? _load : null,
          )
        : SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: FormattedText(_html!),
          ),
  );
}
