// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'icons_blur_editor.dart';
import 'icons_crop_rotate_editor.dart';
import 'icons_emoji_editor.dart';
import 'icons_filter_editor.dart';
import 'icons_layer_interaction.dart';
import 'icons_painting_editor.dart';
import 'icons_sticker_editor.dart';
import 'icons_text_editor.dart';
import 'icons_tune_editor.dart';

export 'icons_blur_editor.dart';
export 'icons_crop_rotate_editor.dart';
export 'icons_emoji_editor.dart';
export 'icons_filter_editor.dart';
export 'icons_layer_interaction.dart';
export 'icons_painting_editor.dart';
export 'icons_sticker_editor.dart';
export 'icons_text_editor.dart';
export 'icons_tune_editor.dart';

/// Customizable icons for the Image Editor component.
class ImageEditorIcons {
  /// Creates an instance of [ImageEditorIcons] with customizable icon settings.
  ///
  /// You can provide custom icons for various actions in the Image Editor
  /// component.
  ///
  /// - [closeEditor]: The icon for closing the editor.
  /// - [doneIcon]: The icon for applying changes.
  /// - [backButton]: The icon for the back button.
  /// - [applyChanges]: The icon for applying changes in the editor.
  /// - [undoAction]: The icon for undoing the last action.
  /// - [redoAction]: The icon for redoing the last undone action.
  /// - [removeElementZone]: The icon for removing an element or zone.
  /// - [paintingEditor]: Customizable icons for the Painting Editor component.
  /// - [textEditor]: Customizable icons for the Text Editor component.
  /// - [cropRotateEditor]: Customizable icons for the Crop and Rotate Editor
  /// component.
  /// - [filterEditor]: Customizable icons for the Filter Editor component.
  /// - [blurEditor]: Customizable icons for the Blur Editor component.
  /// - [emojiEditor]: Customizable icons for the Emoji Editor component.
  /// - [stickerEditor]: Customizable icons for the Sticker Editor component.
  /// - [layerInteraction]: Icons for the layer interaction settings.
  ///
  /// If no custom icons are provided, default icons are used for each action.
  ///
  /// Example:
  ///
  /// ```dart
  /// ImageEditorIcons(
  ///   paintingEditor: IconsPaintingEditor(
  ///     bottomNavBar: Icons.edit_rounded,
  ///     lineWeight: Icons.line_weight_rounded,
  ///     freeStyle: Icons.edit,
  ///     // ... (customize other painting editor icons)
  ///   ),
  ///   textEditor: IconsTextEditor(
  ///     bottomNavBar: Icons.text_fields,
  ///     alignLeft: Icons.align_horizontal_left_rounded,
  ///     alignCenter: Icons.align_horizontal_center_rounded,
  ///     // ... (customize other text editor icons)
  ///   ),
  ///   cropRotateEditor: IconsCropRotateEditor(
  ///     bottomNavBar: Icons.crop_rotate_rounded,
  ///     rotate: Icons.rotate_90_degrees_ccw_outlined,
  ///     aspectRatio: Icons.crop,
  ///     // ... (customize other crop and rotate editor icons)
  ///   ),
  ///   filterEditor: IconsFilterEditor(
  ///     bottomNavBar: Icons.filter,
  ///     // ... (customize other filter editor icons)
  ///   ),
  ///   blurEditor: IconsBlurEditor(
  ///     bottomNavBar: Icons.blur_on,
  ///     // ... (customize other blur editor icons)
  ///   ),
  ///   emojiEditor: IconsEmojiEditor(
  ///     bottomNavBar: Icons.sentiment_satisfied_alt_rounded,
  ///     // ... (customize other emoji editor icons)
  ///   ),
  ///   closeEditor: Icons.clear,
  ///   doneIcon: Icons.done,
  ///   backButton: Icons.arrow_back,
  ///   applyChanges: Icons.done,
  ///   undoAction: Icons.undo,
  ///   redoAction: Icons.redo,
  ///   removeElementZone: Icons.delete_outline_rounded,
  /// )
  /// ```
  const ImageEditorIcons({
    this.paintingEditor = const IconsPaintingEditor(),
    this.textEditor = const IconsTextEditor(),
    this.cropRotateEditor = const IconsCropRotateEditor(),
    this.filterEditor = const IconsFilterEditor(),
    this.tuneEditor = const IconsTuneEditor(),
    this.blurEditor = const IconsBlurEditor(),
    this.emojiEditor = const IconsEmojiEditor(),
    this.stickerEditor = const IconsStickerEditor(),
    this.layerInteraction = const IconsLayerInteraction(),
    this.closeEditor = Icons.clear,
    this.doneIcon = Icons.done,
    this.applyChanges = Icons.done,
    this.backButton = Icons.arrow_back,
    this.undoAction = Icons.undo,
    this.redoAction = Icons.redo,
    this.removeElementZone = Icons.delete_outline_rounded,
  });

