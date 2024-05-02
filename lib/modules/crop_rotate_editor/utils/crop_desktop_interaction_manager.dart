import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';

import '../../../models/layer.dart';

/// A manager class responsible for handling desktop interactions in the crop-rotate editor.
///
/// The `DesktopInteractionManager` class provides methods for responding to keyboard
/// and mouse events on desktop platforms.
class CropDesktopInteractionManager {
  final BuildContext context;
  final Function? onUpdateUI;
  final Function setState;
  final ProImageEditorConfigs configs;

  bool _ctrlDown = false;
  bool _shiftDown = false;

  CropDesktopInteractionManager({
    required this.context,
    required this.onUpdateUI,
    required this.setState,
    required this.configs,
  });

  /// Handles keyboard events.
  ///
  /// This method responds to key events and performs actions based on the pressed keys.
  /// If the 'Escape' key is pressed and the widget is still mounted, it triggers the navigator to pop the current context.
  bool onKey(
    KeyEvent event, {
    required Function(Offset) onTranslate,
    required Function(double) onScale,
    required Function(bool) onUndoRedo,
  }) {
    final key = event.logicalKey.keyLabel;
    if (context.mounted) {
      if (event is KeyDownEvent) {
        double scaleFactor = 0.2;
        double translateFactor = 20;
        switch (key) {
          case 'Subtract':
          case 'Numpad Subtract':
          case 'Page Down':
            onScale(-scaleFactor);
            break;
          case 'Add':
          case 'Numpad Add':
          case 'Page Up':
            onScale(scaleFactor);
            break;
          case 'Arrow Up':
            onTranslate(Offset(0, translateFactor));
            break;
          case 'Arrow Down':
            onTranslate(Offset(0, -translateFactor));
            break;
          case 'Arrow Left':
            onTranslate(Offset(translateFactor, 0));
            break;
          case 'Arrow Right':
            onTranslate(Offset(-translateFactor, 0));
            break;
          case 'Control Left':
          case 'Control Right':
            _ctrlDown = true;
            break;
          case 'Shift Left':
          case 'Shift Right':
            _shiftDown = true;
            break;
          case 'Z':
            if (_ctrlDown) onUndoRedo(!_shiftDown);
            break;
        }
      } else if (event is KeyUpEvent) {
        switch (key) {
          case 'Control Left':
          case 'Control Right':
            _ctrlDown = false;
            break;
          case 'Shift Left':
          case 'Shift Right':
            _shiftDown = false;
            break;
        }
      }
    }

    return false;
  }
}
