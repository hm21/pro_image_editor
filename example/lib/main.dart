import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pro_image_editor/modules/crop_rotate_editor/utils/crop_aspect_ratios.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/widgets/loading_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pro-Image-Editor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade800),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _editor = GlobalKey<ProImageEditorState>();

  Future<Uint8List> loadImageBytes() async {
    final ByteData data = await rootBundle.load('assets/demo.png');
    return data.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pro-Image-Editor'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProImageEditor.asset(
                        'assets/demo.png',
                        onImageEditingComplete: (bytes) async {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.folder_outlined),
                label: const Text('Editor from Asset'),
              ),
              const SizedBox(height: 30),
              if (!kIsWeb) ...[
                OutlinedButton.icon(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: FileType.image,
                    );

                    if (result != null && mounted) {
                      File file = File(result.files.single.path!);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProImageEditor.file(
                            file,
                            onImageEditingComplete: (Uint8List bytes) async {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.sd_card_outlined),
                  label: const Text('Editor from File'),
                ),
                const SizedBox(height: 30),
              ],
              OutlinedButton.icon(
                onPressed: () async {
                  LoadingDialog loading = LoadingDialog()
                    ..show(
                      context,
                      theme: Theme.of(context),
                      imageEditorTheme: const ImageEditorTheme(
                        loadingDialogTextColor: Colors.black,
                      ),
                      designMode: ImageEditorDesignModeE.material,
                      i18n: const I18n(),
                    );
                  var url = 'https://picsum.photos/2000';
                  var bytes = await fetchImageAsUint8List(url);
                  if (mounted) await loading.hide(context);
                  if (mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProImageEditor.memory(
                          bytes,
                          key: _editor,
                          onImageEditingComplete: (bytes) async {
                            Navigator.pop(context);
                          },
                          configs: ProImageEditorConfigs(
                            activePreferredOrientations: [
                              DeviceOrientation.portraitUp,
                              DeviceOrientation.portraitDown,
                              DeviceOrientation.landscapeLeft,
                              DeviceOrientation.landscapeRight,
                            ],
                            i18n: const I18n(
                              various: I18nVarious(
                                loadingDialogMsg: 'Please wait...',
                                closeEditorWarningTitle: 'Close Image Editor?',
                                closeEditorWarningMessage: 'Are you sure you want to close the Image Editor? Your changes will not be saved.',
                                closeEditorWarningConfirmBtn: 'OK',
                                closeEditorWarningCancelBtn: 'Cancel',
                              ),
                              paintEditor: I18nPaintingEditor(
                                bottomNavigationBarText: 'Paint',
                                freestyle: 'Freestyle',
                                arrow: 'Arrow',
                                line: 'Line',
                                rectangle: 'Rectangle',
                                circle: 'Circle',
                                dashLine: 'Dash line',
                                lineWidth: 'Line width',
                                toggleFill: 'Toggle fill',
                                undo: 'Undo',
                                redo: 'Redo',
                                done: 'Done',
                                back: 'Back',
                                smallScreenMoreTooltip: 'More',
                              ),
                              textEditor: I18nTextEditor(
                                inputHintText: 'Enter text',
                                bottomNavigationBarText: 'Text',
                                back: 'Back',
                                done: 'Done',
                                textAlign: 'Align text',
                                backgroundMode: 'Background mode',
                                smallScreenMoreTooltip: 'More',
                              ),
                              cropRotateEditor: I18nCropRotateEditor(
                                bottomNavigationBarText: 'Crop/ Rotate',
                                rotate: 'Rotate',
                                ratio: 'Ratio',
                                back: 'Back',
                                done: 'Done',
                                aspectRatioFree: 'Free',
                                aspectRatioOriginal: 'Original',
                                prepareImageDialogMsg: 'Please wait',
                                applyChangesDialogMsg: 'Please wait',
                                smallScreenMoreTooltip: 'More',
                              ),
                              filterEditor: I18nFilterEditor(
                                applyFilterDialogMsg: 'Filter is being applied.',
                                bottomNavigationBarText: 'Filter',
                                back: 'Back',
                                done: 'Done',
                                filters: I18nFilters(
                                  none: 'No Filter',
                                  addictiveBlue: 'AddictiveBlue',
                                  addictiveRed: 'AddictiveRed',
                                  aden: 'Aden',
                                  amaro: 'Amaro',
                                  ashby: 'Ashby',
                                  brannan: 'Brannan',
                                  brooklyn: 'Brooklyn',
                                  charmes: 'Charmes',
                                  clarendon: 'Clarendon',
                                  crema: 'Crema',
                                  dogpatch: 'Dogpatch',
                                  earlybird: 'Earlybird',
                                  f1977: '1977',
                                  gingham: 'Gingham',
                                  ginza: 'Ginza',
                                  hefe: 'Hefe',
                                  helena: 'Helena',
                                  hudson: 'Hudson',
                                  inkwell: 'Inkwell',
                                  juno: 'Juno',
                                  kelvin: 'Kelvin',
                                  lark: 'Lark',
                                  loFi: 'Lo-Fi',
                                  ludwig: 'Ludwig',
                                  maven: 'Maven',
                                  mayfair: 'Mayfair',
                                  moon: 'Moon',
                                  nashville: 'Nashville',
                                  perpetua: 'Perpetua',
                                  reyes: 'Reyes',
                                  rise: 'Rise',
                                  sierra: 'Sierra',
                                  skyline: 'Skyline',
                                  slumber: 'Slumber',
                                  stinson: 'Stinson',
                                  sutro: 'Sutro',
                                  toaster: 'Toaster',
                                  valencia: 'Valencia',
                                  vesper: 'Vesper',
                                  walden: 'Walden',
                                  willow: 'Willow',
                                  xProII: 'Pro II',
                                ),
                              ),
                              emojiEditor: I18nEmojiEditor(
                                bottomNavigationBarText: 'Emoji',
                              ),
                              cancel: 'Cancel',
                              undo: 'Undo',
                              redo: 'Redo',
                              done: 'Done',
                              remove: 'Remove',
                              doneLoadingMsg: 'Changes are being applied',
                            ),
                            helperLines: const HelperLines(
                              showVerticalLine: true,
                              showHorizontalLine: true,
                              showRotateLine: true,
                              hitVibration: true,
                            ),
                            customWidgets: const ImageEditorCustomWidgets(),
                            imageEditorTheme: const ImageEditorTheme(
                              layerHoverCursor: SystemMouseCursors.move,
                              helperLine: HelperLineTheme(
                                horizontalColor: Color(0xFF1565C0),
                                verticalColor: Color(0xFF1565C0),
                                rotateColor: Color(0xFFE91E63),
                              ),
                              paintingEditor: PaintingEditorTheme(
                                appBarBackgroundColor: Color(0xFF000000),
                                lineWidthBottomSheetColor: Color(0xFF252728),
                                appBarForegroundColor: Color(0xFFE1E1E1),
                                background: Color.fromARGB(255, 22, 22, 22),
                                bottomBarColor: Color(0xFF000000),
                                bottomBarActiveItemColor: Color(0xFF004C9E),
                                bottomBarInactiveItemColor: Color(0xFFEEEEEE),
                              ),
                              textEditor: TextEditorTheme(
                                appBarBackgroundColor: Color(0xFF000000),
                                appBarForegroundColor: Color(0xFFE1E1E1),
                                background: Color.fromARGB(155, 0, 0, 0),
                                inputHintColor: Color(0xFFBDBDBD),
                                inputCursorColor: Color(0xFF004C9E),
                              ),
                              cropRotateEditor: CropRotateEditorTheme(
                                appBarBackgroundColor: Color(0xFF000000),
                                appBarForegroundColor: Color(0xFFE1E1E1),
                                background: Color.fromARGB(255, 22, 22, 22),
                                cropCornerColor: Color(0xFF004C9E),
                              ),
                              filterEditor: FilterEditorTheme(
                                appBarBackgroundColor: Color(0xFF000000),
                                appBarForegroundColor: Color(0xFFE1E1E1),
                                previewTextColor: Color(0xFFE1E1E1),
                                background: Color.fromARGB(255, 22, 22, 22),
                              ),
                              emojiEditor: EmojiEditorTheme(
                                background: Color.fromARGB(255, 22, 22, 22),
                                indicatorColor: Color(0xFF004C9E),
                                iconColorSelected: Color(0xFF004C9E),
                                iconColor: Color(0xFF9E9E9E),
                                skinToneDialogBgColor: Color(0xFF252728),
                                skinToneIndicatorColor: Color(0xFF9E9E9E),
                              ),
                              background: Color.fromARGB(255, 22, 22, 22),
                              loadingDialogTextColor: Color(0xFFE1E1E1),
                              uiOverlayStyle: SystemUiOverlayStyle(
                                statusBarColor: Color(0x42000000),
                                statusBarIconBrightness: Brightness.light,
                                systemNavigationBarIconBrightness: Brightness.light,
                                statusBarBrightness: Brightness.dark,
                                systemNavigationBarColor: Color(0xFF000000),
                              ),
                            ),
                            icons: const ImageEditorIcons(
                              paintingEditor: IconsPaintingEditor(
                                bottomNavBar: Icons.edit_rounded,
                                lineWeight: Icons.line_weight_rounded,
                                freeStyle: Icons.edit,
                                arrow: Icons.arrow_right_alt_outlined,
                                line: Icons.horizontal_rule,
                                fill: Icons.format_color_fill,
                                noFill: Icons.format_color_reset,
                                rectangle: Icons.crop_free,
                                circle: Icons.lens_outlined,
                                dashLine: Icons.power_input,
                              ),
                              textEditor: IconsTextEditor(
                                bottomNavBar: Icons.text_fields,
                                alignLeft: Icons.align_horizontal_left_rounded,
                                alignCenter: Icons.align_horizontal_center_rounded,
                                alignRight: Icons.align_horizontal_right_rounded,
                                backgroundMode: Icons.layers_rounded,
                              ),
                              cropRotateEditor: IconsCropRotateEditor(
                                bottomNavBar: Icons.crop_rotate_rounded,
                                rotate: Icons.rotate_90_degrees_ccw_outlined,
                                aspectRatio: Icons.crop,
                              ),
                              filterEditor: IconsFilterEditor(
                                bottomNavBar: Icons.filter,
                              ),
                              emojiEditor: IconsEmojiEditor(
                                bottomNavBar: Icons.sentiment_satisfied_alt_rounded,
                              ),
                              closeEditor: Icons.clear,
                              doneIcon: Icons.done,
                              applyChanges: Icons.done,
                              backButton: Icons.arrow_back,
                              undoAction: Icons.undo,
                              redoAction: Icons.redo,
                              removeElementZone: Icons.delete_outline_rounded,
                            ),
                            paintEditorConfigs: const PaintEditorConfigs(
                              enabled: true,
                              hasOptionFreeStyle: true,
                              hasOptionArrow: true,
                              hasOptionLine: true,
                              hasOptionRect: true,
                              hasOptionCircle: true,
                              hasOptionDashLine: true,
                              canToggleFill: true,
                              canChangeLineWidth: true,
                              initialFill: false,
                              showColorPicker: true,
                              freeStyleHighPerformanceScaling: true,
                              initialStrokeWidth: 10.0,
                              initialColor: Color(0xffff0000),
                              initialPaintMode: PaintModeE.freeStyle,
                            ),
                            textEditorConfigs: const TextEditorConfigs(
                              enabled: true,
                              canToggleTextAlign: true,
                              canToggleBackgroundMode: true,
                              initFontSize: 24.0,
                              initialTextAlign: TextAlign.center,
                              initialBackgroundColorMode: LayerBackgroundColorModeE.backgroundAndColor,
                            ),
                            cropRotateEditorConfigs: const CropRotateEditorConfigs(
                              enabled: true,
                              canRotate: true,
                              canChangeAspectRatio: true,
                              initAspectRatio: CropAspectRatios.custom,
                            ),
                            filterEditorConfigs: FilterEditorConfigs(
                              enabled: true,
                              filterList: presetFiltersList,
                            ),
                            emojiEditorConfigs: const EmojiEditorConfigs(
                              enabled: true,
                              initScale: 5.0,
                              recentTabBehavior: RecentTabBehavior.RECENT,
                              enableSkinTones: true,
                              recentsLimit: 28,
                              textStyle: TextStyle(fontFamilyFallback: ['Apple Color Emoji']),
                              checkPlatformCompatibility: true,
                              emojiSet:
                                  null /*  [
                                CategoryEmoji(
                                  Category.ANIMALS,
                                  [Emoji.fromJson({})],
                                )
                              ] */
                              ,
                              verticalSpacing: 0,
                              horizontalSpacing: 0,
                              gridPadding: EdgeInsets.zero,
                              initCategory: Category.RECENT,
                              replaceEmojiOnLimitExceed: false,
                              categoryIcons: CategoryIcons(),
                              customSkinColorOverlayHorizontalOffset: 0,
                            ),
                            designMode: ImageEditorDesignModeE.material,
                            heroTag: 'hero',
                            theme: ThemeData(
                              useMaterial3: true,
                              colorScheme: ColorScheme.fromSeed(
                                seedColor: Colors.blue.shade800,
                                brightness: Brightness.dark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.memory_outlined),
                label: const Text('Editor from memory'),
              ),
              const SizedBox(height: 30),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProImageEditor.network(
                        'https://picsum.photos/id/237/2000',
                        onImageEditingComplete: (byte) async {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.public_outlined),
                label: const Text('Editor from network'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
