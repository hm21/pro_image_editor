// Flutter imports:
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../constants/editor_style_constants.dart';

/// Defines the visual styles and colors used in the audio editor UI.
class AudioEditorStyle {
  /// Creates a new set of [AudioEditorStyle] values.
  const AudioEditorStyle({
    this.appBarBackground = kImageEditorAppBarBackground,
    this.appBarColor = kImageEditorAppBarColor,
    this.uiOverlayStyle = kImageEditorUiOverlayStyle,
    this.background = const Color(0x00000000),
    this.audioTrackImageBackground = const Color(0xFF9E9E9E),
    this.selectedTrackColor = const Color(0xFF2196F3),
    this.selectedTrackBackground = const Color(0x00000000),
    this.startTimeSelectorBackground = const Color(0xFF191C20),
    this.startTimeSelectorBorderColor = const Color(0x9F8E9099),
    this.startTimeSelectorColor = const Color(0xFFA9C7FF),
    this.startTimeSelectorSelectionBorderColor = const Color(0xFFA9C7FF),
    this.startTimeSelectorWaveColor = const Color(0xFFFFFFFF),
    this.startTimeSelectorBorderWidth = 1.0,
    this.startTimeSelectorBorderRadius = 12.0,
    this.startTimeSelectorSelectionBorderWidth = 2.0,
    this.startTimeSelectorSelectionBorderRadius = 4.0,
    this.startTimeWaveMaxHeight = 62.0,
    this.startTimeWaveItemWidth = 3.0,
    this.startTimeWaveItemSpacing = 1.0,
    this.balanceSliderBackground = const Color(0xFFA9C7FF),
    this.balanceSliderColor = const Color(0xFF08305F),
    this.buttonEditTrackColor = const Color(0xFFA9C7FF),
    this.buttonConfirmColor = const Color(0xFF08305F),
    this.buttonConfirmBackground = const Color(0xFFA9C7FF),
    this.buttonEditTrackBorderRadius = 8.0,
    this.buttonConfirmBorderRadius = 8.0,
    this.editSheetBackgroundColor = const Color.fromARGB(255, 40, 42, 47),
    this.editSheetShadow,
    this.reversedTrackList = false,
    this.bodyPadding = const EdgeInsets.symmetric(vertical: 12),
  });

  /// Color of the app bar.
  final Color appBarColor;

  /// Background color of the app bar.
  final Color appBarBackground;

  /// Background color of the audio editor.
  final Color background;

  /// Background color used behind audio track images.
  final Color audioTrackImageBackground;

  /// Color used to highlight the selected audio track.
  final Color selectedTrackColor;

  /// Background color of the selected track.
  final Color selectedTrackBackground;

  /// Defines the system UI overlay style (e.g., status bar icons and color).
  final SystemUiOverlayStyle uiOverlayStyle;

  /// Shadow of the edit sheet.
  final List<BoxShadow>? editSheetShadow;

  /// Background color of the edit sheet.
  final Color editSheetBackgroundColor;

  /// Background color of the balance slider track.
  final Color balanceSliderBackground;

  /// Color of the balance slider thumb or active section.
  final Color balanceSliderColor;

  /// Color of the "Edit Track" button text or icon.
  final Color buttonEditTrackColor;

  /// Color of the "Confirm" button text or icon.
  final Color buttonConfirmColor;

  /// Background color of the "Confirm" button.
  final Color buttonConfirmBackground;

  /// Background color of the start time selector.
  final Color startTimeSelectorBackground;

  /// Border color of the start time selector.
  final Color startTimeSelectorBorderColor;

  /// Main color of the start time selector indicator.
  final Color startTimeSelectorColor;

  /// Waveform color in the start time selector.
  final Color startTimeSelectorWaveColor;

  /// Border color for the selected area in the waveform.
  final Color startTimeSelectorSelectionBorderColor;

  /// Maximum height of waveform bars.
  final double startTimeWaveMaxHeight;

  /// Width of each waveform bar.
  final double startTimeWaveItemWidth;

  /// Spacing between waveform bars.
  final double startTimeWaveItemSpacing;

  /// Border width of the start time selector.
  final double startTimeSelectorBorderWidth;

  /// Border radius of the start time selector.
  final double startTimeSelectorBorderRadius;

  /// Border width for the selection outline.
  final double startTimeSelectorSelectionBorderWidth;

  /// Border radius for the selection outline.
  final double startTimeSelectorSelectionBorderRadius;

  /// Border radius of the "Edit Track" button.
  final double buttonEditTrackBorderRadius;

  /// Border radius of the "Confirm" button.
  final double buttonConfirmBorderRadius;

  /// Reverses the order of the audio track list when true.
  final bool reversedTrackList;

