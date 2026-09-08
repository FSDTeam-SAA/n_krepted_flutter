import 'package:flutter/material.dart';

import '../../data/repositories/site_content_repository.dart';
import '../constants/app_colors.dart';
import 'discovery_widgets.dart';

enum LegalDocumentType { terms, privacy }

class LegalDocumentBody extends StatefulWidget {
  final LegalDocumentType type;

  const LegalDocumentBody({super.key, required this.type});

  @override
  State<LegalDocumentBody> createState() => _LegalDocumentBodyState();
}

class _LegalDocumentBodyState extends State<LegalDocumentBody> {
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
      final content = await SiteContentRepository().getLegalContent();
      final html = widget.type == LegalDocumentType.terms
          ? content.termsHtml
          : content.privacyHtml;
      if (mounted) setState(() => _html = html.trim());
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
  Widget build(BuildContext context) {
    if (_html == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_html!.isEmpty) {
      return DataState(
        _failed
            ? 'Inhalt konnte nicht geladen werden.'
            : 'Dieser Inhalt wurde noch nicht veröffentlicht.',
        onRetry: _failed ? _load : null,
      );
    }
    return _RestrictedHtmlDocument(html: _html!);
  }
}

class _RestrictedHtmlDocument extends StatelessWidget {
  final String html;

  const _RestrictedHtmlDocument({required this.html});

  @override
  Widget build(BuildContext context) {
    final blocks = _parseBlocks(html);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: blocks
            .map(
              (block) => Padding(
                padding: const EdgeInsets.only(bottom: 13),
                child: Text.rich(
                  TextSpan(
                    style: _styleFor(block.kind),
                    children: [
                      if (block.kind == 'li') const TextSpan(text: '•  '),
                      ..._inlineSpans(block.html, _styleFor(block.kind)),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  TextStyle _styleFor(String kind) {
    if (kind == 'h1') {
      return const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        height: 1.3,
      );
    }
    if (kind == 'h2') {
      return const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        height: 1.35,
      );
    }
    if (kind == 'h3') {
      return const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        height: 1.4,
      );
    }
    if (kind == 'h4') {
      return const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        height: 1.4,
      );
    }
    if (kind == 'h5') {
      return const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
        height: 1.45,
      );
    }
    if (kind == 'h6') {
      return const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
        height: 1.45,
      );
    }
    if (kind == 'blockquote') {
      return const TextStyle(
        fontSize: 14,
        fontStyle: FontStyle.italic,
        color: AppColors.primaryDark,
        height: 1.5,
      );
    }
    return const TextStyle(
      fontSize: 14,
      color: AppColors.textGrey,
      height: 1.5,
    );
  }

  List<_HtmlBlock> _parseBlocks(String source) {
    final matches = RegExp(
      r'<(h1|h2|h3|h4|h5|h6|p|li|blockquote)\b[^>]*>(.*?)</\1>',
      caseSensitive: false,
      dotAll: true,
    ).allMatches(source);
    final blocks = matches
        .map(
          (match) =>
              _HtmlBlock(match.group(1)!.toLowerCase(), match.group(2) ?? ''),
        )
        .where((block) => _plainText(block.html).isNotEmpty)
        .toList();
    if (blocks.isNotEmpty) return blocks;
    return [_HtmlBlock('p', source)];
  }

  List<InlineSpan> _inlineSpans(String source, TextStyle baseStyle) {
    final tagPattern = RegExp(
      r'<\s*(/?)\s*(strong|b|em|i|u|a|br)\b[^>]*>',
      caseSensitive: false,
    );
    final spans = <InlineSpan>[];
    final styleStack = <TextStyle>[];
    var style = baseStyle;
    var cursor = 0;

    for (final match in tagPattern.allMatches(source)) {
      if (match.start > cursor) {
        spans.add(
          TextSpan(
            text: _decodeEntities(source.substring(cursor, match.start)),
            style: style,
          ),
        );
      }
      final closing = match.group(1) == '/';
      final tag = match.group(2)!.toLowerCase();
      if (tag == 'br') {
        spans.add(TextSpan(text: '\n', style: style));
      } else if (closing) {
        if (styleStack.isNotEmpty) style = styleStack.removeLast();
      } else {
        styleStack.add(style);
        style = switch (tag) {
          'strong' || 'b' => style.copyWith(fontWeight: FontWeight.w700),
          'em' || 'i' => style.copyWith(fontStyle: FontStyle.italic),
          'u' => style.copyWith(decoration: TextDecoration.underline),
          'a' => style.copyWith(
            color: AppColors.primary,
            decoration: TextDecoration.underline,
          ),
          _ => style,
        };
      }
      cursor = match.end;
    }
    if (cursor < source.length) {
      spans.add(
        TextSpan(text: _decodeEntities(source.substring(cursor)), style: style),
      );
    }
    return spans;
  }

  String _plainText(String value) => _decodeEntities(
    value
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), ''),
  ).trim();

  String _decodeEntities(String value) => value
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'");
}

class _HtmlBlock {
  final String kind;
  final String html;

  const _HtmlBlock(this.kind, this.html);
}
