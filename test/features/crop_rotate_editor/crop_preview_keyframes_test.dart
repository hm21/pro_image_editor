// Fail fast: a hang in the editor would otherwise sit out the 10 min default.
@Timeout(Duration(seconds: 45))
library;

// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
// Flutter imports:
import 'package:material_ui/material_ui.dart';
// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/layer/layer_widget.dart';
import 'package:pro_image_editor/shared/widgets/transform/transformed_content_generator.dart';

// The crop editor previews a video's layers at the playback position, so a
// keyframed layer has to sit on the image point the main editor shows it on,
// also once the image is cropped, turned and flipped.
void main() {
  const configs = ProImageEditorConfigs(
    progressIndicatorConfigs: ProgressIndicatorConfigs(
      widgets: ProgressIndicatorWidgets(
        circularProgressIndicator: SizedBox.shrink(),
      ),
    ),
    imageGeneration: ImageGenerationConfigs(
      enableIsolateGeneration: false,
      enableBackgroundGeneration: false,
    ),
  );

  const videoKey = ValueKey('video');

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<(ProImageEditorState, ProVideoController)> pumpVideoEditor(
    WidgetTester tester,
  ) async {
    final key = GlobalKey<ProImageEditorState>();
    final controller = ProVideoController(
      videoPlayer: const SizedBox.expand(key: videoKey),
      videoDuration: const Duration(seconds: 10),
      initialResolution: const Size(1080, 1920),
      fileSize: 1,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: ProImageEditor.video(
          controller,
          key: key,
          configs: configs,
          callbacks: const ProImageEditorCallbacks(),
        ),
      ),
    );
    // The video canvas waits for a real image encode and decode, which fake
    // async never completes.
    await tester.runAsync(() async {
      for (var i = 0; i < 100 && find.byKey(videoKey).evaluate().isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        await tester.pump();
      }
    });
    expect(find.byKey(videoKey), findsWidgets);
    return (key.currentState!, controller);
  }

  Finder filteredImageIn(Finder scope) => find
      .descendant(
        of: scope,
        matching: find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == 'FilteredWidget',
        ),
      )
      .first;

  /// Where the content of the text layer [text] in [scope] is shown, as a
  /// fraction of [image] from its top-left. Every transform counts, the
  /// keyframed placement included.
  Offset shownOn(Finder image, Finder scope, String text) {
    final imageBox = image.evaluate().first.renderObject! as RenderBox;
    final layer = find.descendant(
      of: scope,
      matching: find.byWidgetPredicate(
        (w) =>
            w is LayerWidget &&
            w.layer is TextLayer &&
            (w.layer as TextLayer).text == text,
      ),
    );
    final content = find
        .descendant(of: layer.first, matching: find.byType(FittedBox))
        .first;
    final box = content.evaluate().first.renderObject! as RenderBox;
    final local = imageBox.globalToLocal(
      box.localToGlobal(box.size.center(Offset.zero)),
    );
    return Offset(
      local.dx / imageBox.size.width,
      local.dy / imageBox.size.height,
    );
  }

  Future<void> cropOffCenter(
    WidgetTester tester,
    ProImageEditorState editor,
  ) async {
    editor.openCropRotateEditor();
    await settle(tester);
    final crop = editor.cropRotateEditor.currentState!..rotate();
    await settle(tester);
    crop.flip();
    await settle(tester);
    crop.updateAspectRatio(1);
    await settle(tester);
    crop.setScale(1.6);
    await settle(tester);
    await tester.dragFrom(
      tester.getCenter(find.byType(CropRotateEditor)),
      const Offset(60, 40),
    );
    await settle(tester);
    // done() screenshots the layers, which needs real async work; awaiting it
    // inside the fake-async zone never completes. Pump until it finishes.
    var finished = false;
    unawaited(crop.done().whenComplete(() => finished = true));
    for (var i = 0; i < 40 && !finished; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(finished, isTrue, reason: 'crop done() did not complete');
    await settle(tester);
  }

  testWidgets('previews a keyframed layer where the main editor shows it', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(400, 860);

    final (editor, controller) = await pumpVideoEditor(tester);
    editor.addLayer(
      TextLayer(
        text: 'kf',
        // Away from the keyframes, so a preview at the rest placement shows
        // the layer elsewhere.
        offset: const Offset(30, 50),
        startTime: Duration.zero,
        endTime: const Duration(seconds: 10),
        keyframes: const [
          LayerKeyframe(time: Duration.zero, offset: Offset(40, -60)),
          LayerKeyframe(time: Duration(seconds: 4), offset: Offset(-40, 60)),
        ],
      ),
      autoCorrectZoomOffset: false,
      autoCorrectZoomScale: false,
    );
    controller.setPlayTime(const Duration(seconds: 1));
    await settle(tester);

    await cropOffCenter(tester, editor);
    expect(editor.stateManager.transformConfigs.isEmpty, isFalse);
    final mainEditor = find.byType(ProImageEditor);
    final expected = shownOn(
      filteredImageIn(
        find.descendant(
          of: mainEditor,
          matching: find.byType(TransformedContentGenerator),
        ),
      ),
      mainEditor,
      'kf',
    );

    editor.openCropRotateEditor();
    await settle(tester);
    final cropEditor = find.byType(CropRotateEditor);
    final actual = shownOn(filteredImageIn(cropEditor), cropEditor, 'kf');
    editor.cropRotateEditor.currentState!.close();
    await settle(tester);

    expect(
      (actual - expected).distance,
      lessThan(0.005),
      reason: 'expected $expected, got $actual',
    );
  });
}
