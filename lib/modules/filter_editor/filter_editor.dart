import 'dart:io';

import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:colorfilter_generator/presets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pro_image_editor/models/filter_state_history.dart';
import 'package:screenshot/screenshot.dart';

import '../../models/custom_widgets.dart';
import '../../models/editor_configs/filter_editor_configs.dart';
import '../../models/editor_image.dart';
import '../../models/theme/theme.dart';
import '../../models/i18n/i18n.dart';
import '../../models/icons/icons.dart';
import '../../utils/design_mode.dart';
import '../../widgets/loading_dialog.dart';
import '../../widgets/pro_image_editor_desktop_mode.dart';
import 'widgets/image_with_filter.dart';

/// The `FilterEditor` widget allows users to apply filters to images.
///
/// You can create a `FilterEditor` using one of the factory methods provided:
/// - `FilterEditor.file`: Loads an image from a file.
/// - `FilterEditor.asset`: Loads an image from an asset.
/// - `FilterEditor.network`: Loads an image from a network URL.
/// - `FilterEditor.memory`: Loads an image from memory as a `Uint8List`.
/// - `FilterEditor.autoSource`: Automatically selects the source based on provided parameters.
class FilterEditor extends StatefulWidget {
  /// A byte array representing the image data.
  final Uint8List? byteArray;

  /// The file representing the image.
  final File? file;

  /// The asset path of the image.
  final String? assetPath;

  /// The network URL of the image.
  final String? networkUrl;

  /// The theme configuration for the editor.
  final ThemeData theme;

  /// The design mode of the editor.
  final ImageEditorDesignModeE designMode;

  /// The internationalization (i18n) configuration for the editor.
  final I18n i18n;

  /// Custom widgets configuration for the editor.
  final ImageEditorCustomWidgets customWidgets;

  /// Icons used in the editor.
  final ImageEditorIcons icons;

  /// The theme configuration specific to the image editor.
  final ImageEditorTheme imageEditorTheme;

  /// A hero tag to enable hero transitions between screens.
  final String heroTag;

  /// Configuration settings for the `FilterEditor`.
  final FilterEditorConfigs configs;

  /// A callback function that can be used to update the UI from custom widgets.
  final Function? onUpdateUI;

  /// Determines whether to return the image as a Uint8List when closing the editor.
  ///
  /// If set to `true`, when closing the editor, the editor will return the final image
  /// as a Uint8List, including all applied filter states. If set to `false`, only
  /// the filter states will be returned.
  final bool convertToUint8List;

  final List<FilterStateHistory>? activeFilters;

  /// Private constructor for creating a `FilterEditor` widget.
  const FilterEditor._({
    super.key,
    this.byteArray,
    this.file,
    this.assetPath,
    this.networkUrl,
    this.onUpdateUI,
    this.convertToUint8List = false,
    this.activeFilters,
    required this.theme,
    required this.designMode,
    required this.i18n,
    required this.customWidgets,
    required this.icons,
    required this.imageEditorTheme,
    required this.heroTag,
    required this.configs,
  }) : assert(
          byteArray != null || file != null || networkUrl != null || assetPath != null,
          'At least one of bytes, file, networkUrl, or assetPath must not be null.',
        );

