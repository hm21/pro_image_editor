// Project imports:
import 'utils/export_import_enum.dart';

/// This class represents configurations for importing editor data.
class ImportEditorConfigs {
  /// Constructs an [ImportEditorConfigs] instance.
  ///
  /// - [recalculateSizeAndPosition] is set to `true`
  /// - [mergeMode] is set to [ImportEditorMergeMode.replace]
  const ImportEditorConfigs({
    this.recalculateSizeAndPosition = true,
    this.mergeMode = ImportEditorMergeMode.replace,
  });

  /// The merge mode for importing editor data.
  final ImportEditorMergeMode mergeMode;

  /// A flag indicating whether to recalculate size and position during import
  /// based on the new image size and device size.
  final bool recalculateSizeAndPosition;
}
