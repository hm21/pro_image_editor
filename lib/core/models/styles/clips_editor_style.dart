// Flutter imports:
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../constants/editor_style_constants.dart';

/// Defines the visual styles and colors used in the audio editor UI.
class ClipsEditorStyle {
  /// Creates a new set of [ClipsEditorStyle] values.
  const ClipsEditorStyle({
    this.appBarBackground = kImageEditorAppBarBackground,
    this.appBarColor = kImageEditorAppBarColor,
    this.editPageAppBarBackground = kImageEditorAppBarBackground,
    this.editPageAppBarColor = kImageEditorAppBarColor,
    this.uiOverlayStyle = kImageEditorUiOverlayStyle,
    this.background = const Color(0x00000000),
    this.clipThumbnailBackground = const Color(0xFF9E9E9E),
    this.addClipsButtonBackground = const Color.fromARGB(20, 255, 255, 255),
    this.addClipsButtonColor = const Color(0xFFFFFFFF),
    this.addClipsButtonBorderColor = const Color.fromARGB(179, 255, 255, 255),
    this.addClipsButtonBorderWidth = 1.5,
    this.reversedClipsList = false,
    this.bodyPadding = const EdgeInsets.symmetric(vertical: 12),
    this.editPageBodyPadding = EdgeInsets.zero,
  });

  /// Color of the AppBar.
  final Color appBarColor;

  /// Background color of the AppBar.
  final Color appBarBackground;

  /// Color of the edit-page AppBar.
  final Color editPageAppBarColor;

  /// Background color of the edit-page AppBar.
  final Color editPageAppBarBackground;

  /// Background color of the audio editor.
  final Color background;

  /// Defines the system UI overlay style (e.g., status bar icons and color).
  final SystemUiOverlayStyle uiOverlayStyle;

  /// Background color used behind clip-thumbnail images.
  final Color clipThumbnailBackground;

  /// Background color of the "Add Clips" button.
  final Color addClipsButtonBackground;

  /// Icon or text color of the "Add Clips" button.
  final Color addClipsButtonColor;

  /// Border color of the "Add Clips" button.
  final Color addClipsButtonBorderColor;

  /// Border width of the "Add Clips" button.
  final double addClipsButtonBorderWidth;

  /// Reverses the order of the audio clips list when true.
  final bool reversedClipsList;

  /// Padding around the main body.
  final EdgeInsets bodyPadding;

  /// Padding inside the edit page body.
  final EdgeInsets editPageBodyPadding;

  /// Creates a copy of this instance with the given parameters overridden.
  ClipsEditorStyle copyWith({
    Color? appBarColor,
    Color? appBarBackground,
    Color? editPageAppBarColor,
    Color? editPageAppBarBackground,
    Color? background,
    SystemUiOverlayStyle? uiOverlayStyle,
    Color? clipThumbnailBackground,
    Color? addClipsButtonBackground,
    Color? addClipsButtonColor,
    Color? addClipsButtonBorderColor,
    double? addClipsButtonBorderWidth,
    bool? reversedClipsList,
    EdgeInsets? bodyPadding,
    EdgeInsets? editPageBodyPadding,
  }) {
    return ClipsEditorStyle(
      appBarColor: appBarColor ?? this.appBarColor,
      appBarBackground: appBarBackground ?? this.appBarBackground,
      editPageAppBarColor: editPageAppBarColor ?? this.editPageAppBarColor,
      editPageAppBarBackground:
          editPageAppBarBackground ?? this.editPageAppBarBackground,
      background: background ?? this.background,
      uiOverlayStyle: uiOverlayStyle ?? this.uiOverlayStyle,
      clipThumbnailBackground:
          clipThumbnailBackground ?? this.clipThumbnailBackground,
      addClipsButtonBackground:
          addClipsButtonBackground ?? this.addClipsButtonBackground,
      addClipsButtonColor: addClipsButtonColor ?? this.addClipsButtonColor,
      addClipsButtonBorderColor:
          addClipsButtonBorderColor ?? this.addClipsButtonBorderColor,
      addClipsButtonBorderWidth:
          addClipsButtonBorderWidth ?? this.addClipsButtonBorderWidth,
      reversedClipsList: reversedClipsList ?? this.reversedClipsList,
      bodyPadding: bodyPadding ?? this.bodyPadding,
      editPageBodyPadding: editPageBodyPadding ?? this.editPageBodyPadding,
    );
  }
}
