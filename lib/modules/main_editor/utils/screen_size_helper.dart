import 'package:flutter/material.dart';
import 'package:pro_image_editor/models/theme/theme_editor_mode.dart';

import '../../../models/editor_configs/pro_image_editor_configs.dart';

/// A helper class for managing screen size and padding calculations.
class ScreenSizeHelper {
  /// The build context used to obtain screen size information.
  final BuildContext context;

  /// Configuration options for the image editor.
  final ProImageEditorConfigs configs;

  ScreenSizeHelper({
    required this.context,
    required this.configs,
  });

  /// Getter for the screen size of the device.
  Size get screen => MediaQuery.of(context).size;

  /// Size of the decoded image.
  Size decodedImageSize = const Size(0, 0);

  /// Getter for the screen inner height, excluding top and bottom padding.
  double get screenInnerHeight =>
      lastScreenSize.height -
      screenPadding.top -
      screenPadding.bottom -
      allToolbarHeight;

  /// Returns the total height of all toolbars.
  double get allToolbarHeight => appBarHeight + bottomBarHeight;

  /// Returns the height of the app bar.
  double get appBarHeight =>
      configs.imageEditorTheme.editorMode == ThemeEditorMode.simple
          ? kToolbarHeight
          : 0;

  /// Returns the height of the bottom bar.
  double get bottomBarHeight =>
      configs.imageEditorTheme.editorMode == ThemeEditorMode.simple
          ? kBottomNavigationBarHeight
          : 0;

  /// Getter for the screen padding, accounting for safe area insets.
  EdgeInsets get screenPadding => MediaQuery.of(context).padding;

  /// Get the screen padding values.
  EdgeInsets get imageMargin => EdgeInsets.only(
        top: (lastScreenSize.height -
                screenPadding.top -
                screenPadding.bottom -
                decodedImageSize.height) /
            2,
        left: (lastScreenSize.width -
                screenPadding.left -
                screenPadding.right -
                decodedImageSize.width) /
            2,
      );
  EdgeInsets get imageScreenGaps => EdgeInsets.only(
        top: (screen.height -
                screenPadding.top -
                screenPadding.bottom -
                decodedImageSize.height -
                allToolbarHeight) /
            2,
        left: (screen.width -
                screenPadding.left -
                screenPadding.right -
                decodedImageSize.width) /
            2,
      );

  /// Stores the last recorded screen size.
  Size lastScreenSize = const Size(0, 0);

  /// Stores the last recorded body size.
  Size bodySize = Size.zero;

  /// Stores the last recorded editor size.
  Size editorSize = Size.zero;
}