  /// Create a FilterEditor widget with an in-memory image represented as a Uint8List.
  ///
  /// This factory method allows you to create a FilterEditor widget that can be used to apply various image filters and edit an image represented as a Uint8List in memory. The provided parameters allow you to customize the appearance and behavior of the FilterEditor widget.
  ///
  /// Parameters:
  /// - `byteArray`: A Uint8List representing the image data in memory.
  /// - `key`: An optional Key to uniquely identify this widget in the widget tree.
  /// - `theme`: An optional ThemeData object that defines the visual styling of the FilterEditor widget.
  /// - `designMode`: An optional ImageEditorDesignMode enum to specify the design mode (material or custom) of the ImageEditor.
  /// - `i18n`: An optional I18n object for localization and internationalization.
  /// - `customWidgets`: An optional CustomWidgets object for customizing the widgets used in the editor.
  /// - `icons`: An optional ImageEditorIcons object for customizing the icons used in the editor.
  /// - `imageEditorTheme`: An optional ImageEditorTheme object for customizing the overall theme of the editor.
  /// - `heroTag`: An optional String used to create a hero animation between two FilterEditor instances.
  /// - `configs`: An optional FilterEditorConfigs object for customizing the behavior of the FilterEditor.
  /// - `convertToUint8List`: Determines whether to return the image as a Uint8List when closing the editor.
  ///
  /// Returns:
  /// A FilterEditor widget configured with the provided parameters and the in-memory image data.
  ///
  /// Example Usage:
  /// ```dart
  /// final Uint8List imageBytes = ... // Load your image data here.
  /// final filterEditor = FilterEditor.memory(
  ///   imageBytes,
  ///   theme: ThemeData.light(),
  ///   designMode: ImageEditorDesignMode.material,
  ///   heroTag: 'unique_hero_tag',
  /// );
  /// ```
  factory FilterEditor.memory(
    Uint8List byteArray, {
    Key? key,
    required ThemeData theme,
    ImageEditorDesignModeE designMode = ImageEditorDesignModeE.material,
    I18n i18n = const I18n(),
    ImageEditorCustomWidgets customWidgets = const ImageEditorCustomWidgets(),
    ImageEditorIcons icons = const ImageEditorIcons(),
    ImageEditorTheme imageEditorTheme = const ImageEditorTheme(),
    FilterEditorConfigs configs = const FilterEditorConfigs(),
    required String heroTag,
    Function? onUpdateUI,
    bool convertToUint8List = false,
    List<FilterStateHistory>? activeFilters,
  }) {
    return FilterEditor._(
      key: key,
      byteArray: byteArray,
      theme: theme,
      designMode: designMode,
      i18n: i18n,
      customWidgets: customWidgets,
      icons: icons,
      imageEditorTheme: imageEditorTheme,
      heroTag: heroTag,
      configs: configs,
      onUpdateUI: onUpdateUI,
      activeFilters: activeFilters,
      convertToUint8List: convertToUint8List,
    );
  }

  /// Create a FilterEditor widget with an image loaded from a File.
  ///
  /// This factory method allows you to create a FilterEditor widget that can be used to apply various image filters and edit an image loaded from a File. The provided parameters allow you to customize the appearance and behavior of the FilterEditor widget.
  ///
  /// Parameters:
  /// - `file`: A File object representing the image file to be loaded.
  /// - `key`: An optional Key to uniquely identify this widget in the widget tree.
  /// - `theme`: An optional ThemeData object that defines the visual styling of the FilterEditor widget.
  /// - `designMode`: An optional ImageEditorDesignMode enum to specify the design mode (material or custom) of the ImageEditor.
  /// - `i18n`: An optional I18n object for localization and internationalization.
  /// - `customWidgets`: An optional CustomWidgets object for customizing the widgets used in the editor.
  /// - `icons`: An optional ImageEditorIcons object for customizing the icons used in the editor.
  /// - `imageEditorTheme`: An optional ImageEditorTheme object for customizing the overall theme of the editor.
  /// - `heroTag`: An optional String used to create a hero animation between two FilterEditor instances.
  /// - `configs`: An optional FilterEditorConfigs object for customizing the behavior of the FilterEditor.
  /// - `convertToUint8List`: Determines whether to return the image as a Uint8List when closing the editor.
  ///
  /// Returns:
  /// A FilterEditor widget configured with the provided parameters and the image loaded from the File.
  ///
  /// Example Usage:
  /// ```dart
  /// final File imageFile = ... // Provide the image file.
  /// final filterEditor = FilterEditor.file(
  ///   imageFile,
  ///   theme: ThemeData.light(),
  ///   designMode: ImageEditorDesignMode.material,
  ///   heroTag: 'unique_hero_tag',
  /// );
  /// ```
  factory FilterEditor.file(
    File file, {
    Key? key,
    required ThemeData theme,
    ImageEditorDesignModeE designMode = ImageEditorDesignModeE.material,
    I18n i18n = const I18n(),
    ImageEditorCustomWidgets customWidgets = const ImageEditorCustomWidgets(),
    ImageEditorIcons icons = const ImageEditorIcons(),
    ImageEditorTheme imageEditorTheme = const ImageEditorTheme(),
    FilterEditorConfigs configs = const FilterEditorConfigs(),
    required String heroTag,
    Function? onUpdateUI,
    bool convertToUint8List = false,
    List<FilterStateHistory>? activeFilters,
  }) {
    return FilterEditor._(
      key: key,
      file: file,
      theme: theme,
      designMode: designMode,
      i18n: i18n,
      customWidgets: customWidgets,
      icons: icons,
      imageEditorTheme: imageEditorTheme,
      heroTag: heroTag,
      configs: configs,
      onUpdateUI: onUpdateUI,
      activeFilters: activeFilters,
      convertToUint8List: convertToUint8List,
    );
  }

