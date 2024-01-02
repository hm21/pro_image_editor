<h1>pro_image_editor</h1>

<!-- TODO: Remove banner  -->
# In Progress!

A Flutter image editor: Seamlessly enhance your images with user-friendly editing features.

<div>

[![pub package](https://img.shields.io/pub/v/pro_image_editor.svg)](https://pub.dartlang.org/packages/pro_image_editor)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub issues](https://img.shields.io/github/issues/hm21/pro_image_editor)](https://github.com/hm21/pro_image_editor/issues)

</div>
<!-- TODO: Write demo
<h2 >Demo</h2>
<div>
https://flutter-hm21.web.app/pro_image_editor
</div>
 -->

## Table of contents

- [Preview](#preview)
- [Example](#example)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [License](LICENSE)


<h2>Preview</h2>
<!-- TODO: write preview -->

## Getting started

### Installation

```sh
flutter pub add pro_image_editor
```

#### Android

To enable smooth hit vibrations, you need to include the `VIBRATE` permission in your `AndroidManifest.xml` file. Here's how you can do it:

``` xml
<uses-permission android:name="android.permission.VIBRATE"/>
```

#### Web

If you're displaying emojis on the web and want them to have color by default (especially if you're not using a custom font like "Noto Emoji"), 
you can achieve this by adding the "useColorEmoji: true" parameter as shown in the code snippet below:

```html
<body>
  <script>
    window.addEventListener('load', function(ev) {
      _flutter.loader.loadEntrypoint({
        serviceWorker: {
          serviceWorkerVersion: serviceWorkerVersion,
        },
        onEntrypointLoaded: function (engineInitializer) {
          engineInitializer.initializeEngine({
            useColorEmoji: true, // add this parameter
          }).then(function (appRunner) {
            appRunner.runApp();
          });
        }
      });
    });
  </script>
</body>
```


#### iOS, macOS, Linux, Windows

No further action is required.


<br/>


<h2>Example</h2>

Import first the image editor like below:
```dart
import 'package:pro_image_editor/pro_image_editor.dart';
```


#### Simple example

Use the image editor without any custom configurations.

```dart
@override
Widget build(BuildContext context) {
    return Scaffold(
        body: ProImageEditor.network(
        'https://picsum.photos/id/237/2000',
        ),
    );
}
```
#### Complex example

Customize the image editor to suit your preferences. Of course, each class like `I18nTextEditor` includes more configuration options

```dart
return Scaffold(
    appBar: AppBar(
    title: const Text('Pro-Image-Editor')
    ),
    body: ProImageEditor.network(
        'https://picsum.photos/id/237/2000',
            key: _editor,
            configs: ProImageEditorConfigs(
            activePreferredOrientations: [
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
            ],
            i18n: const I18n(
                various: I18nVarious(),
                paintEditor: I18nPaintingEditor(),
                textEditor: I18nTextEditor(),
                cropRotateEditor: I18nCropRotateEditor(),
                filterEditor: I18nFilterEditor(filters: I18nFilters()),
                emojiEditor: I18nEmojiEditor(),
                // More translations...
            ),
            helperLines: const HelperLines(
                showVerticalLine: true,
                showHorizontalLine: true,
                showRotateLine: true,
                hitVibration: true,
            ),
            customWidgets: const ProImageEditorCustomWidgets(),
            imageEditorTheme: const ImageEditorTheme(
                layerHoverCursor: SystemMouseCursors.move,
                helperLine: HelperLineTheme(
                    horizontalColor: Color(0xFF1565C0),
                    verticalColor: Color(0xFF1565C0),
                    rotateColor: Color(0xFFE91E63),
                ),
                paintingEditor: PaintingEditorTheme(),
                textEditor: TextEditorTheme(),
                cropRotateEditor: CropRotateEditorTheme(),
                filterEditor: FilterEditorTheme(),
                emojiEditor: EmojiEditorTheme(),
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
                paintingEditor: IconsPaintingEditor(),
                textEditor: IconsTextEditor(),
                cropRotateEditor: IconsCropRotateEditor(),
                filterEditor: IconsFilterEditor(),
                emojiEditor: IconsEmojiEditor(),
                closeEditor: Icons.clear,
                doneIcon: Icons.done,
                applyChanges: Icons.done,
                backButton: Icons.arrow_back,
                undoAction: Icons.undo,
                redoAction: Icons.redo,
                removeElementZone: Icons.delete_outline_rounded,
            ),
            paintEditorConfigs: const PaintEditorConfigs(),
            textEditorConfigs: const TextEditorConfigs(),
            cropRotateEditorConfigs: const CropRotateEditorConfigs(),
            filterEditorConfigs: FilterEditorConfigs(),
            emojiEditorConfigs: const EmojiEditorConfigs(),
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
    )
);
```


<h2>Documentation</h2>


## Contributing

I welcome contributions from the open-source community to make this project even better. Whether you want to report a bug, suggest a new feature, or contribute code, I appreciate your help.

### Bug Reports and Feature Requests

If you encounter a bug or have an idea for a new feature, please open an issue on my [GitHub Issues](https://github.com/hm21/pro_image_editor/issues) page. I will review it and discuss the best approach to address it.

### Code Contributions

If you'd like to contribute code to this project, please follow these steps:

1. Fork the repository to your GitHub account.
2. Clone your forked repository to your local machine.

```bash
git clone https://github.com/hm21/pro_image_editor.git
```