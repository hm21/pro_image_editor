// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/core/models/editor_callbacks/pro_image_editor_callbacks.dart';
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/layers/layer.dart';
import '/core/services/keyboard_service.dart';

import '/shared/widgets/extended/interactive_viewer/extended_interactive_viewer.dart';

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
  ///   callbacks: myEditorCallbacks,
  /// )
  /// ```
  DesktopInteractionManager({
    required this.context,
    required this.onUpdateUI,
    required this.setState,
    required this.configs,
    required this.callbacks,
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

  /// A class representing callbacks for the Image Editor.
  final ProImageEditorCallbacks callbacks;

  final _keyboard = KeyboardService();

  /// Handles keyboard events.
  ///
  /// This method responds to key events and performs actions based on the
  /// pressed keys.
  /// If the 'Escape' key is pressed and the widget is still mounted, it
  /// triggers the navigator to pop the current context.
  bool onKey(
    KeyEvent event, {
    required List<Layer> selectedLayers,
    required Function onEscape,
    required Function(bool) onUndoRedo,
  }) {
    if (!context.mounted || event is! KeyDownEvent) return false;

    final key = event.logicalKey.keyLabel;

    bool? stopPropagate =
        callbacks.mainEditorCallbacks?.onKeyboardEvent?.call(event);

    if (stopPropagate == true) return true;

    switch (key) {
      case 'Escape':
        if (callbacks.mainEditorCallbacks?.onEscapeButton != null) {
          callbacks.mainEditorCallbacks!.onEscapeButton!();
        } else if (configs.mainEditor.enableEscapeButton) {
          onEscape();
        }
        break;

      case 'Subtract':
      case 'Numpad Subtract':
      case 'Page Down':
      case 'Arrow Down':
        _keyboardZoom(isZoomIn: true, selectedLayers: selectedLayers);
        break;
      case 'Add':
      case 'Numpad Add':
      case 'Page Up':
      case 'Arrow Up':
        _keyboardZoom(isZoomIn: false, selectedLayers: selectedLayers);
        break;
      case 'Arrow Left':
        _keyboardRotate(isLeftRotation: true, selectedLayers: selectedLayers);
        break;
      case 'Arrow Right':
        _keyboardRotate(isLeftRotation: false, selectedLayers: selectedLayers);
        break;
      case 'Z':
        if (_keyboard.isCtrlPressed) onUndoRedo(!_keyboard.isShiftPressed);
        break;
    }

    return false;
  }

  /// Handles Keyboard rotation event
  void _keyboardRotate({
    required bool isLeftRotation,
    required List<Layer> selectedLayers,
  }) {
    if (selectedLayers.isEmpty) return;
    for (Layer layer in selectedLayers) {
      if (isLeftRotation) {
        layer.rotation -= 0.087266;
      } else {
        layer.rotation += 0.087266;
      }
    }
    setState(() {});
    onUpdateUI?.call();
  }

  /// Handles Keyboard zoom event
  void _keyboardZoom({
    required bool isZoomIn,
    required List<Layer> selectedLayers,
  }) {
    if (selectedLayers.isEmpty) return;

    for (Layer layer in selectedLayers) {
      double factor = 1.1;
      if (isZoomIn) {
        layer
          ..scale /= factor
          ..scale = max(0.1, layer.scale);
      } else {
        layer.scale *= factor;
      }
    }

    setState(() {});
    onUpdateUI?.call();
  }

  /// Handles mouse scroll events.
  void mouseScroll(
    PointerSignalEvent event, {
    required List<Layer> selectedLayers,
    required ExtendedInteractiveViewerState? interactiveViewer,
  }) {
    if (event is! PointerScrollEvent || selectedLayers.isEmpty) return;

    for (Layer layer in selectedLayers) {
      if (_keyboard.isShiftPressed) {
        if (event.scrollDelta.dy > 0) {
          layer.rotation -= 0.087266;
        } else if (event.scrollDelta.dy < 0) {
          layer.rotation += 0.087266;
        }
      } else {
        double factor = 1.1;
        if (interactiveViewer?.isInteractionEnabled == true) {
          // only scale if interaction is enabled (that means we might zoom in/out)
          if (event.scrollDelta.dy > 0) {
            layer
              ..scale /= factor
              ..scale = max(0.1, layer.scale);
          } else if (event.scrollDelta.dy < 0) {
            layer.scale *= factor;
          }
        }
      }
    }
    setState(() {});
    onUpdateUI?.call();
  }
}
