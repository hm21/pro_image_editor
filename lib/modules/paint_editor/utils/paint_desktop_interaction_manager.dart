// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A manager class responsible for handling desktop interactions in the
/// crop-rotate editor.
///
/// The `PaintDesktopInteractionManager` class provides methods for responding
/// to keyboard
/// and mouse events on desktop platforms.
class PaintDesktopInteractionManager {
  /// Manages desktop interactions for painting functionality.
  /// Creates an instance of [PaintDesktopInteractionManager].
  ///
  /// [context] is the build context used for interactions.
  PaintDesktopInteractionManager({
    required this.context,
  });

  /// The build context used for interactions.
  final BuildContext context;

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
    required Function(bool) onUndoRedo,
  }) {
    final key = event.logicalKey.keyLabel;
    if (context.mounted) {
      if (event is KeyDownEvent) {
        switch (key) {
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
