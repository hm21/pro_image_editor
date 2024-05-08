import 'package:flutter/material.dart';
import 'package:pro_image_editor/models/theme/theme_editor_mode.dart';

import '../../../models/editor_configs/pro_image_editor_configs.dart';
import '../../../utils/debounce.dart';

/// A helper class for managing screen size and padding calculations.
class ScreenSizeHelper {
  /// The build context used to obtain screen size information.
  final BuildContext context;

  /// Configuration options for the image editor.
  final ProImageEditorConfigs configs;

  ScreenSizeHelper({
    required this.context,
    required this.configs,
  }) {
    screenSizeDebouncer = Debounce(const Duration(milliseconds: 200));
  }

  /// Getter for the screen size of the device.
  Size get screen => MediaQuery.of(context).size;

  /// Width of the image being edited.
  double imageWidth = 0;

  /// Height of the image being edited.
  double imageHeight = 0;

  /// Getter for the screen inner height, excluding top and bottom padding.
  double get screenInnerHeight =>
      lastScreenSize.height -
      screenPadding.top -
      screenPadding.bottom -
      allToolbarHeight;

  /// Getter for the X-coordinate of the middle of the screen.
  double get screenMiddleX =>
      lastScreenSize.width / 2 - (screenPadding.left + screenPadding.right) / 2;

  /// Getter for the Y-coordinate of the middle of the screen.
  double get screenMiddleY =>
      lastScreenSize.height / 2 -
      (screenPadding.top + screenPadding.bottom) / 2;

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
  EdgeInsets get screenPaddingHelper => EdgeInsets.only(
        top: (lastScreenSize.height -
                screenPadding.top -
                screenPadding.bottom -
                imageHeight) /
            2,
        left: (lastScreenSize.width -
                screenPadding.left -
                screenPadding.right -
                imageWidth) /
            2,
      );

  /// Debounce for handling changes in screen size.
  late Debounce screenSizeDebouncer;

  /// Stores the last recorded screen size.
  Size lastScreenSize = const Size(0, 0);

  /// Stores the last recorded body size.
  Size bodySize = Size.zero;

  /// Stores the last recorded image size.
  Size renderedImageSize = Size.zero;
}
