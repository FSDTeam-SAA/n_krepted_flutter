import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parseFragment;

/// Plain editable text, with entity decoding and paragraph boundaries preserved.
String plainDescription(String value) {
  if (!RegExp(r'<[a-zA-Z/!]').hasMatch(value)) return value.trim();
  final fragment = parseFragment(value);
  const blocks = {
    'p',
    'div',
    'li',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'blockquote',
  };
  String text(dom.Node node) {
    if (node is dom.Text) return node.data;
    if (node is dom.Element) {
      if (node.localName == 'script' || node.localName == 'style') return '';
      if (node.localName == 'br') return '\n';
      final children = node.nodes.map(text).join();
      return blocks.contains(node.localName) ? '$children\n' : children;
    }
    return node.nodes.map(text).join();
  }

  return text(
    fragment,
  ).replaceAll('\u00a0', ' ').replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
}

/// Saving an unrelated field must not discard formatting authored on dashboard.
String descriptionForSubmission(String original, String edited) =>
    plainDescription(original) == edited.trim() ? original : edited.trim();

/// Forms display new photos first; multipart uploads retain saved photos first.
int leadImageSubmissionIndex(
  int displayedIndex,
  int newCount,
  int existingCount,
) {
  final count = newCount + existingCount;
  if (count == 0) return 0;
  final index = displayedIndex.clamp(0, count - 1);
  return index < newCount ? existingCount + index : index - newCount;
}
