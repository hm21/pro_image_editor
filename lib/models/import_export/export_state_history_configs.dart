import 'utils/export_import_enum.dart';

/// Configuration options for exporting editor contents.
///
/// This class defines various options for exporting editor contents such as
/// paintings, text, crop/rotate actions, filters, emojis, and stickers.
class ExportEditorConfigs {
  /// The span of the export history to include in the export.
  ///
  /// By default, it includes the entire export history.
  final ExportHistorySpan historySpan;

  /// Whether to export the painting content.
  ///
  /// Defaults to `true`.
  final bool exportPainting;

  /// Whether to export the text content.
  ///
  /// Defaults to `true`.
  final bool exportText;

  /// Whether to export the crop and rotate actions.
  ///
  /// Defaults to `false`.
  ///
  /// Warning: Exporting cropRotate may result in increased file size.
  final bool exportCropRotate;

  /// Whether to export the applied filters.
  ///
  /// Defaults to `true`.
  final bool exportFilter;

  /// Whether to export the emojis.
  ///
  /// Defaults to `true`.
  final bool exportEmoji;

  /// Whether to export the stickers.
  ///
  /// Defaults to `true`.
  ///
  /// Warning: Exporting stickers may result in increased file size.
  final bool exportSticker;

  const ExportEditorConfigs({
    this.historySpan = ExportHistorySpan.all,
    this.exportPainting = true,
    this.exportText = true,
    this.exportCropRotate = false,
    this.exportFilter = true,
    this.exportEmoji = true,
    this.exportSticker = true,
  });
}
