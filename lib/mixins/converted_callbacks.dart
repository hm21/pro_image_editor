// Project imports:
import 'package:pro_image_editor/models/editor_callbacks/pro_image_editor_callbacks.dart';

/// A mixin that provides access to various editor callback configurations.
///
/// This mixin allows classes to access specific callback configurations for
/// different editor functionalities such as paint, text, crop/rotate, filter,
/// and blur operations within an image editor.

mixin ImageEditorConvertedCallbacks {
  /// Returns the main configuration options for the editor.
  ///
  /// This property provides access to the primary callback configurations,
  /// enabling interaction with different editor components.
  ProImageEditorCallbacks get callbacks;

  /// Provides access to the paint editor callbacks.
  ///
  /// This getter returns the callback functions specific to the paint editor,
  /// allowing interaction with paint-related actions and events.
  PaintEditorCallbacks? get paintEditorCallbacks =>
      callbacks.paintEditorCallbacks;

  /// Provides access to the text editor callbacks.
  ///
  /// This getter returns the callback functions specific to the text editor,
  /// enabling interaction with text-related actions and events.
  TextEditorCallbacks? get textEditorCallbacks => callbacks.textEditorCallbacks;

  /// Provides access to the crop/rotate editor callbacks.
  ///
  /// This getter returns the callback functions specific to the crop/rotate
  /// editor, allowing interaction with crop and rotate actions and events.
  CropRotateEditorCallbacks? get cropRotateEditorCallbacks =>
      callbacks.cropRotateEditorCallbacks;

  /// Provides access to the filter editor callbacks.
  ///
  /// This getter returns the callback functions specific to the filter editor,
  /// enabling interaction with filter-related actions and events.
  FilterEditorCallbacks? get filterEditorCallbacks =>
      callbacks.filterEditorCallbacks;

  /// Provides access to the blur editor callbacks.
  ///
  /// This getter returns the callback functions specific to the blur editor,
  /// allowing interaction with blur-related actions and events.
  BlurEditorCallbacks? get blurEditorCallbacks => callbacks.blurEditorCallbacks;

  /// Provides access to the tune editor callbacks.
  ///
  /// This getter returns the callback functions specific to the tune editor,
  /// enabling interaction with tune-related actions and events.
  TuneEditorCallbacks? get tuneEditorCallbacks => callbacks.tuneEditorCallbacks;
}
