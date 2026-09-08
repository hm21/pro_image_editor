import 'package:example/core/constants/example_constants.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '/core/constants/history_demo/import_history_6_3_0_minified.dart';
import '/core/mixin/example_helper.dart';

/// The import export example
class ImportExportExample extends StatefulWidget {
  /// Creates a new [ImportExportExample] widget.
  const ImportExportExample({super.key});

  @override
  State<ImportExportExample> createState() => _ImportExportExampleState();
}

class _ImportExportExampleState extends State<ImportExportExample>
    with ExampleHelperState<ImportExportExample> {
  @override
  void initState() {
    super.initState();
    preCacheImage(assetPath: kImageEditorExampleAssetPath);
  }

  final _history = ImportStateHistory.fromMap(
    kImportHistoryDemoData,
    configs: ImportEditorConfigs(
      recalculateSizeAndPosition: true,

      /// The `widgetLoader` is optional and only required if you
      /// add `exportConfigs` with an id to the widget layers.
      /// Refer to the [sticker-example](https://github.com/hm21/pro_image_editor/blob/stable/example/lib/features/stickers_example.dart)
      /// for details on how this works in the sticker editor.
      ///
      /// If you add widget layers directly to the editor,
      /// you can pass the parameters as shown below:
      ///
      /// ```dart
      /// editor.addLayer(
      ///   WidgetLayer(
      ///     exportConfigs: const WidgetLayerExportConfigs(
      ///       id: 'my-special-container',
      ///     ),
      ///     widget: Container(
      ///       width: 100,
      ///       height: 100,
      ///       color: Colors.amber,
      ///     ),
      ///   ),
      /// );
      /// ```
      widgetLoader: (
        String id, {
        Map<String, dynamic>? meta,
      }) {
        switch (id) {
          case 'my-special-container':
            return Container(
              width: 100,
              height: 100,
              color: Colors.amber,
            );

          /// ... other widgets
        }
        throw ArgumentError(
          'No widget found for the given id: $id',
        );
      },
    ),
  );

  void _export() async {
    final editor = editorKey.currentState!;

    var history = await editor.exportStateHistory(
      configs: const ExportEditorConfigs(
        historySpan: ExportHistorySpan.current,
        maxDecimalPlaces: 3,
        // configs...
      ),
    );

    final result = await history.toJson();

    debugPrint(result);

    /*  final directory = await getTemporaryDirectory();
    final path = '${directory.path}/PIE_Export.json';
    await history.toFile(path: path); */
  }

  @override
  Widget build(BuildContext context) {
    if (!isPreCached) return const PrepareImageWidget();

    return Stack(
      children: [
        ProImageEditor.asset(
          kImageEditorExampleAssetPath,
          key: editorKey,
          callbacks: ProImageEditorCallbacks(
            onImageEditingStarted: onImageEditingStarted,
            onImageEditingComplete: onImageEditingComplete,
            onCloseEditor: (editorMode) => onCloseEditor(
              editorMode: editorMode,
              enablePop: !isDesktopMode(context),
            ),
            mainEditorCallbacks: MainEditorCallbacks(
              helperLines: HelperLinesCallbacks(onLineHit: vibrateLineHit),
            ),
          ),
          configs: ProImageEditorConfigs(
            designMode: platformDesignMode,
            mainEditor: MainEditorConfigs(
              enableCloseButton: !isDesktopMode(context),
              widgets: MainEditorWidgets(
                bodyItems: (editor, rebuildStream) {
                  return [_buildExportButton(rebuildStream)];
                },
              ),
            ),
            stateHistory: StateHistoryConfigs(
              initStateHistory: _history,
            ),
          ),
        ),
      ],
    );
  }

  ReactiveWidget _buildExportButton(Stream<void> rebuildStream) {
    return ReactiveWidget(
      builder: (_) {
        return Positioned(
          bottom: 20,
          left: 0,
          child: Container(
            padding: const EdgeInsets.only(right: 4),
            decoration: const BoxDecoration(
              color: Colors.lightBlue,
              borderRadius: BorderRadius.horizontal(
                right: Radius.circular(100),
              ),
            ),
            child: IconButton(
              onPressed: _export,
              icon: const Icon(
                Icons.send_to_mobile_outlined,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
      stream: rebuildStream,
    );
  }
}
