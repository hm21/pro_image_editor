// Project imports:
import 'i18n_blur_editor.dart';
import 'i18n_crop_rotate_editor.dart';
import 'i18n_emoji_editor.dart';
import 'i18n_filter_editor.dart';
import 'i18n_layer_interaction.dart';
import 'i18n_painting_editor.dart';
import 'i18n_sticker_editor.dart';
import 'i18n_text_editor.dart';
import 'i18n_tune_editor.dart';
import 'i18n_various.dart';

export 'i18n_blur_editor.dart';
export 'i18n_crop_rotate_editor.dart';
export 'i18n_emoji_editor.dart';
export 'i18n_filter_editor.dart';
export 'i18n_layer_interaction.dart';
export 'i18n_painting_editor.dart';
export 'i18n_sticker_editor.dart';
export 'i18n_text_editor.dart';
export 'i18n_tune_editor.dart';
export 'i18n_various.dart';

/// The `I18n` class provides internationalization settings for the image editor
/// and its components. It includes translations and messages for various parts
/// of the editor.
///
/// Usage:
///
/// ```dart
/// I18n i18n = I18n(
///   various: I18nVarious(
///     // Define various translations...
///   ),
///   paintEditor: I18nPaintingEditor(
///     // Define painting editor translations...
///   ),
///   textEditor: I18nTextEditor(
///     // Define text editor translations...
///   ),
///   cropRotateEditor: I18nCropRotateEditor(
///     // Define crop and rotate editor translations...
///   ),
///   filterEditor: I18nFilterEditor(
///     // Define filter editor translations...
///   ),
///   blurEditor: I18nBlurEditor(
///     // Define blur editor translations...
///   ),
///   emojiEditor: I18nEmojiEditor(
///     // Define emoji editor translations...
///   ),
///   cancel: 'Cancel',
///   undo: 'Undo',
///   redo: 'Redo',
///   done: 'Done',
///   doneLoadingMsg: 'Changes are being applied',
/// );
/// ```
///
/// Properties:
///
/// - `various`: Translations and messages for various parts of the editor.
///
/// - `paintEditor`: Translations and messages specific to the painting editor.
///
/// - `textEditor`: Translations and messages specific to the text editor.
///
/// - `cropRotateEditor`: Translations and messages specific to the crop and
///   rotate editor.
///
/// - `filterEditor`: Translations and messages specific to the filter editor.
///
/// - `blurEditor`: Translations and messages specific to the blur editor.
///
/// - `emojiEditor`: Translations and messages specific to the emoji editor.
///
/// - `cancel`: The text for the "Cancel" button.
///
/// - `undo`: The text for the "Undo" action.
///
/// - `redo`: The text for the "Redo" action.
///
/// - `done`: The text for the "Done" action.
///
/// - `remove`: The text for the "Remove" action.
///
/// - `doneLoadingMsg`: The message displayed when changes are being applied.
///
/// Example Usage:
///
/// ```dart
/// I18n i18n = I18n(
///   various: I18nVarious(
///     // Define various translations...
///   ),
///   paintEditor: I18nPaintingEditor(
///     // Define painting editor translations...
///   ),
///   // Access other translations and messages...
/// );
///
/// String cancelText = i18n.cancel;
/// String undoText = i18n.undo;
/// // Access other translations and messages...
/// ```
class I18n {
  /// Creates an instance of [I18n] with customizable internationalization
  /// settings.
  ///
  /// You can provide translations and messages for various components of the
  /// Image Editor by specifying the corresponding [I18n] subclasses. If a
  /// specific translation is not provided, default values will be used.
  ///
  /// The [cancel], [undo], [redo], and [done] parameters allow you to specify
  /// the text for the respective buttons in the Image Editor interface.
  ///
  /// The [doneLoadingMsg] parameter is used to display a message while changes
  /// are being applied.
  ///
  /// Example:
  ///
  /// ```dart
  /// I18n(
  ///   various: I18nVarious(
  ///     // Custom translations and settings for various components
  ///   ),
  ///   paintEditor: I18nPaintingEditor(
  ///     // Custom translations and settings for the Painting Editor
  ///   ),
  ///   textEditor: I18nTextEditor(
  ///     // Custom translations and settings for the Text Editor
  ///   ),
  ///   // Additional settings for other components...
  ///   cancel: 'Cancel',
  ///   undo: 'Undo',
  ///   redo: 'Redo',
  ///   done: 'Done',
  ///   remove: 'Remove',
  ///   doneLoadingMsg: 'Changes are being applied',
  /// )
  /// ```
  const I18n({
    this.layerInteraction = const I18nLayerInteraction(),
    this.paintEditor = const I18nPaintingEditor(),
    this.textEditor = const I18nTextEditor(),
    this.cropRotateEditor = const I18nCropRotateEditor(),
    this.tuneEditor = const I18nTuneEditor(),
    this.filterEditor = const I18nFilterEditor(),
    this.blurEditor = const I18nBlurEditor(),
    this.emojiEditor = const I18nEmojiEditor(),
    this.stickerEditor = const I18nStickerEditor(),
    this.various = const I18nVarious(),
    this.importStateHistoryMsg = 'Initialize Editor',
    this.cancel = 'Cancel',
    this.undo = 'Undo',
    this.redo = 'Redo',
    this.done = 'Done',
    this.remove = 'Remove',
    this.doneLoadingMsg = 'Changes are being applied',
  });

