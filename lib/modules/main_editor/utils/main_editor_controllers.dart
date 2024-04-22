import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:screenshot/screenshot.dart';

/// A class that manages various controllers used in the main editor interface.
class MainEditorControllers {
  /// Stream controller for tracking mouse movement within the editor.
  late final StreamController<bool> mouseMoveStream;

  /// Scroll controller for the bottom bar in the editor interface.
  late final ScrollController bottomBarScroll;

  /// Controller for capturing screenshots of the editor content.
  late final ScreenshotController screenshot;

  /// Constructs a new instance of [MainEditorControllers].
  MainEditorControllers() {
    mouseMoveStream = StreamController.broadcast();
    screenshot = ScreenshotController();
    bottomBarScroll = ScrollController();
  }

  /// Disposes of resources held by the controllers.
  void dispose() {
    mouseMoveStream.close();
    bottomBarScroll.dispose();
  }
}
