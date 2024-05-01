import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';

import '../../../models/layer.dart';

/// A manager class responsible for handling desktop interactions in the image editor.
///
/// The `DesktopInteractionManager` class provides methods for responding to keyboard
/// and mouse events on desktop platforms. It enables users to perform actions such
/// as zooming, rotating, and navigating layers using keyboard shortcuts and mouse
/// scroll wheel movements.
class DesktopInteractionManager {
  final BuildContext context;
  final Function? onUpdateUI;
  final Function setState;
  final ProImageEditorConfigs configs;

  bool _ctrlDown = false;
  bool _shiftDown = false;

  DesktopInteractionManager({
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
    required Layer? activeLayer,
    required bool canPressEscape,
    required bool isEditorOpen,
    required Function onCloseEditor,
    required Function(bool) onUndoRedo,
  }) {
    final key = event.logicalKey.keyLabel;
    if (context.mounted) {
      if (event is KeyDownEvent) {
        switch (key) {
          case 'Escape':
            if (canPressEscape) {
              if (isEditorOpen) {
                Navigator.pop(context);
              } else {
                onCloseEditor();
              }
            }
            break;

          case 'Subtract':
          case 'Numpad Subtract':
          case 'Page Down':
          case 'Arrow Down':
            _keyboardZoom(zoomIn: true, activeLayer: activeLayer);
            break;
          case 'Add':
          case 'Numpad Add':
          case 'Page Up':
          case 'Arrow Up':
            _keyboardZoom(zoomIn: false, activeLayer: activeLayer);
            break;
          case 'Arrow Left':
            _keyboardRotate(left: true, activeLayer: activeLayer);
            break;
          case 'Arrow Right':
            _keyboardRotate(left: false, activeLayer: activeLayer);
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

  /// Handles Keyboard zoom event
  void _keyboardRotate({
    required bool left,
    required Layer? activeLayer,
  }) {
    if (activeLayer == null) return;

    if (left) {
      activeLayer.rotation -= 0.087266;
    } else {
      activeLayer.rotation += 0.087266;
    }
    setState(() {});
    onUpdateUI?.call();
  }

  /// Handles Keyboard zoom event
  void _keyboardZoom({
    required bool zoomIn,
    required Layer? activeLayer,
  }) {
    if (activeLayer == null) return;
    double factor = activeLayer is PaintingLayerData
        ? 0.1
        : activeLayer is TextLayerData
            ? 0.15
            : configs.textEditorConfigs.initFontSize / 50;
    if (zoomIn) {
      activeLayer.scale -= factor;
      activeLayer.scale = max(0.1, activeLayer.scale);
    } else {
      activeLayer.scale += factor;
    }
    setState(() {});
    onUpdateUI?.call();
  }

  /// Handles mouse scroll events.
  void mouseScroll(
    PointerSignalEvent event, {
    required Layer activeLayer,
    required int selectedLayerIndex,
  }) {
    bool shiftDown = HardwareKeyboard.instance.logicalKeysPressed
            .contains(LogicalKeyboardKey.shiftLeft) ||
        HardwareKeyboard.instance.logicalKeysPressed
            .contains(LogicalKeyboardKey.shiftRight);

    if (event is PointerScrollEvent && selectedLayerIndex >= 0) {
      if (shiftDown) {
        if (event.scrollDelta.dy > 0) {
          activeLayer.rotation -= 0.087266;
        } else if (event.scrollDelta.dy < 0) {
          activeLayer.rotation += 0.087266;
        }
      } else {
        double factor = activeLayer is PaintingLayerData
            ? 0.1
            : activeLayer is TextLayerData
                ? 0.15
                : configs.textEditorConfigs.initFontSize / 50;
        if (event.scrollDelta.dy > 0) {
          activeLayer.scale -= factor;
          activeLayer.scale = max(0.1, activeLayer.scale);
        } else if (event.scrollDelta.dy < 0) {
          activeLayer.scale += factor;
        }
      }
      setState(() {});
      onUpdateUI?.call();
    }
  }
}
