// ignore_for_file: invalid_use_of_protected_member

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pro_image_editor/core/models/editor_callbacks/pro_image_editor_callbacks.dart';
import 'package:pro_image_editor/core/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/core/models/init_configs/crop_rotate_editor_init_configs.dart';
import 'package:pro_image_editor/features/crop_rotate_editor/crop_rotate_editor.dart';
import '../../mock/mock_image.dart';

void main() {
  final CropRotateEditorInitConfigs initConfigs = CropRotateEditorInitConfigs(
    theme: ThemeData.light(),
    enableFakeHero: false,
    configs: const ProImageEditorConfigs(
      cropRotateEditor: CropRotateEditorConfigs(
        animationDuration: Duration.zero,
        cropDragAnimationDuration: Duration.zero,
        fadeInOutsideCropAreaAnimationDuration: Duration.zero,
        opacityOutsideCropAreaDuration: Duration.zero,
      ),
      imageGeneration: ImageGenerationConfigs(
        enableBackgroundGeneration: false,
        enableIsolateGeneration: false,
      ),
    ),
  );
  var key = GlobalKey<CropRotateEditorState>();
  Future<void> pumpEditor(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CropRotateEditor.memory(
            mockMemoryImage,
            key: key,
            initConfigs: initConfigs,
          ),
        ),
      ),
    );
  }

  group('CropRotateEditor Initialization', () {
    testWidgets('creates CropRotateEditor using memory image', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CropRotateEditor.memory(
            mockMemoryImage,
            initConfigs: initConfigs,
          ),
        ),
      );

      expect(find.byType(CropRotateEditor), findsOneWidget);
    });
    testWidgets('creates CropRotateEditor using network image', (
      WidgetTester tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: CropRotateEditor.network(
              mockNetworkImage,
              initConfigs: initConfigs,
            ),
          ),
        );
      });

      expect(find.byType(CropRotateEditor), findsOneWidget);
    });
    testWidgets('creates CropRotateEditor using file image', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CropRotateEditor.file(mockFileImage, initConfigs: initConfigs),
        ),
      );

      expect(find.byType(CropRotateEditor), findsOneWidget);
    });
    testWidgets('creates CropRotateEditor using file path', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: CropRotateEditor.file('', initConfigs: initConfigs)),
      );

      expect(find.byType(CropRotateEditor), findsOneWidget);
    });
    group('creates CropRotateEditor using autoSource constructor', () {
      testWidgets('Auto-detects from memory image', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CropRotateEditor.autoSource(
              byteArray: mockMemoryImage,
              initConfigs: initConfigs,
            ),
          ),
        );

        expect(find.byType(CropRotateEditor), findsOneWidget);
      });
      testWidgets('Auto-detects from network image', (
        WidgetTester tester,
      ) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            MaterialApp(
              home: CropRotateEditor.autoSource(
                networkUrl: mockNetworkImage,
                initConfigs: initConfigs,
              ),
            ),
          );
        });

        expect(find.byType(CropRotateEditor), findsOneWidget);
      });
      testWidgets('Auto-detects from file image', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CropRotateEditor.autoSource(
              file: mockFileImage,
              initConfigs: initConfigs,
            ),
          ),
        );

        expect(find.byType(CropRotateEditor), findsOneWidget);
      });
      testWidgets('Auto-detects from file path', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CropRotateEditor.autoSource(
              file: '',
              initConfigs: initConfigs,
            ),
          ),
        );

        expect(find.byType(CropRotateEditor), findsOneWidget);
      });
    });
  });

  group('CropRotateEditor Tests', () {
    Future<void> zoom(
      WidgetTester tester,
      GlobalKey<CropRotateEditorState> editorKey,
    ) async {
      final Offset centerPoint = tester.getCenter(
        find.byType(CropRotateEditor),
      );

      // Start pinch gesture with two fingers
      final TestGesture gesture1 = await tester.startGesture(centerPoint);
      final TestGesture gesture2 = await tester.startGesture(
        centerPoint.translate(-50.0, -50.0),
      );

      // Move fingers apart to simulate pinch zoom
      await gesture1.moveBy(const Offset(30.0, 30.0));
      await gesture2.moveBy(const Offset(-30.0, -30.0));

      await tester.pump(const Duration(milliseconds: 1));

      // Additional movements for further zoom
      await gesture1.moveBy(const Offset(20.0, 20.0));
      await gesture2.moveBy(const Offset(-20.0, -20.0));

      // End the gesture
      await gesture1.up();
      await gesture2.up();

      expect(editorKey.currentState!.userScaleFactor, greaterThan(1));

      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets('handles rotation correctly', (WidgetTester tester) async {
      await pumpEditor(tester);
      await tester.tap(
        find.byKey(const ValueKey('crop-rotate-editor-rotate-btn')),
      );
      await tester.pumpAndSettle();

      expect(key.currentState!.rotationCount == 1, isTrue);
    });

    testWidgets('handles flip correctly', (WidgetTester tester) async {
      await pumpEditor(tester);
      await tester.tap(
        find.byKey(const ValueKey('crop-rotate-editor-flip-btn')),
      );
      await tester.pumpAndSettle();
      expect(key.currentState!.flipX, isTrue);
    });

    testWidgets('handles zoom correctly', (WidgetTester tester) async {
      await pumpEditor(tester);

      await zoom(tester, key);

      /// Fake tap that widget will stay alive until loop finish
      await tester.tap(
        find.byKey(const ValueKey('crop-rotate-editor-reset-btn')),
      );
    });

    testWidgets('handles reset correctly', (WidgetTester tester) async {
      await pumpEditor(tester);
      await zoom(tester, key);

      await tester.tap(
        find.byKey(const ValueKey('crop-rotate-editor-flip-btn')),
      );
      await tester.pumpAndSettle();
      expect(key.currentState!.flipX, isTrue);

      await tester.tap(
        find.byKey(const ValueKey('crop-rotate-editor-rotate-btn')),
      );
      await tester.pumpAndSettle();
      expect(key.currentState!.rotationCount == 1, isTrue);

      await tester.tap(
        find.byKey(const ValueKey('crop-rotate-editor-reset-btn')),
      );
      await tester.pumpAndSettle();

      expect(key.currentState!.rotationCount == 0, isTrue);
      expect(key.currentState!.flipX, isFalse);
      expect(key.currentState!.userScaleFactor, equals(1));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
    });
  });

  group('CropRotateEditor keep aspect ratio on rotate', () {
    CropRotateEditorInitConfigs buildConfigs({
      required bool enableLock,
      double? initAspectRatio,
    }) {
      return CropRotateEditorInitConfigs(
        theme: ThemeData.light(),
        enableFakeHero: false,
        mainImageSize: const Size(600, 800),
        configs: ProImageEditorConfigs(
          cropRotateEditor: CropRotateEditorConfigs(
            initAspectRatio: initAspectRatio,
            enableKeepAspectRatioOnRotate: enableLock,
            animationDuration: Duration.zero,
            cropDragAnimationDuration: Duration.zero,
            fadeInOutsideCropAreaAnimationDuration: Duration.zero,
            opacityOutsideCropAreaDuration: Duration.zero,
          ),
          imageGeneration: const ImageGenerationConfigs(
            enableBackgroundGeneration: false,
            enableIsolateGeneration: false,
          ),
        ),
      );
    }

    Future<GlobalKey<CropRotateEditorState>> pumpLockEditor(
      WidgetTester tester, {
      required bool enableLock,
      double? initAspectRatio,
    }) async {
      final editorKey = GlobalKey<CropRotateEditorState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CropRotateEditor.memory(
              mockMemoryImage,
              key: editorKey,
              initConfigs: buildConfigs(
                enableLock: enableLock,
                initAspectRatio: initAspectRatio,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      return editorKey;
    }

    testWidgets('keeps the selected ratio orientation when enabled', (
      WidgetTester tester,
    ) async {
      final editorKey = await pumpLockEditor(
        tester,
        enableLock: true,
        initAspectRatio: 9 / 16,
      );

      // Initially the crop frame matches the selected 9:16 ratio.
      expect(
        editorKey.currentState!.cropRect.size.aspectRatio,
        closeTo(9 / 16, 0.01),
      );

      await tester.tap(
        find.byKey(const ValueKey('crop-rotate-editor-rotate-btn')),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // After rotating, the local crop rect is inverted so the on-screen frame
      // keeps the 9:16 orientation.
      expect(editorKey.currentState!.rotationCount, 1);
      expect(
        editorKey.currentState!.cropRect.size.aspectRatio,
        closeTo(16 / 9, 0.01),
      );
    });

    testWidgets('swaps the ratio orientation when disabled', (
      WidgetTester tester,
    ) async {
      final editorKey = await pumpLockEditor(
        tester,
        enableLock: false,
        initAspectRatio: 9 / 16,
      );

      expect(
        editorKey.currentState!.cropRect.size.aspectRatio,
        closeTo(9 / 16, 0.01),
      );

      await tester.tap(
        find.byKey(const ValueKey('crop-rotate-editor-rotate-btn')),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Without the option the local crop rect stays unchanged, so on-screen it
      // appears as 16:9 after the rotation.
      expect(editorKey.currentState!.rotationCount, 1);
      expect(
        editorKey.currentState!.cropRect.size.aspectRatio,
        closeTo(9 / 16, 0.01),
      );
    });

    testWidgets('keeps orientation for the free aspect ratio', (
      WidgetTester tester,
    ) async {
      // No initAspectRatio => free ratio, the crop frame matches the image
      // (600x800 => 3:4).
      final editorKey = await pumpLockEditor(tester, enableLock: true);

      expect(
        editorKey.currentState!.cropRect.size.aspectRatio,
        closeTo(3 / 4, 0.01),
      );

      await tester.tap(
        find.byKey(const ValueKey('crop-rotate-editor-rotate-btn')),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // The local crop rect is inverted so the on-screen frame keeps the 3:4
      // orientation even with a free ratio.
      expect(editorKey.currentState!.rotationCount, 1);
      expect(
        editorKey.currentState!.cropRect.size.aspectRatio,
        closeTo(4 / 3, 0.01),
      );
    });
  });

  group('CropRotateEditor Aspect Ratio Dialog Tests', () {
    testWidgets('Opens and selects an aspect ratio', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CropRotateEditor.memory(
            mockMemoryImage,
            initConfigs: initConfigs,
          ),
        ),
      );

      // Wait for the widget to be built
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      var openDialogButtonFinder = find.byKey(
        const ValueKey('crop-rotate-editor-ratio-btn'),
      );
      await tester.tap(openDialogButtonFinder);

      // Rebuild the widget and open the dialog
      await tester.pumpAndSettle();

      expect(find.byType(CropAspectRatioOptions), findsOneWidget);

      // Ensure to draw ratios
      expect(find.text('16*9'), findsOneWidget);
    });
  });

  group('Keyboard shortcuts', () {
    const fastConfig = CropRotateEditorConfigs(
      animationDuration: Duration.zero,
      cropDragAnimationDuration: Duration.zero,
      fadeInOutsideCropAreaAnimationDuration: Duration.zero,
      opacityOutsideCropAreaDuration: Duration.zero,
    );

    Future<GlobalKey<CropRotateEditorState>> pumpWith(
      WidgetTester tester, {
      required CropRotateEditorConfigs cropConfigs,
      ProImageEditorCallbacks callbacks = const ProImageEditorCallbacks(),
    }) async {
      final editorKey = GlobalKey<CropRotateEditorState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CropRotateEditor.memory(
              mockMemoryImage,
              key: editorKey,
              initConfigs: CropRotateEditorInitConfigs(
                theme: ThemeData.light(),
                enableFakeHero: false,
                callbacks: callbacks,
                configs: ProImageEditorConfigs(
                  cropRotateEditor: cropConfigs,
                  imageGeneration: const ImageGenerationConfigs(
                    enableBackgroundGeneration: false,
                    enableIsolateGeneration: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return editorKey;
    }

    testWidgets('rotate the image with the R key by default', (tester) async {
      final editorKey = await pumpWith(tester, cropConfigs: fastConfig);
      expect(editorKey.currentState!.rotationCount, 0);

      await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
      await tester.pumpAndSettle();

      expect(editorKey.currentState!.rotationCount, 1);
    });

    testWidgets('ignore the R key when shortcuts are disabled', (tester) async {
      final editorKey = await pumpWith(
        tester,
        cropConfigs: fastConfig.copyWith(enableKeyboardShortcuts: false),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
      await tester.pumpAndSettle();

      expect(editorKey.currentState!.rotationCount, 0);
    });

    testWidgets('onKeyboardEvent can consume the R key (#837)', (tester) async {
      var receivedEvent = false;
      final editorKey = await pumpWith(
        tester,
        cropConfigs: fastConfig,
        callbacks: ProImageEditorCallbacks(
          cropRotateEditorCallbacks: CropRotateEditorCallbacks(
            onKeyboardEvent: (event) {
              receivedEvent = true;
              return true;
            },
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
      await tester.pumpAndSettle();

      expect(receivedEvent, isTrue);
      expect(editorKey.currentState!.rotationCount, 0);
    });
  });
}
