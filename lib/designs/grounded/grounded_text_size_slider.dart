// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:pro_image_editor/designs/grounded/utils/grounded_configs.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/widgets/animated/fade_in_left.dart';

/// A widget that provides a slider for adjusting the text size in the
/// ProImageEditor.
///
/// The [GroundedTextSizeSlider] allows users to control the font size of the
/// text in the editor by sliding between different values. The slider is
/// displayed vertically and interacts with the [TextEditorState] to apply
/// the selected text size to the editor.
class GroundedTextSizeSlider extends StatelessWidget {
  /// Constructor for the [GroundedTextSizeSlider].
  ///
  /// Requires the [textEditor] parameter to manage the state of the text
  /// editor.
  const GroundedTextSizeSlider({
    super.key,
    required this.textEditor,
  });

  /// The state of the text editor associated with this slider.
  ///
  /// This state allows the slider to interact with the text editor, providing
  /// necessary controls to manage text size adjustments.
  final TextEditorState textEditor;

  @override
  Widget build(BuildContext context) {
    return FadeInLeft(
      duration: GROUNDED_FADE_IN_DURATION * 2,
      child: Align(
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
      ),
    );
  }
}
