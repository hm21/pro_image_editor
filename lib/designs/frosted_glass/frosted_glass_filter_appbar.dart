// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'frosted_glass_effect.dart';

/// A stateless widget that represents an app bar with a frosted glass effect.
///
/// This app bar is designed to be used within a filter editing interface,
/// providing a stylish and functional header for managing filter operations.
class FrostedGlassFilterAppbar extends StatelessWidget {
  /// Creates a [FrostedGlassFilterAppbar].
  ///
  /// The app bar uses a frosted glass effect, integrating seamlessly with the
  /// filter editor to enhance the user interface of the application.
  ///
  /// Example:
  /// ```
  /// FrostedGlassFilterAppbar(
  ///   filterEditor: myFilterEditorState,
  /// )
  /// ```
  const FrostedGlassFilterAppbar({
    super.key,
    required this.filterEditor,
  });

  /// The state of the filter editor associated with this app bar.
  ///
  /// This state allows the app bar to interact with the filter editor,
  /// providing necessary controls and options to manage filters effectively.
  final FilterEditorState filterEditor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Hero(
                tag: 'frosted-glass-close-btn',
                child: FrostedGlassEffect(
                  child: IconButton(
                    tooltip: filterEditor.configs.i18n.cancel,
                    onPressed: filterEditor.close,
                    icon: Icon(
                      filterEditor.configs.icons.closeEditor,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Hero(
                tag: 'frosted-glass-done-btn',
                child: FrostedGlassEffect(
                  child: IconButton(
                    tooltip: filterEditor.configs.i18n.done,
                    onPressed: filterEditor.done,
                    icon: Icon(
                      filterEditor.configs.icons.doneIcon,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
