// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';
import '../../../utils/content_recorder.dart/content_recorder_controller.dart';

/// A class that manages various controllers used in the main editor interface.
class MainEditorControllers {
  /// Constructs a new instance of [MainEditorControllers].
  MainEditorControllers(ProImageEditorConfigs configs) {
    bottomBarScrollCtrl = ScrollController();
    helperLineCtrl = StreamController.broadcast();
    layerHeroResetCtrl = StreamController.broadcast();
    removeBtnCtrl = StreamController.broadcast();
    uiLayerCtrl = StreamController.broadcast();
    screenshot = ContentRecorderController(configs: configs);
  }

  /// Scroll controller for the bottom bar in the editor interface.
  late final ScrollController bottomBarScrollCtrl;

  /// Stream controller for tracking mouse movement within the editor.
  late final StreamController<void> helperLineCtrl;

  /// Stream controller for resetting layer hero animations.
  late final StreamController<bool> layerHeroResetCtrl;

  /// Stream controller for the remove button.
  late final StreamController<void> removeBtnCtrl;

  /// Controller which updates only the UI from the layers.
  late final StreamController<void> uiLayerCtrl;

  /// Controller for capturing screenshots of the editor content.
  late final ContentRecorderController screenshot;

  /// Disposes of resources held by the controllers.
  void dispose() {
    bottomBarScrollCtrl.dispose();
    helperLineCtrl.close();
    layerHeroResetCtrl.close();
    removeBtnCtrl.close();
    screenshot.destroy();
    uiLayerCtrl.close();
  }
}
