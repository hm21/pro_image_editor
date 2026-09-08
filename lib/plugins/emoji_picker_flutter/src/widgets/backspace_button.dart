import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '/plugins/emoji_picker_flutter/emoji_picker_flutter.dart';

/// Backspace Button Widget
class BackspaceButton extends StatefulWidget {
  /// Constructor
  const BackspaceButton(
    this.config,
    this.onBackspacePressed,
    this.onBackspaceLongPressed,
    this.iconColor, {
    super.key,
  });

  /// Config
  final Config config;

  /// Backspace callback
  final VoidCallback? onBackspacePressed;

  /// Backspace long press callback
  final VoidCallback? onBackspaceLongPressed;

  /// Backspace Icon color
  final Color iconColor;

  @override
  State<BackspaceButton> createState() => _BackspaceButtonState();
}

class _BackspaceButtonState extends State<BackspaceButton> {
  Timer? _onBackspacePressedCallbackTimer;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onLongPressStart: (_) => _startOnBackspacePressedCallback(),
        onLongPressEnd: (_) => _stopOnBackspacePressedCallback(),
        child: IconButton(
          padding: const EdgeInsets.only(bottom: 2),
          icon:
              widget.config.customBackspaceIcon ??
              Icon(Icons.backspace, color: widget.iconColor),
          onPressed: () {
            widget.onBackspacePressed?.call();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _onBackspacePressedCallbackTimer?.cancel();
    super.dispose();
  }

  /// Start the callback for long-pressing the backspace button.
  void _startOnBackspacePressedCallback() {
    // Initial callback interval for short presses
    var callbackInterval = const Duration(milliseconds: 75);
    var millisecondsSincePressed = 0;

    // Callback function executed on each timer tick
    void callback(Timer timer) {
      // Accumulate elapsed time since the last tick
      millisecondsSincePressed += callbackInterval.inMilliseconds;

      // If the long-press duration exceeds 3 seconds
      if (millisecondsSincePressed > 3000 &&
          callbackInterval == const Duration(milliseconds: 75)) {
        // Switch to a longer callback interval for word-by-word deletion
        callbackInterval = const Duration(milliseconds: 300);

        // Cancel the existing timer and start a new one with the updated
        // interval
        _onBackspacePressedCallbackTimer?.cancel();
        _onBackspacePressedCallbackTimer = Timer.periodic(
          callbackInterval,
          callback,
        );

        // Reset the elapsed time for the new interval
        millisecondsSincePressed = 0;
      }

      // Trigger the appropriate callback based on the interval
      if (callbackInterval == const Duration(milliseconds: 75)) {
        widget.onBackspacePressed?.call(); // Short-press callback
      } else {
        widget.onBackspaceLongPressed?.call(); // Long-press callback
      }
    }

    // Start the initial timer with the short-press interval
    _onBackspacePressedCallbackTimer = Timer.periodic(
      callbackInterval,
      callback,
    );
  }

  /// Stop the callback for long-pressing the backspace button.
  void _stopOnBackspacePressedCallback() {
    // Cancel the active timer
    _onBackspacePressedCallbackTimer?.cancel();
  }
}