  /// Create a FilterEditor widget with an image loaded from an asset.
  ///
  /// This factory method allows you to create a FilterEditor widget that can be used to apply various image filters and edit an image loaded from an asset. The provided parameters allow you to customize the appearance and behavior of the FilterEditor widget.
  ///
  /// Parameters:
  /// - `assetPath`: A String representing the asset path of the image to be loaded.
  /// - `key`: An optional Key to uniquely identify this widget in the widget tree.
  /// - `theme`: An optional ThemeData object that defines the visual styling of the FilterEditor widget.
  /// - `designMode`: An optional ImageEditorDesignMode enum to specify the design mode (material or custom) of the ImageEditor.
  /// - `i18n`: An optional I18n object for localization and internationalization.
  /// - `customWidgets`: An optional CustomWidgets object for customizing the widgets used in the editor.
  /// - `icons`: An optional ImageEditorIcons object for customizing the icons used in the editor.
  /// - `imageEditorTheme`: An optional ImageEditorTheme object for customizing the overall theme of the editor.
  /// - `heroTag`: An optional String used to create a hero animation between two FilterEditor instances.
  /// - `configs`: An optional FilterEditorConfigs object for customizing the behavior of the FilterEditor.
  /// - `convertToUint8List`: Determines whether to return the image as a Uint8List when closing the editor.
  ///
  /// Returns:
  /// A FilterEditor widget configured with the provided parameters and the image loaded from the asset.
  ///
  /// Example Usage:
  /// ```dart
  /// final String assetPath = 'assets/image.png'; // Provide the asset path.
  /// final filterEditor = FilterEditor.asset(
  ///   assetPath,
  ///   theme: ThemeData.light(),
  ///   designMode: ImageEditorDesignMode.material,
  ///   heroTag: 'unique_hero_tag',
  /// );
  /// ```
  factory FilterEditor.asset(
    String assetPath, {
    Key? key,
    required ThemeData theme,
    ImageEditorDesignModeE designMode = ImageEditorDesignModeE.material,
    I18n i18n = const I18n(),
    ImageEditorCustomWidgets customWidgets = const ImageEditorCustomWidgets(),
    ImageEditorIcons icons = const ImageEditorIcons(),
    ImageEditorTheme imageEditorTheme = const ImageEditorTheme(),
    FilterEditorConfigs configs = const FilterEditorConfigs(),
    required String heroTag,
    Function? onUpdateUI,
    bool convertToUint8List = false,
    List<FilterStateHistory>? activeFilters,
  }) {
    return FilterEditor._(
      key: key,
      assetPath: assetPath,
      theme: theme,
      designMode: designMode,
      i18n: i18n,
      customWidgets: customWidgets,
      icons: icons,
      imageEditorTheme: imageEditorTheme,
      heroTag: heroTag,
      configs: configs,
      onUpdateUI: onUpdateUI,
      activeFilters: activeFilters,
      convertToUint8List: convertToUint8List,
    );
  }

