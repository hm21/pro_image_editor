import 'package:flutter/widgets.dart';

/// [text] in capital letters, with every character kept at its UTF-16
/// length.
///
/// The length is what lets a layer draw its text in capitals while the
/// stored text, its cursor positions, its highlights and its reveal steps
/// keep pointing at the same characters. A character whose capital is longer
/// is kept as it is, apart from `ß`, which becomes `ẞ`.
String textInCapitals(String text) {
  final buffer = StringBuffer();
  for (final rune in text.runes) {
    final character = String.fromCharCode(rune);
    if (character == 'ß') {
      buffer.write('ẞ');
      continue;
    }
    final capital = character.toUpperCase();
    buffer.write(capital.length == character.length ? capital : character);
  }
  return buffer.toString();
}

/// A copy of [span] whose text, and the text of every span below it, is in
/// capitals (see [textInCapitals]).
TextSpan spanInCapitals(TextSpan span) {
  return TextSpan(
    text: span.text == null ? null : textInCapitals(span.text!),
    style: span.style,
    children: span.children
        ?.map((child) => child is TextSpan ? spanInCapitals(child) : child)
        .toList(),
    recognizer: span.recognizer,
    mouseCursor: span.mouseCursor,
    onEnter: span.onEnter,
    onExit: span.onExit,
    semanticsLabel: span.semanticsLabel,
    semanticsIdentifier: span.semanticsIdentifier,
    locale: span.locale,
    spellOut: span.spellOut,
  );
}

/// A [TextEditingController] that can show its text in capitals while
/// [text] keeps the letters as they were typed.
///
/// The capitals have the same length as the typed text (see
/// [textInCapitals]), so the cursor and the selection stay where they are.
class CapitalsTextEditingController extends TextEditingController {
  /// Whether the text shows in capitals.
  bool get capitals => _capitals;
  bool _capitals = false;
  set capitals(bool value) {
    if (_capitals == value) return;
    _capitals = value;
    notifyListeners();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final span = super.buildTextSpan(
      context: context,
      style: style,
      withComposing: withComposing,
    );
    return _capitals ? spanInCapitals(span) : span;
  }
}
