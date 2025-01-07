// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '/features/blur_editor/blur_editor.dart';
import '/features/crop_rotate_editor/crop_rotate_editor.dart';
import '/features/emoji_editor/emoji_editor.dart';
import '/features/filter_editor/filter_editor.dart';
import '/features/paint_editor/paint_editor.dart';
import '/features/text_editor/text_editor.dart';
import '/features/tune_editor/tune_editor.dart';

/// Mixin which contains all global keys for the main-editor
mixin MainEditorGlobalKeys {
  /// A GlobalKey for the Paint Editor, used to access and control the state
  /// of the paint editor.
  final paintEditor = GlobalKey<PaintEditorState>();

  /// A GlobalKey for the Text Editor, used to access and control the state of
  /// the text editor.
  final textEditor = GlobalKey<TextEditorState>();

  /// A GlobalKey for the Crop and Rotate Editor, used to access and control
  /// the state of the crop and rotate editor.
  final cropRotateEditor = GlobalKey<CropRotateEditorState>();

  /// A GlobalKey for the Filter Editor, used to access and control the state
  /// of the filter editor.
  final filterEditor = GlobalKey<FilterEditorState>();

  /// A GlobalKey for the Tune Editor, used to access and control the state of
  /// the tune editor.
  final tuneEditor = GlobalKey<TuneEditorState>();

  /// A GlobalKey for the Blur Editor, used to access and control the state of
  /// the blur editor.
  final blurEditor = GlobalKey<BlurEditorState>();

  /// A GlobalKey for the Emoji Editor, used to access and control the state of
  /// the emoji editor.
  final emojiEditor = GlobalKey<EmojiEditorState>();
}