  /// Create a FilterEditor widget with an image loaded from a network URL.
  ///
  /// This factory method allows you to create a FilterEditor widget that can be used to apply various image filters and edit an image loaded from a network URL. The provided parameters allow you to customize the appearance and behavior of the FilterEditor widget.
  ///
  /// Parameters:
  /// - `networkUrl`: A String representing the network URL of the image to be loaded.
  /// - `key`: An optional Key to uniquely identify this widget in the widget tree.
  /// - `theme`: An optional ThemeData object that defines the visual styling of the FilterEditor widget.
  /// - `designMode`: An optional ImageEditorDesignMode enum to specify the design mode (material or custom) of the ImageEditor.
  /// - `i18n`: An optional I18n object for localization and internationalization.
  /// - `customWidgets`: An optional CustomWidgets object for customizing the widgets used in the editor.
  /// - `icons`: An optional ImageEditorIcons object for customizing the icons used in the editor.
  /// - `imageEditorTheme`: An optional ImageEditorTheme object for customizing the overall theme of the editor.
  /// - `heroTag`: An optional String used to create a hero animation between two FilterEditor instances.
  /// - `convertToUint8List`: Determines whether to return the image as a Uint8List when closing the editor.
  ///
  /// Returns:
  /// A FilterEditor widget configured with the provided parameters and the image loaded from the network URL.
  ///
  /// Example Usage:
  /// ```dart
  /// final String imageUrl = 'https://example.com/image.jpg'; // Provide the network URL.
  /// final filterEditor = FilterEditor.network(
  ///   imageUrl,
  ///   theme: ThemeData.light(),
  ///   designMode: ImageEditorDesignMode.material,
  /// );
  /// ```
  factory FilterEditor.network(
    String networkUrl, {
    Key? key,
    required ThemeData theme,
    ImageEditorDesignModeE designMode = ImageEditorDesignModeE.material,
    I18n i18n = const I18n(),
    ImageEditorCustomWidgets customWidgets = const ImageEditorCustomWidgets(),
    ImageEditorIcons icons = const ImageEditorIcons(),
    ImageEditorTheme imageEditorTheme = const ImageEditorTheme(),
    FilterEditorConfigs configs = const FilterEditorConfigs(),
    required String heroTag,
    Function? onUpdateUI,
    bool convertToUint8List = false,
    List<FilterStateHistory>? activeFilters,
  }) {
    return FilterEditor._(
      key: key,
      networkUrl: networkUrl,
      theme: theme,
      designMode: designMode,
      i18n: i18n,
      customWidgets: customWidgets,
      icons: icons,
      imageEditorTheme: imageEditorTheme,
      heroTag: heroTag,
      configs: configs,
      onUpdateUI: onUpdateUI,
      activeFilters: activeFilters,
      convertToUint8List: convertToUint8List,
    );
  }

