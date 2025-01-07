// Flutter imports:
import 'package:flutter/services.dart';
import '/core/constants/editor_style_constants.dart';

import 'sub_editor_page_style.dart';

/// Represents the styling configuration for the main editor interface.
class MainEditorStyle {
  /// Creates a new instance of [MainEditorStyle].
  const MainEditorStyle({
    this.background = kImageEditorBackground,
    this.bottomBarColor = kImageEditorBottomBarColor,
    this.bottomBarBackground = kImageEditorBottomBarBackground,
    this.appBarColor = kImageEditorAppBarColor,
    this.appBarBackground = kImageEditorAppBarBackground,
    this.uiOverlayStyle = kImageEditorUiOverlayStyle,
    this.outsideCaptureAreaLayerOpacity = 0.5,
    this.subEditorPage = const SubEditorPageStyle(),
  });

  /// Background color for the image editor in the overview.
  final Color background;

  /// Color of the bottom bar.
  final Color bottomBarColor;

  /// Background color of the bottom bar.
  final Color bottomBarBackground;

  /// Color of the app bar.
  final Color appBarColor;

  /// Background color of the app bar.
  final Color appBarBackground;

  /// UI overlay style, defining the appearance of system status bars.
  final SystemUiOverlayStyle uiOverlayStyle;

  /// The theme configuration for the sub-editor page.
  final SubEditorPageStyle subEditorPage;

  /// If this opacity is greater than 0, it will paint a transparent overlay
  /// over all layers that are drawn outside the background image area. The
  /// overlay will have the specified opacity level.
  ///
  /// Note: This opacity only takes effect if the
  /// `captureOnlyBackgroundImageArea` flag in the generation configuration is
  /// set to `true`.
  final double outsideCaptureAreaLayerOpacity;

  /// Creates a copy of this style with the specified overrides.
  ///
  /// Returns a new [MainEditorStyle] instance with the overridden properties.
  MainEditorStyle copyWith({
    Color? background,
    Color? bottomBarColor,
    Color? bottomBarBackground,
    Color? appBarColor,
    Color? appBarBackground,
    SystemUiOverlayStyle? uiOverlayStyle,
    double? outsideCaptureAreaLayerOpacity,
    SubEditorPageStyle? subEditorPage,
  }) {
    return MainEditorStyle(
        background: background ?? this.background,
        bottomBarColor: bottomBarColor ?? this.bottomBarColor,
        bottomBarBackground: bottomBarBackground ?? this.bottomBarBackground,
        appBarColor: appBarColor ?? this.appBarColor,
        appBarBackground: appBarBackground ?? this.appBarBackground,
        uiOverlayStyle: uiOverlayStyle ?? this.uiOverlayStyle,
        subEditorPage: subEditorPage ?? this.subEditorPage,
        outsideCaptureAreaLayerOpacity: outsideCaptureAreaLayerOpacity ??
            this.outsideCaptureAreaLayerOpacity);
  }
}