  /// Translations and messages specific to the painting editor.
  final I18nPaintingEditor paintEditor;

  /// Translations and messages for various parts of the editor.
  final I18nVarious various;

  /// Translations and messages for layer interactions.
  final I18nLayerInteraction layerInteraction;

  /// Translations and messages specific to the text editor.
  final I18nTextEditor textEditor;

  /// Translations and messages specific to the filter editor.
  final I18nFilterEditor filterEditor;

  /// Translations and messages specific to the tune editor.
  final I18nTuneEditor tuneEditor;

  /// Translations and messages specific to the blur editor.
  final I18nBlurEditor blurEditor;

  /// Translations and messages specific to the emoji editor.
  final I18nEmojiEditor emojiEditor;

  /// Translations and messages specific to the sticker editor.
  final I18nStickerEditor stickerEditor;

  /// Translations and messages specific to the crop and rotate editor.
  final I18nCropRotateEditor cropRotateEditor;

  /// Message displayed while changes are being applied.
  final String doneLoadingMsg;

  /// Message displayed during the import of state history.
  /// If the text is empty, no loading dialog will be shown.
  final String importStateHistoryMsg;

  /// Text for the "Cancel" action.
  final String cancel;

  /// Text for the "Undo" action.
  final String undo;

  /// Text for the "Redo" action.
  final String redo;

  /// Text for the "Done" action.
  final String done;

  /// Text for the "Remove" action.
  final String remove;

  /// Creates a copy of this `I18n` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [I18n] with some properties updated while keeping the
  /// others unchanged.
  I18n copyWith({
    I18nPaintingEditor? paintEditor,
    I18nVarious? various,
    I18nLayerInteraction? layerInteraction,
    I18nTextEditor? textEditor,
    I18nFilterEditor? filterEditor,
    I18nTuneEditor? tuneEditor,
    I18nBlurEditor? blurEditor,
    I18nEmojiEditor? emojiEditor,
    I18nStickerEditor? stickerEditor,
    I18nCropRotateEditor? cropRotateEditor,
    String? doneLoadingMsg,
    String? importStateHistoryMsg,
    String? cancel,
    String? undo,
    String? redo,
    String? done,
    String? remove,
  }) {
    return I18n(
      paintEditor: paintEditor ?? this.paintEditor,
      various: various ?? this.various,
      layerInteraction: layerInteraction ?? this.layerInteraction,
      textEditor: textEditor ?? this.textEditor,
      tuneEditor: tuneEditor ?? this.tuneEditor,
      filterEditor: filterEditor ?? this.filterEditor,
      blurEditor: blurEditor ?? this.blurEditor,
      emojiEditor: emojiEditor ?? this.emojiEditor,
      stickerEditor: stickerEditor ?? this.stickerEditor,
      cropRotateEditor: cropRotateEditor ?? this.cropRotateEditor,
      doneLoadingMsg: doneLoadingMsg ?? this.doneLoadingMsg,
      importStateHistoryMsg:
          importStateHistoryMsg ?? this.importStateHistoryMsg,
      cancel: cancel ?? this.cancel,
      undo: undo ?? this.undo,
      redo: redo ?? this.redo,
      done: done ?? this.done,
      remove: remove ?? this.remove,
    );
  }
}
