// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../utils/content_recorder.dart/content_recorder_controller.dart';

/// A class that manages various controllers used in the main editor interface.
class MainEditorControllers {
  /// Stream controller for tracking mouse movement within the editor.
  late final StreamController<bool> mouseMoveStream;

  late final StreamController<bool> layerHeroResetCtrl;

  /// Controller which update only the ui from the layers.
  late final StreamController uiLayerStream;

  /// Scroll controller for the bottom bar in the editor interface.
  late final ScrollController bottomBarScroll;

  /// Controller for capturing screenshots of the editor content.
  late final ContentRecorderController screenshot;

  /// Constructs a new instance of [MainEditorControllers].
  MainEditorControllers() {
    mouseMoveStream = StreamController.broadcast();
    uiLayerStream = StreamController.broadcast();
    layerHeroResetCtrl = StreamController.broadcast();
    screenshot = ContentRecorderController();
    bottomBarScroll = ScrollController();
  }

  /// Disposes of resources held by the controllers.
  void dispose() {
    mouseMoveStream.close();
    uiLayerStream.close();
    layerHeroResetCtrl.close();
    bottomBarScroll.dispose();
    screenshot.destroy();
  }
}
