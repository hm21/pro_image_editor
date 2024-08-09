// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';

/// A stateless widget that provides a text size slider with a frosted glass
/// effect.
///
/// This slider is designed for use in a text editor interface, allowing users
/// to adjust the text size while maintaining the frosted glass theme.

class FrostedGlassTextSizeSlider extends StatelessWidget {
  /// Creates a [FrostedGlassTextSizeSlider].
  ///
  /// This slider allows users to adjust the size of text within a text editor,
  /// using a frosted glass effect to enhance its visual design.
  ///
  /// Example:
  /// ```
  /// FrostedGlassTextSizeSlider(
  ///   textEditor: myTextEditorState,
  /// )
  /// ```
  const FrostedGlassTextSizeSlider({super.key, required this.textEditor});

  /// The state of the text editor associated with this slider.
  ///
  /// This state allows the slider to interact with the text editor, providing
  /// necessary controls to manage text size adjustments.
  final TextEditorState textEditor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        width: 16,
        height: min(
            280,
            MediaQuery.of(context).size.height -
                MediaQuery.of(context).viewInsets.bottom -
                kToolbarHeight -
                kBottomNavigationBarHeight -
                MediaQuery.of(context).padding.top),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'A',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            Flexible(
              child: RotatedBox(
                quarterTurns: 1,
                child: SliderTheme(
                  data: SliderThemeData(
                    overlayShape: SliderComponentShape.noThumb,
                  ),
                  child: StatefulBuilder(builder: (context, setState) {
                    return Slider(
                      onChanged: (value) {
                        textEditor.fontScale = 4.5 - value;
                        setState(() {});
                      },
                      min: 0.5,
                      max: 4,
                      value: max(0.5, min(4.5 - textEditor.fontScale, 4)),
                      thumbColor: Colors.white,
                      inactiveColor: Colors.white60,
                      activeColor: Colors.white60,
                    );
                  }),
                ),
              ),
            ),
            const Text(
              'A',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