  /// Create a FilterEditor widget with automatic image source detection.
  ///
  /// This factory method allows you to create a FilterEditor widget with automatic detection of the image source type (Uint8List, File, asset, or network URL). Based on the provided parameters, it selects the appropriate source type and creates the FilterEditor widget accordingly.
  ///
  /// Parameters:
  /// - `key`: An optional Key to uniquely identify this widget in the widget tree.
  /// - `theme`: An optional ThemeData object that defines the visual styling of the FilterEditor widget.
  /// - `designMode`: An optional ImageEditorDesignMode enum to specify the design mode (material or custom) of the ImageEditor.
  /// - `i18n`: An optional I18n object for localization and internationalization.
  /// - `customWidgets`: An optional CustomWidgets object for customizing the widgets used in the editor.
  /// - `icons`: An optional ImageEditorIcons object for customizing the icons used in the editor.
  /// - `imageEditorTheme`: An optional ImageEditorTheme object for customizing the overall theme of the editor.
  /// - `heroTag`: An optional String used to create a hero animation between two FilterEditor instances.
  /// - `byteArray`: An optional Uint8List representing the image data in memory.
  /// - `file`: An optional File object representing the image file to be loaded.
  /// - `assetPath`: An optional String representing the asset path of the image to be loaded.
  /// - `networkUrl`: An optional String representing the network URL of the image to be loaded.
  /// - `convertToUint8List`: Determines whether to return the image as a Uint8List when closing the editor.
  ///
  /// Returns:
  /// A FilterEditor widget configured with the provided parameters and the detected image source.
  ///
  /// Example Usage:
  /// ```dart
  /// // Provide one of the image sources: byteArray, file, assetPath, or networkUrl.
  /// final filterEditor = FilterEditor.autoSource(
  ///   byteArray: imageBytes,
  ///   theme: ThemeData.light(),
  ///   designMode: ImageEditorDesignMode.material,
  /// );
  /// ```
  factory FilterEditor.autoSource({
    Key? key,
    required ThemeData theme,
    ImageEditorDesignModeE designMode = ImageEditorDesignModeE.material,
    I18n i18n = const I18n(),
    ImageEditorCustomWidgets customWidgets = const ImageEditorCustomWidgets(),
    ImageEditorIcons icons = const ImageEditorIcons(),
    ImageEditorTheme imageEditorTheme = const ImageEditorTheme(),
    FilterEditorConfigs configs = const FilterEditorConfigs(),
    required String heroTag,
    Function? onUpdateUI,
    bool convertToUint8List = false,
    List<FilterStateHistory>? activeFilters,
    Uint8List? byteArray,
    File? file,
    String? assetPath,
    String? networkUrl,
  }) {
    if (byteArray != null) {
      return FilterEditor.memory(
        byteArray,
        key: key,
        theme: theme,
        designMode: designMode,
        i18n: i18n,
        customWidgets: customWidgets,
        icons: icons,
        imageEditorTheme: imageEditorTheme,
        heroTag: heroTag,
        configs: configs,
        onUpdateUI: onUpdateUI,
        activeFilters: activeFilters,
        convertToUint8List: convertToUint8List,
      );
    } else if (file != null) {
      return FilterEditor.file(
        file,
        key: key,
        theme: theme,
        designMode: designMode,
        i18n: i18n,
        customWidgets: customWidgets,
        icons: icons,
        imageEditorTheme: imageEditorTheme,
        heroTag: heroTag,
        configs: configs,
        onUpdateUI: onUpdateUI,
        activeFilters: activeFilters,
        convertToUint8List: convertToUint8List,
      );
    } else if (networkUrl != null) {
      return FilterEditor.network(
        networkUrl,
        key: key,
        theme: theme,
        designMode: designMode,
        i18n: i18n,
        customWidgets: customWidgets,
        icons: icons,
        imageEditorTheme: imageEditorTheme,
        heroTag: heroTag,
        configs: configs,
        onUpdateUI: onUpdateUI,
        activeFilters: activeFilters,
        convertToUint8List: convertToUint8List,
      );
    } else if (assetPath != null) {
      return FilterEditor.asset(
        assetPath,
        key: key,
        theme: theme,
        designMode: designMode,
        i18n: i18n,
        customWidgets: customWidgets,
        icons: icons,
        imageEditorTheme: imageEditorTheme,
        heroTag: heroTag,
        configs: configs,
        onUpdateUI: onUpdateUI,
        activeFilters: activeFilters,
        convertToUint8List: convertToUint8List,
      );
    } else {
      throw ArgumentError("Either 'byteArray', 'file', 'networkUrl' or 'assetPath' must be provided.");
    }
  }

  @override
  createState() => FilterEditorState();
}

/// The state class for the `FilterEditor` widget.
class FilterEditorState extends State<FilterEditor> {
  late ScrollController _scrollCtrl;
  late Image decodedImage;
  ColorFilterGenerator selectedFilter = PresetFilters.none;
  Uint8List resizedImage = Uint8List.fromList([]);
  double filterOpacity = 1;
  bool _createScreenshot = false;
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    _scrollCtrl = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  /// Closes the editor without applying changes.
  void close() {
    Navigator.pop(context);
  }

  /// Handles the "Done" action, either by applying changes or closing the editor.
  void done() async {
    if (_createScreenshot) return;

    if (widget.convertToUint8List) {
      _createScreenshot = true;
      LoadingDialog loading = LoadingDialog()
        ..show(
          context,
          i18n: widget.i18n,
          theme: widget.theme,
          designMode: widget.designMode,
          message: widget.i18n.filterEditor.applyFilterDialogMsg,
          imageEditorTheme: widget.imageEditorTheme,
        );
      var data = await screenshotController.capture();
      _createScreenshot = false;
      if (mounted) {
        loading.hide(context);
        Navigator.pop(context, data);
      }
    } else {
      FilterStateHistory filter = FilterStateHistory(
        filter: selectedFilter,
        opacity: filterOpacity,
      );
      Navigator.pop(context, filter);
    }
  }

