import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/features/text_editor/utils/rounded_background_painter.dart';

void main() {
  group(RoundedBackgroundTextPainter, () {
    RoundedBackgroundTextPainter painterFor(InlineSpan text) {
      return RoundedBackgroundTextPainter(
        backgroundColor: const Color(0xFF0000FF),
        painter: TextPainter(text: text, textDirection: TextDirection.ltr)
          ..layout(),
        onHitTestResult: null,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        hitBoxCorrectionOffset: Offset.zero,
      );
    }

    TextSpan helloWorld({required Color worldColor}) => TextSpan(
      style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 20),
      children: [
        const TextSpan(text: 'Hello '),
        TextSpan(
          text: 'world',
          style: TextStyle(color: worldColor),
        ),
      ],
    );

    group('shouldRepaint', () {
      test('repaints when only the color of a span changes', () {
        final plain = painterFor(
          helloWorld(worldColor: const Color(0xFFFFFFFF)),
        );
        final lit = painterFor(helloWorld(worldColor: const Color(0xFFFFD60A)));

        expect(lit.shouldRepaint(plain), isTrue);
      });

      test('does not repaint for the same text and colors', () {
        final first = painterFor(
          helloWorld(worldColor: const Color(0xFFFFD60A)),
        );
        final second = painterFor(
          helloWorld(worldColor: const Color(0xFFFFD60A)),
        );

        expect(second.shouldRepaint(first), isFalse);
      });
    });
  });
}
