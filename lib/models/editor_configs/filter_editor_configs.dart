// Project imports:
import 'package:pro_image_editor/modules/filter_editor/utils/filter_generator/filter_model.dart';

import 'utils/editor_safe_area.dart';

/// Configuration options for a filter editor.
///
/// `FilterEditorConfigs` allows you to define settings for a filter editor,
/// including whether the editor is enabled and a list of filter generators.
///
/// Example usage:
/// ```dart
/// FilterEditorConfigs(
///   enabled: true,
///   filterList: [
///     ColorFilterGenerator.contrast(1.5),
///     ColorFilterGenerator.brightness(0.7),
///   ],
/// );
/// ```
class FilterEditorConfigs {
  /// Creates an instance of FilterEditorConfigs with optional settings.
  ///
  /// By default, the editor is enabled, and the filter list contains all
  /// filters.
  const FilterEditorConfigs({
    this.enabled = true,
    this.showLayers = true,
    this.filterList,
    this.safeArea = const EditorSafeArea(),
    this.fadeInUpDuration = const Duration(milliseconds: 220),
    this.fadeInUpStaggerDelayDuration = const Duration(milliseconds: 25),
  });

  /// Indicates whether the filter editor is enabled.
  final bool enabled;

  /// Show also layers in the editor.
  final bool showLayers;

  /// A list of color filter generators to apply to an image.
  final List<FilterModel>? filterList;

  /// The duration for the fade-in-up animation.
  ///
  /// The [fadeInUpDuration] field defines how long the fade-in-up animation
  /// should take.
  final Duration fadeInUpDuration;

  /// The delay between staggered fade-in-up animations.
  ///
  /// The [fadeInUpStaggerDelayDuration] field specifies the delay between
  /// multiple fade-in-up animations when they are staggered. This creates a
  /// sequential animation effect where elements fade in one after the other,
  /// with a delay defined by this duration.
  final Duration fadeInUpStaggerDelayDuration;

  /// Defines the safe area configuration for the editor.
  final EditorSafeArea safeArea;

  /// Creates a copy of this `FilterEditorConfigs` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [FilterEditorConfigs] with some properties updated while keeping the
  /// others unchanged.
  FilterEditorConfigs copyWith({
    bool? enabled,
    bool? showLayers,
    List<FilterModel>? filterList,
    Duration? fadeInUpDuration,
    Duration? fadeInUpStaggerDelayDuration,
    EditorSafeArea? safeArea,
  }) {
    return FilterEditorConfigs(
      safeArea: safeArea ?? this.safeArea,
      enabled: enabled ?? this.enabled,
      showLayers: showLayers ?? this.showLayers,
      filterList: filterList ?? this.filterList,
      fadeInUpDuration: fadeInUpDuration ?? this.fadeInUpDuration,
      fadeInUpStaggerDelayDuration:
          fadeInUpStaggerDelayDuration ?? this.fadeInUpStaggerDelayDuration,
    );
  }
}