  /// A list of `ColorFilterGenerator` objects that define the image filters available in the editor.
  List<ColorFilterGenerator> get _filters => widget.configs.filterList ?? presetFiltersList;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.theme.copyWith(tooltipTheme: widget.theme.tooltipTheme.copyWith(preferBelow: true)),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: widget.imageEditorTheme.uiOverlayStyle,
        child: Scaffold(
          backgroundColor: widget.imageEditorTheme.filterEditor.background,
          appBar: _buildAppBar(),
          body: _buildBody(),
          bottomNavigationBar: _buildBottomNavBar(),
        ),
      ),
    );
  }

  /// Builds the app bar for the filter editor.
  PreferredSizeWidget _buildAppBar() {
    return widget.customWidgets.appBarFilterEditor ??
        AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: widget.imageEditorTheme.filterEditor.appBarBackgroundColor,
          foregroundColor: widget.imageEditorTheme.filterEditor.appBarForegroundColor,
          actions: [
            IconButton(
              tooltip: widget.i18n.filterEditor.back,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: Icon(widget.icons.backButton),
              onPressed: close,
            ),
            const Spacer(),
            IconButton(
              tooltip: widget.i18n.filterEditor.done,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: Icon(widget.icons.applyChanges),
              iconSize: 28,
              onPressed: done,
            ),
          ],
        );
  }

  /// Builds the main content area of the editor.
  Widget _buildBody() {
    return Center(
      child: Screenshot(
        controller: screenshotController,
        child: Hero(
          tag: widget.heroTag,
          createRectTween: (begin, end) => RectTween(begin: begin, end: end),
          child: ImageWithFilter(
            image: EditorImage(
              file: widget.file,
              byteArray: widget.byteArray,
              networkUrl: widget.networkUrl,
              assetPath: widget.assetPath,
            ),
            activeFilters: widget.activeFilters,
            designMode: widget.designMode,
            filter: selectedFilter,
            fit: BoxFit.contain,
            opacity: filterOpacity,
          ),
        ),
      ),
    );
  }

  /// Builds the bottom navigation bar with filter options.
  Widget _buildBottomNavBar() {
    return SafeArea(
      child: SizedBox(
        height: 160,
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: selectedFilter == PresetFilters.none
                  ? null
                  : Slider(
                      min: 0,
                      max: 1,
                      divisions: 100,
                      value: filterOpacity,
                      onChanged: (value) {
                        filterOpacity = value;
                        setState(() {});
                        widget.onUpdateUI?.call();
                      },
                    ),
            ),
            _buildFilterList(),
          ],
        ),
      ),
    );
  }

  /// Builds a horizontal list of filter preview buttons.
  SizedBox _buildFilterList() {
    return SizedBox(
      height: 120,
      child: Scrollbar(
        controller: _scrollCtrl,
        scrollbarOrientation: ScrollbarOrientation.bottom,
        thumbVisibility: isDesktop,
        trackVisibility: isDesktop,
        child: ListView(
          controller: _scrollCtrl,
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            for (int i = 0; i < _filters.length; i++)
              filterPreviewButton(
                filter: _filters[i],
                name: _filters[i].name,
                index: i,
                activeFilters: widget.activeFilters,
              ),
          ],
        ),
      ),
    );
  }

  /// Create a button for filter preview.
  Widget filterPreviewButton({
    required ColorFilterGenerator filter,
    required String name,
    required int index,
    List<FilterStateHistory>? activeFilters,
  }) {
    var size = const Size(64, 64);
    return GestureDetector(
      key: ValueKey('Filter-$name-$index'),
      onTap: () {
        selectedFilter = filter;
        setState(() {});
        widget.onUpdateUI?.call();
      },
      child: Column(children: [
        Container(
          height: size.height,
          width: size.width,
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: const Color(0xFF242424),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: ImageWithFilter(
              image: EditorImage(
                file: widget.file,
                byteArray: widget.byteArray,
                networkUrl: widget.networkUrl,
                assetPath: widget.assetPath,
              ),
              activeFilters: widget.activeFilters,
              size: size,
              designMode: widget.designMode,
              filter: filter,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Text(
          widget.i18n.filterEditor.filters.getFilterI18n(name),
          style: TextStyle(fontSize: 12, color: widget.imageEditorTheme.filterEditor.previewTextColor),
        ),
      ]),
    );
  }
}
