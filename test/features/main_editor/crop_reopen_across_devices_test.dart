// Fail fast: a hang in the editor would otherwise sit out the 10 min default.
@Timeout(Duration(seconds: 45))
library;

// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/services.dart';
// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/layer/layer_stack.dart';
import 'package:pro_image_editor/shared/widgets/layer/layer_widget.dart';
import 'package:pro_image_editor/shared/widgets/transform/transformed_content_generator.dart';

// A layer must stay on the same pixel of the image when a crop is applied,
// undone, or reopened on a screen of another size. Positions are measured on
// what is painted, in raw image pixels.
void main() {
  const configs = ProImageEditorConfigs(
    i18n: I18n(importStateHistoryMsg: ''),
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

  const rawSize = Size(900, 600);

  const surfaces = <String, Size>{
    'desktop': Size(1600, 1000),
    'phone': Size(400, 860),
    'tablet': Size(1024, 1366),
    'ultrawide': Size(2400, 800),
  };

  Future<Uint8List> makePng() async {
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawRect(
      Offset.zero & rawSize,
      ui.Paint()..color = const Color(0xFF3366AA),
    );
    final image = await recorder.endRecording().toImage(
      rawSize.width.toInt(),
      rawSize.height.toInt(),
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  void setSurface(WidgetTester tester, String name) {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = surfaces[name]!;
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<ProImageEditorState> pumpEditor(
    WidgetTester tester,
    Uint8List bytes, {
    String? historyJson,
    bool blank = false,
  }) async {
    final key = GlobalKey<ProImageEditorState>();
    final editorConfigs = configs.copyWith(
      stateHistory: StateHistoryConfigs(
        initStateHistory: historyJson == null
            ? null
            : ImportStateHistory.fromJson(historyJson),
      ),
    );
    final callbacks = ProImageEditorCallbacks(
      onImageEditingComplete: (_) async {},
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      MaterialApp(
        home: blank
            ? ProImageEditor.blank(
                rawSize,
                key: key,
                configs: editorConfigs,
                callbacks: callbacks,
              )
            : ProImageEditor.memory(
                bytes,
                key: key,
                configs: editorConfigs,
                callbacks: callbacks,
              ),
      ),
    );
    await settle(tester);
    return key.currentState!;
  }

  /// Painted box of the whole (uncropped) image, under every transform.
  RenderBox paintedImage(WidgetTester tester) {
    return tester.renderObject<RenderBox>(
      find
          .descendant(
            of: find.byType(TransformedContentGenerator),
            matching: find.byWidgetPredicate(
              (w) => w.runtimeType.toString() == 'FilteredWidget',
            ),
          )
          .first,
    );
  }

  /// Anchor of each text layer found by [layers] in raw pixels of [image],
  /// by layer text.
  ///
  /// The layout box top-left is the anchor; FractionalTranslation only shifts
  /// paint. globalToLocal inverts rotation and flips too.
  Map<String, Offset> anchorsOn(RenderBox image, Finder layers) {
    final result = <String, Offset>{};
    for (final element in layers.evaluate()) {
      final layer = (element.widget as LayerWidget).layer;
      if (layer is! TextLayer) continue;
      final anchor = (element.renderObject! as RenderBox).localToGlobal(
        Offset.zero,
      );
      final local = image.globalToLocal(anchor);
      result[layer.text] = Offset(
        local.dx / image.size.width * rawSize.width,
        local.dy / image.size.height * rawSize.height,
      );
    }
    return result;
  }

  /// Anchor of each layer in raw image pixels, by layer text.
  Map<String, Offset> layersOnImage(WidgetTester tester) {
    return anchorsOn(paintedImage(tester), find.byType(LayerWidget));
  }

  void expectSame(
    Map<String, Offset> actual,
    Map<String, Offset> expected,
    String when,
  ) {
    expect(actual.keys.toSet(), expected.keys.toSet(), reason: when);
    for (final name in expected.keys) {
      final a = actual[name]!;
      final e = expected[name]!;
      // One raw pixel of tolerance.
      expect(
        (a - e).distance,
        lessThan(1.5),
        reason: '$name $when: expected $e, got $a',
      );
    }
  }

  Finder filteredImageIn(Finder scope) {
    return find
        .descendant(
          of: scope,
          matching: find.byWidgetPredicate(
            (w) => w.runtimeType.toString() == 'FilteredWidget',
          ),
        )
        .first;
  }

  /// Anchor of each layer in raw image pixels, as the open crop editor
  /// previews it.
  Map<String, Offset> layersInCropPreview(WidgetTester tester) {
    final editor = find.byType(CropRotateEditor);
    return anchorsOn(
      tester.renderObject<RenderBox>(filteredImageIn(editor)),
      find.descendant(of: editor, matching: find.byType(LayerWidget)),
    );
  }

  /// Anchor of each layer in raw image pixels, as the crop editor shows it
  /// while it closes, where the hero flight back to the main editor starts.
  Map<String, Offset> layersInClosingCropEditor(WidgetTester tester) {
    final editor = find.byType(CropRotateEditor);
    final heroImage = find.descendant(
      of: editor,
      matching: find.byType(TransformedContentGenerator),
    );
    // The preview stack draws with a zero main body size.
    final heroLayers = find.descendant(
      of: editor,
      matching: find.byWidgetPredicate(
        (w) => w is LayerStack && !w.transformHelper.mainBodySize.isEmpty,
      ),
    );
    return anchorsOn(
      tester.renderObject<RenderBox>(filteredImageIn(heroImage)),
      find.descendant(of: heroLayers, matching: find.byType(LayerWidget)),
    );
  }

  Future<void> expectCropPreview(
    WidgetTester tester,
    ProImageEditorState editor,
    Map<String, Offset> expected,
    String when,
  ) async {
    editor.openCropRotateEditor();
    await settle(tester);
    expectSame(layersInCropPreview(tester), expected, 'crop preview $when');
    editor.cropRotateEditor.currentState!.close();
    await settle(tester);
  }

  void addTick(ProImageEditorState editor, String name, Offset offset) {
    editor.addLayer(
      TextLayer(text: name, offset: offset),
      autoCorrectZoomOffset: false,
      autoCorrectZoomScale: false,
    );
  }

  Future<void> cropOffCenter(
    WidgetTester tester,
    ProImageEditorState editor, {
    bool rotate = false,
    bool flip = false,
    double aspectRatio = 1,
    void Function()? whileClosing,
  }) async {
    editor.openCropRotateEditor();
    await settle(tester);
    final crop = editor.cropRotateEditor.currentState!;
    if (rotate) {
      crop.rotate();
      await settle(tester);
    }
    if (flip) {
      crop.flip();
      await settle(tester);
    }
    crop.updateAspectRatio(aspectRatio);
    await settle(tester);
    crop.setScale(1.6);
    await settle(tester);
    await tester.dragFrom(
      tester.getCenter(find.byType(CropRotateEditor)),
      const Offset(90, 40),
    );
    await settle(tester);
    // done() screenshots the layers, which needs real async work; awaiting it
    // inside the fake-async zone never completes. Pump until it finishes.
    var finished = false;
    unawaited(crop.done().whenComplete(() => finished = true));
    if (whileClosing != null) {
      await tester.pump();
      whileClosing();
    }
    for (var i = 0; i < 40 && !finished; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(finished, isTrue, reason: 'crop done() did not complete');
    await settle(tester);
  }

  Future<String> export(WidgetTester tester, ProImageEditorState editor) async {
    return (await tester.runAsync(() async {
      final history = await editor.exportStateHistory(
        configs: const ExportEditorConfigs(
          historySpan: ExportHistorySpan.current,
        ),
      );
      return jsonEncode(await history.toMap());
    }))!;
  }

  /// Crops on [hops].first with one layer placed before and one after the
  /// crop, then reopens on every following surface, exporting after each.
  Future<void> scenario(
    WidgetTester tester, {
    required List<String> hops,
    String Function(String json)? rewriteExport,
    bool rotate = false,
    bool flip = false,
    bool cropTwice = false,
    bool blank = false,
    double aspectRatio = 1,
    bool checkCropPreview = false,
    bool checkClosingCropEditor = false,
  }) async {
    addTearDown(tester.view.reset);
    final bytes = (await tester.runAsync(makePng))!;

    setSurface(tester, hops.first);
    final source = await pumpEditor(tester, bytes, blank: blank);
    addTick(source, 'before', const Offset(40, -30));
    await settle(tester);
    final placed = layersOnImage(tester);

    await cropOffCenter(
      tester,
      source,
      rotate: rotate,
      flip: flip,
      aspectRatio: aspectRatio,
      whileClosing: checkClosingCropEditor
          ? () => expectSame(
              layersInClosingCropEditor(tester),
              placed,
              'while the crop editor closes',
            )
          : null,
    );
    expectSame(layersOnImage(tester), placed, 'right after crop');

    addTick(source, 'after', const Offset(-25, 35));
    await settle(tester);
    final expected = layersOnImage(tester);

    if (cropTwice) {
      await cropOffCenter(tester, source);
      expectSame(layersOnImage(tester), expected, 'right after second crop');
    }

    if (checkCropPreview) {
      await expectCropPreview(tester, source, expected, 'after crop');
    }

    var json = await export(tester, source);
    if (rewriteExport != null) json = rewriteExport(json);

    for (final hop in hops.skip(1)) {
      setSurface(tester, hop);
      final reopened = await pumpEditor(
        tester,
        bytes,
        historyJson: json,
        blank: blank,
      );
      expectSame(layersOnImage(tester), expected, 'reopened on $hop');
      if (checkCropPreview) {
        await expectCropPreview(tester, reopened, expected, 'on $hop');
      }
      json = await export(tester, reopened);
    }
  }

  for (final from in surfaces.keys) {
    for (final to in surfaces.keys) {
      if (from == to) continue;
      testWidgets(
        'crop on $from reopens on $to',
        (t) => scenario(t, hops: [from, to]),
      );
    }
  }

  testWidgets(
    'round trip desktop > phone > ultrawide > tablet > desktop',
    (t) => scenario(
      t,
      hops: ['desktop', 'phone', 'ultrawide', 'tablet', 'desktop'],
    ),
  );

  testWidgets('undo after crop puts the layer back', (tester) async {
    addTearDown(tester.view.reset);
    final bytes = (await tester.runAsync(makePng))!;
    setSurface(tester, 'desktop');
    final editor = await pumpEditor(tester, bytes);
    addTick(editor, 'before', const Offset(40, -30));
    await settle(tester);
    final placed = layersOnImage(tester);

    await cropOffCenter(tester, editor);
    editor.undoAction();
    await settle(tester);

    expect(editor.stateManager.transformConfigs.isEmpty, isTrue);
    expectSame(layersOnImage(tester), placed, 'after undo');
  });

  String withoutBodySize(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>
      ..remove('editorBodySize')
      ..remove('e');
    return jsonEncode(map);
  }

  for (final pair in const [
    ['desktop', 'phone'],
    ['phone', 'desktop'],
    ['tablet', 'ultrawide'],
    ['ultrawide', 'tablet'],
  ]) {
    testWidgets(
      'export without body size, ${pair.join(' > ')}',
      (t) => scenario(t, hops: pair, rewriteExport: withoutBodySize),
    );
    testWidgets(
      'rotated crop, ${pair.join(' > ')}',
      (t) => scenario(t, hops: pair, rotate: true),
    );
  }

  for (final pair in const [
    ['desktop', 'phone'],
    ['phone', 'desktop'],
    ['ultrawide', 'tablet'],
  ]) {
    testWidgets(
      'crop editor previews layers on a cropped image, ${pair.join(' > ')}',
      (t) => scenario(t, hops: pair, checkCropPreview: true),
    );
  }

  testWidgets(
    'flipped crop, desktop > phone',
    (t) => scenario(t, hops: ['desktop', 'phone'], flip: true),
  );

  testWidgets(
    'crop a cropped image, phone > desktop',
    (t) => scenario(t, hops: ['phone', 'desktop'], cropTwice: true),
  );

  testWidgets(
    'export without body size reopens on the same phone with a tall crop',
    (t) => scenario(
      t,
      hops: ['phone', 'phone'],
      rewriteExport: withoutBodySize,
      aspectRatio: 0.5,
    ),
  );

  testWidgets(
    'blank canvas, desktop > phone',
    (t) => scenario(t, hops: ['desktop', 'phone'], blank: true),
  );

  for (final hop in const ['desktop', 'phone']) {
    testWidgets(
      'blank canvas export without body size reopens on $hop',
      (t) => scenario(
        t,
        hops: [hop, hop],
        blank: true,
        rewriteExport: withoutBodySize,
      ),
    );
  }

  for (final hop in const ['desktop', 'phone']) {
    testWidgets(
      'closing crop editor shows layers on their image points, $hop',
      (t) => scenario(t, hops: [hop], checkClosingCropEditor: true),
    );
  }

  testWidgets('reopen same surface keeps the layer', (tester) async {
    await scenario(tester, hops: ['desktop', 'desktop']);
  });
}
