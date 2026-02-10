import 'package:flutter/services.dart';

/// A service class for querying the current state of the hardware keyboard.
///
/// This class provides utility methods to check if specific keys or key
/// combinations (like Ctrl or Shift) are currently being pressed.
class KeyboardService {
  /// The current instance of the hardware keyboard.
  final keyboard = HardwareKeyboard.instance;

  /// Checks if a specific [key] is currently being pressed.
  ///
  /// Returns `true` if the key is pressed, `false` otherwise.
  bool isKeyPressed(LogicalKeyboardKey key) {
    return HardwareKeyboard.instance.isLogicalKeyPressed(key);
  }

  /// Returns `true` if either Ctrl key or the Meta key is currently pressed.
  ///
  /// This includes:
  /// - [LogicalKeyboardKey.controlLeft]
  /// - [LogicalKeyboardKey.controlRight]
  /// - [LogicalKeyboardKey.meta] (useful for macOS where Meta is the
  /// command key)
  bool get isCtrlPressed =>
      isKeyPressed(LogicalKeyboardKey.controlLeft) ||
      isKeyPressed(LogicalKeyboardKey.controlRight) ||
      isKeyPressed(LogicalKeyboardKey.meta);

  /// Returns `true` if either Shift key is currently pressed.
  ///
  /// This includes:
  /// - [LogicalKeyboardKey.shiftLeft]
  /// - [LogicalKeyboardKey.shiftRight]
  bool get isShiftPressed =>
      isKeyPressed(LogicalKeyboardKey.shiftLeft) ||
      isKeyPressed(LogicalKeyboardKey.shiftRight);

  /// Returns `true` if either Alt key is currently pressed.
  ///
  /// This includes:
  /// - [LogicalKeyboardKey.altLeft]
  /// - [LogicalKeyboardKey.altRight]
  bool get isAltPressed =>
      isKeyPressed(LogicalKeyboardKey.altLeft) ||
      isKeyPressed(LogicalKeyboardKey.altRight);
}
