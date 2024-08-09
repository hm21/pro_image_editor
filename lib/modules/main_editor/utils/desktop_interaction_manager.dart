// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';
import '../../../models/layer/layer.dart';

/// A manager class responsible for handling desktop interactions in the image
/// editor.
///
/// The `DesktopInteractionManager` class provides methods for responding to
/// keyboard and mouse events on desktop platforms. It enables users to perform
/// actions such as zooming, rotating, and navigating layers using keyboard
/// shortcuts and mouse scroll wheel movements.
class DesktopInteractionManager {
  /// Creates an instance of [DesktopInteractionManager].
  ///
  /// The constructor initializes the context, update callback, state setter,
  /// and configuration settings for managing desktop interactions in the
  /// image editor.
  ///
  /// Example:
  /// ```
  /// DesktopInteractionManager(
  ///   context: myContext,
  ///   onUpdateUI: myUpdateUICallback,
  ///   setState: mySetStateFunction,
  ///   configs: myEditorConfigs,
  /// )
  /// ```
  DesktopInteractionManager({
    required this.context,
    required this.onUpdateUI,
    required this.setState,
    required this.configs,
  });

  /// The build context associated with the desktop interaction manager.
  ///
  /// This [BuildContext] is used to access the widget tree and manage
  /// interactions with the UI, such as displaying dialogs or updating widgets.
  final BuildContext context;

  /// Callback function to trigger UI updates.
  ///
  /// This optional [Function] is invoked to request updates to the user
  /// interface, allowing for dynamic changes in response to interactions.
  final Function? onUpdateUI;

  /// Function to set the state within the widget.
  ///
  /// This [Function] is used to modify the state of the widget, enabling
  /// changes to the UI based on user interactions or other events.
  final Function setState;

  /// Configuration settings for the image editor.
  ///
  /// This [ProImageEditorConfigs] object contains various configuration
  /// options that influence the behavior and appearance of the image editor
  /// during desktop interactions.
  final ProImageEditorConfigs configs;

  bool _ctrlDown = false;
  bool _shiftDown = false;

  /// Handles keyboard events.
  ///
  /// This method responds to key events and performs actions based on the
  /// pressed keys.
  /// If the 'Escape' key is pressed and the widget is still mounted, it
  /// triggers the navigator to pop the current context.
  bool onKey(
    KeyEvent event, {
    required Layer? activeLayer,
    required Function onEscape,
    required Function(bool) onUndoRedo,
  }) {
    final key = event.logicalKey.keyLabel;
    if (context.mounted) {
      if (event is KeyDownEvent) {
        switch (key) {
          case 'Escape':
            onEscape();
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
      activeLayer
        ..scale -= factor
        ..scale = max(0.1, activeLayer.scale);
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
          activeLayer
            ..scale -= factor
            ..scale = max(0.1, activeLayer.scale);
        } else if (event.scrollDelta.dy < 0) {
          activeLayer.scale += factor;
        }
      }
      setState(() {});
      onUpdateUI?.call();
    }
  }
}