  /// The icon for closing the editor without saving.
  final IconData closeEditor;

  /// The icon for applying changes and closing the editor.
  final IconData doneIcon;

  /// The icon for the back button.
  final IconData backButton;

  /// The icon for applying changes in the editor.
  final IconData applyChanges;

  /// The icon for undoing the last action.
  final IconData undoAction;

  /// The icon for redoing the last undone action.
  final IconData redoAction;

  /// The icon for removing an element/ layer like an emoji.
  final IconData removeElementZone;

  /// Icons for the Painting Editor component.
  final IconsPaintingEditor paintingEditor;

  /// Icons for the Text Editor component.
  final IconsTextEditor textEditor;

  /// Icons for the Crop and Rotate Editor component.
  final IconsCropRotateEditor cropRotateEditor;

  /// Icons for the Filter Editor component.
  final IconsFilterEditor filterEditor;

  /// Icons for the tune Editor component.
  final IconsTuneEditor tuneEditor;

  /// Icons for the Blur Editor component.
  final IconsBlurEditor blurEditor;

  /// Icons for the Emoji Editor component.
  final IconsEmojiEditor emojiEditor;

  /// Icons for the Sticker Editor component.
  final IconsStickerEditor stickerEditor;

  /// Icons for the layer interaction settings.
  final IconsLayerInteraction layerInteraction;

  /// Creates a copy of this `ImageEditorIcons` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [ImageEditorIcons] with some properties updated while keeping the
  /// others unchanged.
  ImageEditorIcons copyWith({
    IconData? closeEditor,
    IconData? doneIcon,
    IconData? backButton,
    IconData? applyChanges,
    IconData? undoAction,
    IconData? redoAction,
    IconData? removeElementZone,
    IconsPaintingEditor? paintingEditor,
    IconsTextEditor? textEditor,
    IconsCropRotateEditor? cropRotateEditor,
    IconsFilterEditor? filterEditor,
    IconsTuneEditor? tuneEditor,
    IconsBlurEditor? blurEditor,
    IconsEmojiEditor? emojiEditor,
    IconsStickerEditor? stickerEditor,
    IconsLayerInteraction? layerInteraction,
  }) {
    return ImageEditorIcons(
      closeEditor: closeEditor ?? this.closeEditor,
      doneIcon: doneIcon ?? this.doneIcon,
      backButton: backButton ?? this.backButton,
      applyChanges: applyChanges ?? this.applyChanges,
      undoAction: undoAction ?? this.undoAction,
      redoAction: redoAction ?? this.redoAction,
      removeElementZone: removeElementZone ?? this.removeElementZone,
      paintingEditor: paintingEditor ?? this.paintingEditor,
      textEditor: textEditor ?? this.textEditor,
      cropRotateEditor: cropRotateEditor ?? this.cropRotateEditor,
      filterEditor: filterEditor ?? this.filterEditor,
      tuneEditor: tuneEditor ?? this.tuneEditor,
      blurEditor: blurEditor ?? this.blurEditor,
      emojiEditor: emojiEditor ?? this.emojiEditor,
      stickerEditor: stickerEditor ?? this.stickerEditor,
      layerInteraction: layerInteraction ?? this.layerInteraction,
    );
  }
}
