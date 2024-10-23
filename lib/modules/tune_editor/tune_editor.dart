// Dart imports:
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pro_image_editor/mixins/converted_callbacks.dart';
import 'package:pro_image_editor/models/transform_helper.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/utils/record_invisible_widget.dart';

import '../../mixins/converted_configs.dart';
import '../../mixins/standalone_editor.dart';
import '../../models/crop_rotate_editor/transform_factors.dart';
import '../../models/tune_editor/tune_adjustment_matrix.dart';
import '../../utils/content_recorder.dart/content_recorder.dart';
import '../../widgets/layer_stack.dart';
import '../../widgets/transform/transformed_content_generator.dart';
import '../filter_editor/widgets/filtered_image.dart';
import 'utils/tune_presets.dart';

export '../../models/tune_editor/tune_adjustment_item.dart';

/// The `TuneEditor` widget allows users to edit images with various
/// tune adjustment tools such as brightness, contrast, and saturation.
///
/// You can create a `TuneEditor` using one of the factory methods provided:
/// - `TuneEditor.file`: Loads an image from a file.
/// - `TuneEditor.asset`: Loads an image from an asset.
/// - `TuneEditor.network`: Loads an image from a network URL.
/// - `TuneEditor.memory`: Loads an image from memory as a `Uint8List`.
/// - `TuneEditor.autoSource`: Automatically selects the source based on
/// the provided parameters.
class TuneEditor extends StatefulWidget
    with StandaloneEditor<TuneEditorInitConfigs> {
  /// Constructs a `TuneEditor` widget.
  ///
  /// The [key] parameter is used to provide a key for the widget.
  /// The [editorImage] parameter specifies the image to be edited.
  /// The [initConfigs] parameter specifies the initialization configurations
  /// for the editor.
  const TuneEditor._({
    super.key,
    required this.editorImage,
    required this.initConfigs,
  });

  /// Constructs a `TuneEditor` widget with image data loaded from memory.
  factory TuneEditor.memory(
    Uint8List byteArray, {
    Key? key,
    required TuneEditorInitConfigs initConfigs,
  }) {
    return TuneEditor._(
      key: key,
      editorImage: EditorImage(byteArray: byteArray),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `TuneEditor` widget with an image loaded from a file.
  factory TuneEditor.file(
    File file, {
    Key? key,
    required TuneEditorInitConfigs initConfigs,
  }) {
    return TuneEditor._(
      key: key,
      editorImage: EditorImage(file: file),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `TuneEditor` widget with an image loaded from an asset.
  factory TuneEditor.asset(
    String assetPath, {
    Key? key,
    required TuneEditorInitConfigs initConfigs,
  }) {
    return TuneEditor._(
      key: key,
      editorImage: EditorImage(assetPath: assetPath),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `TuneEditor` widget with an image loaded from a network
  /// URL.
  factory TuneEditor.network(
    String networkUrl, {
    Key? key,
    required TuneEditorInitConfigs initConfigs,
  }) {
    return TuneEditor._(
      key: key,
      editorImage: EditorImage(networkUrl: networkUrl),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `TuneEditor` widget with an image loaded automatically
  /// based on the provided source.
  ///
  /// Either [byteArray], [file], [networkUrl], or [assetPath] must be provided.
  factory TuneEditor.autoSource({
    Key? key,
    required TuneEditorInitConfigs initConfigs,
    Uint8List? byteArray,
    File? file,
    String? assetPath,
    String? networkUrl,
  }) {
    if (byteArray != null) {
      return TuneEditor.memory(
        byteArray,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (file != null) {
      return TuneEditor.file(
        file,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (networkUrl != null) {
      return TuneEditor.network(
        networkUrl,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (assetPath != null) {
      return TuneEditor.asset(
        assetPath,
        key: key,
        initConfigs: initConfigs,
      );
    } else {
      throw ArgumentError(
          "Either 'byteArray', 'file', 'networkUrl' or 'assetPath' must "
          'be provided.');
    }
  }
  @override
  final TuneEditorInitConfigs initConfigs;
  @override
  final EditorImage editorImage;

  @override
  createState() => TuneEditorState();
}

/// The state class for the `TuneEditor` widget.
class TuneEditorState extends State<TuneEditor>
    with
        ImageEditorConvertedConfigs,
        ImageEditorConvertedCallbacks,
        StandaloneEditorState<TuneEditor, TuneEditorInitConfigs> {
  /// A stream controller used to manage UI updates.
  ///
  /// This stream is used to broadcast events when the UI needs to be rebuilt.
  late final StreamController<void> uiStream;

  /// A scroll controller for the bottom bar in the tune editor.
  ///
  /// This controller manages the scrolling behavior of the bottom bar.
  final bottomBarScrollCtrl = ScrollController();

  /// A list of tune adjustment items available in the editor.
  ///
  /// Each item represents an adjustable parameter such as brightness or
  /// contrast.
  List<TuneAdjustmentItem> tuneAdjustmentList = [];

  /// A list of matrices representing the adjustments applied to the image.
  ///
  /// Each matrix corresponds to a specific tune adjustment and stores the
  /// current value and its transformation matrix.
  List<TuneAdjustmentMatrix> tuneAdjustmentMatrix = [];

  /// The index of the currently selected tune adjustment item.
  ///
  /// This index represents the adjustment item that is currently being modified
  /// by the user.
  int selectedIndex = 0;

  /// A stack used to keep track of previous states for undo functionality.
  ///
  /// Each entry in the list is a snapshot of the `tuneAdjustmentMatrix` at a
  /// certain point, allowing the user to revert to a previous state.
  List<List<TuneAdjustmentMatrix>> _undoStack = [];

  /// A stack used to keep track of states for redo functionality.
  ///
  /// When the user undoes an action, the current state is moved to this stack,
  /// allowing them to redo the action and return to that state if desired.
  List<List<TuneAdjustmentMatrix>> _redoStack = [];

  /// Determines whether undo can be performed on the current state.
  bool get canUndo => _undoStack.isNotEmpty;

  /// Determines whether redo can be performed on the current state.
  bool get canRedo => _redoStack.isNotEmpty;

  @override
  void initState() {
    uiStream = StreamController.broadcast();
    uiStream.stream.listen((_) => rebuildController.add(null));

    tuneAdjustmentMatrix = appliedTuneAdjustments;

    var items = tuneEditorConfigs.tuneAdjustmentOptions ??
        tunePresets(
          icons: icons.tuneEditor,
          i18n: i18n.tuneEditor,
        );
    tuneAdjustmentList = items.map((item) {
      return item.copyWith(
        value: tuneAdjustmentMatrix
            .firstWhere((el) => el.id == item.id,
                orElse: () => TuneAdjustmentMatrix(
                      id: 'id',
                      value: 0,
                      matrix: [],
                    ))
            .value,
      );
    }).toList();

    if (tuneAdjustmentMatrix.isEmpty) {
      _setMatrixList();
    }

    tuneEditorCallbacks?.onInit?.call();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      tuneEditorCallbacks?.onAfterViewInit?.call();
    });
    super.initState();
  }

  @override
  void dispose() {
    bottomBarScrollCtrl.dispose();
    uiStream.close();
    super.dispose();
  }

  @override
  void setState(void Function() fn) {
    rebuildController.add(null);
    super.setState(fn);
  }

  /// Handles the "Done" action, either by applying changes or closing the
  /// editor.
  void done() async {
    doneEditing(
      editorImage: editorImage,
      returnValue: tuneAdjustmentMatrix,
    );
    tuneEditorCallbacks?.handleDone();
  }

  /// Resets the tune editor state, clearing undo and redo stacks.
  void reset() {
    _undoStack = [];
    _redoStack = [];
    _setMatrixList();
    setState(() {});
  }

  /// Redoes the last undone action.
  ///
  /// Moves the last action from the redo stack to the undo stack and restores
  /// the adjustment matrix.
  void redo() {
    if (_redoStack.isNotEmpty) {
      /// Save current state to undo stack
      _undoStack.add(List.from(tuneAdjustmentMatrix.map((e) => e.copy())));

      /// Restore the last state from redo stack
      tuneAdjustmentMatrix = _redoStack.removeLast();

      tuneEditorCallbacks?.handleRedo();

      setState(() {});
    }
  }

  /// Undoes the last action.
  ///
  /// Moves the last action from the undo stack to the redo stack and restores
  /// the previous adjustment matrix.
  void undo() {
    if (_undoStack.isNotEmpty) {
      /// Save current state to redo stack
      _redoStack.add(List.from(tuneAdjustmentMatrix.map((e) => e.copy())));

      /// Restore the last state from undo stack
      tuneAdjustmentMatrix = _undoStack.removeLast();

      tuneEditorCallbacks?.handleUndo();

      setState(() {});
    }
  }

  /// Initializes the adjustment matrix with default values.
  void _setMatrixList() {
    tuneAdjustmentMatrix = tuneAdjustmentList
        .map(
          (item) => TuneAdjustmentMatrix(
            id: item.id,
            value: 0,
            matrix: item.toMatrix(0),
          ),
        )
        .toList();
  }

  /// Handles changes in the tune factor value.
  void onChanged(double value) {
    var selectedItem = tuneAdjustmentList[selectedIndex];

    int index =
        tuneAdjustmentMatrix.indexWhere((item) => item.id == selectedItem.id);

    var item = TuneAdjustmentMatrix(
      id: selectedItem.id,
      value: value,
      matrix: selectedItem.toMatrix(value),
    );
    if (index >= 0) {
      tuneAdjustmentMatrix[index] = item;
    } else {
      tuneAdjustmentMatrix.add(item);
    }

    /// Important that the hash-code update
    tuneAdjustmentMatrix = [...tuneAdjustmentMatrix];

    uiStream.add(null);
    tuneEditorCallbacks?.handleTuneFactorChange(tuneAdjustmentMatrix);
  }

  /// Saves the current state to the undo stack before making changes.
  void onChangedStart(double value) {
    // Save current state to undo stack before making changes
    _undoStack.add(
      tuneAdjustmentMatrix.map((e) => e.copy()).toList(),
    );
    // Clear redo stack because a new change is made
    _redoStack.clear();
  }

  /// Handles the end of changes in the tune factor value.
  void onChangedEnd(double value) {
    setState(() {});

    tuneEditorCallbacks?.handleTuneFactorChangeEnd(tuneAdjustmentMatrix);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      takeScreenshot();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme.copyWith(
          tooltipTheme: theme.tooltipTheme.copyWith(preferBelow: true)),
      child: ExtendedPopScope(
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: imageEditorTheme.uiOverlayStyle,
          child: SafeArea(
            top: tuneEditorConfigs.safeArea.top,
            bottom: tuneEditorConfigs.safeArea.bottom,
            left: tuneEditorConfigs.safeArea.left,
            right: tuneEditorConfigs.safeArea.right,
            child: RecordInvisibleWidget(
              controller: screenshotCtrl,
              child: Scaffold(
                backgroundColor: imageEditorTheme.tuneEditor.background,
                appBar: _buildAppBar(),
                body: _buildBody(),
                bottomNavigationBar: _buildBottomNavBar(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the app bar for the tune editor.
  PreferredSizeWidget? _buildAppBar() {
    if (customWidgets.tuneEditor.appBar != null) {
      return customWidgets.tuneEditor.appBar!
          .call(this, rebuildController.stream);
    }
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: imageEditorTheme.tuneEditor.appBarBackgroundColor,
      foregroundColor: imageEditorTheme.tuneEditor.appBarForegroundColor,
      actions: [
        IconButton(
          tooltip: i18n.tuneEditor.back,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(icons.backButton),
          onPressed: close,
        ),
        const Spacer(),
        IconButton(
          tooltip: i18n.tuneEditor.undo,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(
            icons.undoAction,
            color: canUndo ? Colors.white : Colors.white.withAlpha(80),
          ),
          onPressed: canUndo ? undo : null,
        ),
        IconButton(
          tooltip: i18n.tuneEditor.redo,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(
            icons.redoAction,
            color: canRedo ? Colors.white : Colors.white.withAlpha(80),
          ),
          onPressed: canRedo ? redo : null,
        ),
        IconButton(
          tooltip: i18n.tuneEditor.done,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(icons.applyChanges),
          iconSize: 28,
          onPressed: done,
        ),
      ],
    );
  }

  /// Builds the main content area of the editor.
  Widget _buildBody() {
    return LayoutBuilder(builder: (context, constraints) {
      editorBodySize = constraints.biggest;
      return ContentRecorder(
        controller: screenshotCtrl,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            Hero(
              tag: heroTag,
              createRectTween: (begin, end) =>
                  RectTween(begin: begin, end: end),
              child: TransformedContentGenerator(
                configs: configs,
                transformConfigs:
                    initialTransformConfigs ?? TransformConfigs.empty(),
                child: StreamBuilder(
                    stream: uiStream.stream,
                    builder: (context, snapshot) {
                      return FilteredImage(
                        width:
                            getMinimumSize(mainImageSize, editorBodySize).width,
                        height: getMinimumSize(mainImageSize, editorBodySize)
                            .height,
                        configs: configs,
                        image: editorImage,
                        filters: appliedFilters,
                        tuneAdjustments: tuneAdjustmentMatrix,
                        blurFactor: appliedBlurFactor,
                      );
                    }),
              ),
            ),
            if (tuneEditorConfigs.showLayers && layers != null)
              LayerStack(
                transformHelper: TransformHelper(
                  mainBodySize: getMinimumSize(mainBodySize, editorBodySize),
                  mainImageSize: getMinimumSize(mainImageSize, editorBodySize),
                  editorBodySize: editorBodySize,
                  transformConfigs: initialTransformConfigs,
                ),
                configs: configs,
                layers: layers!,
                clipBehavior: Clip.none,
              ),
            if (customWidgets.tuneEditor.bodyItems != null)
              ...customWidgets.tuneEditor.bodyItems!(
                  this, rebuildController.stream),
          ],
        ),
      );
    });
  }

  /// Builds the bottom navigation bar with tune options.
  Widget? _buildBottomNavBar() {
    if (customWidgets.tuneEditor.bottomBar != null) {
      return customWidgets.tuneEditor.bottomBar!
          .call(this, rebuildController.stream);
    }
    var bottomTextStyle = const TextStyle(fontSize: 10.0);
    double bottomIconSize = 22.0;

    return SafeArea(
      child: Container(
        color: imageEditorTheme.tuneEditor.bottomBarColor,
        padding: const EdgeInsets.only(top: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: RepaintBoundary(
                child: StreamBuilder(
                    stream: uiStream.stream,
                    builder: (context, snapshot) {
                      var activeOption = tuneAdjustmentList[selectedIndex];
                      var activeMatrix = tuneAdjustmentMatrix[selectedIndex];
                      return SizedBox(
                        height: 40,
                        child: customWidgets.tuneEditor.slider?.call(
                              this,
                              rebuildController.stream,
                              activeMatrix.value,
                              onChanged,
                              onChangedEnd,
                            ) ??
                            Slider(
                              min: activeOption.min,
                              max: activeOption.max,
                              divisions: activeOption.divisions,
                              label: (activeMatrix.value *
                                      activeOption.labelMultiplier)
                                  .round()
                                  .toString(),
                              value: activeMatrix.value,
                              onChangeStart: onChangedStart,
                              onChanged: onChanged,
                              onChangeEnd: onChangedEnd,
                            ),
                      );
                    }),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: kBottomNavigationBarHeight,
              child: Scrollbar(
                controller: bottomBarScrollCtrl,
                scrollbarOrientation: ScrollbarOrientation.bottom,
                thickness: isDesktop ? null : 0,
                child: SingleChildScrollView(
                  controller: bottomBarScrollCtrl,
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children:
                          List.generate(tuneAdjustmentMatrix.length, (index) {
                        var item = tuneAdjustmentList[index];
                        return FlatIconTextButton(
                          label: Text(
                            item.label,
                            style: bottomTextStyle.copyWith(
                              color: selectedIndex == index
                                  ? imageEditorTheme
                                      .tuneEditor.bottomBarActiveItemColor
                                  : imageEditorTheme
                                      .tuneEditor.bottomBarInactiveItemColor,
                            ),
                          ),
                          icon: Icon(
                            item.icon,
                            size: bottomIconSize,
                            color: selectedIndex == index
                                ? imageEditorTheme
                                    .tuneEditor.bottomBarActiveItemColor
                                : imageEditorTheme
                                    .tuneEditor.bottomBarInactiveItemColor,
                          ),
                          onPressed: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