  /// Padding around the main body.
  final EdgeInsets bodyPadding;

  /// Creates a copy of this instance with the given parameters overridden.
  AudioEditorStyle copyWith({
    Color? appBarColor,
    Color? appBarBackground,
    Color? background,
    Color? audioTrackImageBackground,
    Color? selectedTrackColor,
    Color? selectedTrackBackground,
    SystemUiOverlayStyle? uiOverlayStyle,
    List<BoxShadow>? editSheetShadow,
    Color? editSheetBackgroundColor,
    Color? balanceSliderBackground,
    Color? balanceSliderColor,
    Color? buttonEditTrackColor,
    Color? buttonConfirmColor,
    Color? buttonConfirmBackground,
    Color? startTimeSelectorBackground,
    Color? startTimeSelectorBorderColor,
    Color? startTimeSelectorColor,
    Color? startTimeSelectorWaveColor,
    Color? startTimeSelectorSelectionBorderColor,
    double? startTimeWaveMaxHeight,
    double? startTimeWaveItemWidth,
    double? startTimeWaveItemSpacing,
    double? startTimeSelectorBorderWidth,
    double? startTimeSelectorBorderRadius,
    double? startTimeSelectorSelectionBorderWidth,
    double? startTimeSelectorSelectionBorderRadius,
    double? buttonEditTrackBorderRadius,
    double? buttonConfirmBorderRadius,
    bool? reversedTrackList,
    EdgeInsets? bodyPadding,
  }) {
    return AudioEditorStyle(
      appBarColor: appBarColor ?? this.appBarColor,
      appBarBackground: appBarBackground ?? this.appBarBackground,
      background: background ?? this.background,
      audioTrackImageBackground:
          audioTrackImageBackground ?? this.audioTrackImageBackground,
      selectedTrackColor: selectedTrackColor ?? this.selectedTrackColor,
      selectedTrackBackground:
          selectedTrackBackground ?? this.selectedTrackBackground,
      uiOverlayStyle: uiOverlayStyle ?? this.uiOverlayStyle,
      editSheetShadow: editSheetShadow ?? this.editSheetShadow,
      editSheetBackgroundColor:
          editSheetBackgroundColor ?? this.editSheetBackgroundColor,
      balanceSliderBackground:
          balanceSliderBackground ?? this.balanceSliderBackground,
      balanceSliderColor: balanceSliderColor ?? this.balanceSliderColor,
      buttonEditTrackColor: buttonEditTrackColor ?? this.buttonEditTrackColor,
      buttonConfirmColor: buttonConfirmColor ?? this.buttonConfirmColor,
      buttonConfirmBackground:
          buttonConfirmBackground ?? this.buttonConfirmBackground,
      startTimeSelectorBackground:
          startTimeSelectorBackground ?? this.startTimeSelectorBackground,
      startTimeSelectorBorderColor:
          startTimeSelectorBorderColor ?? this.startTimeSelectorBorderColor,
      startTimeSelectorColor:
          startTimeSelectorColor ?? this.startTimeSelectorColor,
      startTimeSelectorWaveColor:
          startTimeSelectorWaveColor ?? this.startTimeSelectorWaveColor,
      startTimeSelectorSelectionBorderColor:
          startTimeSelectorSelectionBorderColor ??
              this.startTimeSelectorSelectionBorderColor,
      startTimeWaveMaxHeight:
          startTimeWaveMaxHeight ?? this.startTimeWaveMaxHeight,
      startTimeWaveItemWidth:
          startTimeWaveItemWidth ?? this.startTimeWaveItemWidth,
      startTimeWaveItemSpacing:
          startTimeWaveItemSpacing ?? this.startTimeWaveItemSpacing,
      startTimeSelectorBorderWidth:
          startTimeSelectorBorderWidth ?? this.startTimeSelectorBorderWidth,
      startTimeSelectorBorderRadius:
          startTimeSelectorBorderRadius ?? this.startTimeSelectorBorderRadius,
      startTimeSelectorSelectionBorderWidth:
          startTimeSelectorSelectionBorderWidth ??
              this.startTimeSelectorSelectionBorderWidth,
      startTimeSelectorSelectionBorderRadius:
          startTimeSelectorSelectionBorderRadius ??
              this.startTimeSelectorSelectionBorderRadius,
      buttonEditTrackBorderRadius:
          buttonEditTrackBorderRadius ?? this.buttonEditTrackBorderRadius,
      buttonConfirmBorderRadius:
          buttonConfirmBorderRadius ?? this.buttonConfirmBorderRadius,
      reversedTrackList: reversedTrackList ?? this.reversedTrackList,
      bodyPadding: bodyPadding ?? this.bodyPadding,
    );
  }
}
