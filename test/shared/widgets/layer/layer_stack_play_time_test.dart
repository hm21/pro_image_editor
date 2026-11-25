// Package imports:
import 'package:flutter_test/flutter_test.dart';
// Flutter imports:
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/core/models/transform_helper.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/layer/layer_stack.dart';
import 'package:pro_image_editor/shared/widgets/layer/layer_widget.dart';
import 'package:pro_image_editor/shared/widgets/layer/widgets/invisible_but_painted.dart';

const Size _body = Size(200, 300);

TextLayer _caption(String text, {required int startMs, required int endMs}) =>
    TextLayer(text: text)
      ..startTime = Duration(milliseconds: startMs)
      ..endTime = Duration(milliseconds: endMs);

Future<void> _pumpStack(
  WidgetTester tester,
  List<Layer> layers, {
  ValueNotifier<Duration>? playTimeNotifier,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Center(
        child: SizedBox.fromSize(
          size: _body,
          child: LayerStack(
            configs: const ProImageEditorConfigs(),
            layers: layers,
            overlayColor: Colors.black,
            transformHelper: const TransformHelper(
              editorBodySize: _body,
              mainBodySize: _body,
              mainImageSize: _body,
            ),
            playTimeNotifier: playTimeNotifier,
          ),
        ),
      ),
    ),
  );
}

/// Whether the timeline hides [layer]: it is still painted, for captures and
/// hero flights, but shows nothing.
bool _isHidden(Layer layer) => find
    .descendant(
      of: find.byWidgetPredicate(
        (widget) => widget is LayerWidget && widget.layer.id == layer.id,
      ),
      matching: find.byType(InvisibleButPainted),
    )
    .evaluate()
    .isNotEmpty;

void main() {
  group('LayerStack play time', () {
    late ValueNotifier<Duration> playTime;

    setUp(() => playTime = ValueNotifier(Duration.zero));
    tearDown(() => playTime.dispose());

    testWidgets('shows only the layers whose window holds the position', (
      tester,
    ) async {
      final first = _caption('First', startMs: 0, endMs: 1000);
      final second = _caption('Second', startMs: 1500, endMs: 2500);
      playTime.value = const Duration(milliseconds: 500);
      await _pumpStack(tester, [first, second], playTimeNotifier: playTime);

      expect(_isHidden(first), isFalse);
      expect(_isHidden(second), isTrue);

      playTime.value = const Duration(seconds: 2);
      await tester.pump();

      expect(_isHidden(first), isTrue);
      expect(_isHidden(second), isFalse);
    });

    testWidgets('hides a layer at its end time, as the export does', (
      tester,
    ) async {
      final first = _caption('First', startMs: 0, endMs: 1000);
      final second = _caption('Second', startMs: 1000, endMs: 2000);
      playTime.value = const Duration(milliseconds: 999);
      await _pumpStack(tester, [first, second], playTimeNotifier: playTime);

      expect(_isHidden(first), isFalse);
      expect(_isHidden(second), isTrue);

      playTime.value = const Duration(seconds: 1);
      await tester.pump();

      expect(_isHidden(first), isTrue);
      expect(_isHidden(second), isFalse);
    });

    testWidgets('shows every layer without a play time', (tester) async {
      final first = _caption('First', startMs: 0, endMs: 1000);
      final second = _caption('Second', startMs: 1500, endMs: 2500);
      await _pumpStack(tester, [first, second]);

      expect(find.byType(LayerWidget), findsNWidgets(2));
      expect(_isHidden(first), isFalse);
      expect(_isHidden(second), isFalse);
    });
  });
}
