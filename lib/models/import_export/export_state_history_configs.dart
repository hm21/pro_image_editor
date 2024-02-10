class ExportEditorConfigs {
  final bool redoHistory;
  final bool exportPainting;
  final bool exportText;
  final bool exportCropRotate;
  final bool exportFilter;
  final bool exportEmoji;
  final bool exportStickers;

  const ExportEditorConfigs({
    this.redoHistory = true,
    this.exportPainting = true,
    this.exportText = true,
    this.exportCropRotate = true,
    this.exportFilter = true,
    this.exportEmoji = true,
    this.exportStickers = true,
  });
}
