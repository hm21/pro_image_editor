// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../modules/blur_editor/blur_editor.dart';
import '../../modules/crop_rotate_editor/crop_rotate_editor.dart';
import '../../modules/emoji_editor/emoji_editor.dart';
import '../../modules/filter_editor/filter_editor.dart';
import '../../modules/paint_editor/paint_editor.dart';
import '../../modules/text_editor/text_editor.dart';

/// Mixin which contains all global keys for the main-editor
mixin MainEditorGlobalKeys {
  /// A GlobalKey for the Painting Editor, used to access and control the state
  /// of the painting editor.
  final paintingEditor = GlobalKey<PaintingEditorState>();

  /// A GlobalKey for the Text Editor, used to access and control the state of
  /// the text editor.
  final textEditor = GlobalKey<TextEditorState>();

  /// A GlobalKey for the Crop and Rotate Editor, used to access and control
  /// the state of the crop and rotate editor.
  final cropRotateEditor = GlobalKey<CropRotateEditorState>();

  /// A GlobalKey for the Filter Editor, used to access and control the state
  /// of the filter editor.
  final filterEditor = GlobalKey<FilterEditorState>();

  /// A GlobalKey for the Blur Editor, used to access and control the state of
  /// the blur editor.
  final blurEditor = GlobalKey<BlurEditorState>();

  /// A GlobalKey for the Emoji Editor, used to access and control the state of
  /// the emoji editor.
  final emojiEditor = GlobalKey<EmojiEditorState>();
}
