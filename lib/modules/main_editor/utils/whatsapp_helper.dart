// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../utils/swipe_mode.dart';
import '../main_editor.dart';

/// A helper class for managing WhatsApp filter animations and values.
class WhatsAppHelper {
  /// Represents the direction of swipe action.
  SwipeMode _swipeDirection = SwipeMode.none;

  /// Represents the start time of the swipe action.
  DateTime _swipeStartTime = DateTime.now();

  /// Represents the helper value for showing WhatsApp filters.
  double filterShowHelper = 0;

  void onScaleStart(ScaleStartDetails details) {
    _swipeDirection = SwipeMode.none;
    _swipeStartTime = DateTime.now();
  }

  void onScaleUpdate(
    ScaleUpdateDetails details,
    ProImageEditorState editor,
  ) {
    editor.blockOnScaleUpdateFunction = filterShowHelper > 0;

    if (editor.selectedLayerIndex < 0) {
      filterShowHelper -= details.focalPointDelta.dy;
      filterShowHelper = max(0, min(120, filterShowHelper));

      double pointerOffset =
          editor.layerInteractionManager.snapStartPosY - details.focalPoint.dy;
      if (pointerOffset > 20) {
        _swipeDirection = SwipeMode.up;
      } else if (pointerOffset < -20) {
        _swipeDirection = SwipeMode.down;
      }
    }
    editor.setState(() {});
  }

  void onScaleEnd(ScaleEndDetails details, ProImageEditorState editor) {
    if (editor.selectedLayerIndex < 0) {
      editor.layerInteractionManager.showHelperLines = false;

      if (_swipeDirection != SwipeMode.none &&
          DateTime.now().difference(_swipeStartTime).inMilliseconds < 200) {
        if (_swipeDirection == SwipeMode.up) {
          _filterSheetAutoAnimation(true, editor);
        } else if (_swipeDirection == SwipeMode.down) {
          _filterSheetAutoAnimation(false, editor);
        }
      } else {
        if (filterShowHelper < 90) {
          _filterSheetAutoAnimation(false, editor);
        } else {
          _filterSheetAutoAnimation(true, editor);
        }
      }

      filterShowHelper = max(0, min(120, filterShowHelper));
      editor.setState(() {});
    }
  }

  /// Animates the WhatsApp filter sheet.
  ///
  /// If [up] is `true`, it animates the sheet upwards.
  /// Otherwise, it animates the sheet downwards.
  void _filterSheetAutoAnimation(bool up, ProImageEditorState editor) async {
    if (up) {
      while (filterShowHelper < 120) {
        filterShowHelper += 4;
        editor.setState(() {});
        await Future.delayed(const Duration(milliseconds: 1));
      }
    } else {
      while (filterShowHelper > 0) {
        filterShowHelper -= 4;
        editor.setState(() {});
        await Future.delayed(const Duration(milliseconds: 1));
      }
    }
  }
}
