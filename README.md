<h1>pro_image_editor</h1>

<p>
    <a href="https://pub.dartlang.org/packages/pro_image_editor">
        <img src="https://img.shields.io/pub/v/pro_image_editor.svg" alt="pub package">
    </a>
    <a href="https://img.shields.io/github/license/hm21/pro_image_editor">
        <img src="https://img.shields.io/github/license/hm21/pro_image_editor" alt="License">
    </a>
    <a href="https://github.com/hm21/pro_image_editor/issues">
        <img src="https://img.shields.io/github/issues/hm21/pro_image_editor" alt="GitHub issues">
    </a>
    <a href="https://hm21.github.io/pro_image_editor">
        <img src="https://img.shields.io/badge/web-demo---?&color=0f7dff" alt="Web Demo">
    </a>
</p>

The ProImageEditor is a Flutter widget designed for image editing within your application. It provides a flexible and convenient way to integrate image editing capabilities into your Flutter project. 


  <a href="https://hm21.github.io/pro_image_editor">
    <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/showcase.png?raw=true" width=450 />
      <br/>
      Demo Website
  </a>

## Table of contents

- **[📷 Preview](#preview)**
- **[✨ Features](#features)**
- **[🔧 Getting started](#getting-started)**
  - [Android](#android)
  - [Web](#web)
- **[❓ Usage](#usage)**
  - [Open the editor in a new page](#open-the-editor-in-a-new-page)
  - [Show the editor inside of a widget](#show-the-editor-inside-of-a-widget)
  - [Own stickers or widgets](#own-stickers-or-widgets)
  - [WhatsApp-Design](#whatsapp-design)
  - [Highly configurable](#highly-configurable)
  - [Custom AppBar](#custom-appbar)
  - [Import-Export state history](#import-export-state-history)
- **[📚 Documentation](#documentation)**
- **[🤝 Contributing](#contributing)**
- **[📜 License](LICENSE)**
- **[📜 Notices](NOTICES)**



## Preview
<table>
  <thead>
    <tr>
      <th align="center">WhatsApp-Design</th>
      <th align="center">Blur-Editor</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center" width="50%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/whatsapp-design.gif?raw=true" alt="WhatsApp-Design" />
      </td>
      <td align="center" width="50%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/blur-editor.gif?raw=true" alt="Blur-Editor" />
      </td>
    </tr>
  </tbody>
</table>
<table>
  <thead>
    <tr>
      <th align="center">Paint-Editor</th>
      <th align="center">Text-Editor</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center" width="50%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/paint-editor.gif?raw=true" alt="Paint-Editor" />
      </td>
      <td align="center" width="50%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/text-editor.gif?raw=true" alt="Text-Editor" />
      </td>
    </tr>
  </tbody>
</table>
<table>
  <thead>
    <tr>
      <th align="center">Crop-Rotate-Editor</th>
      <th align="center">Filter-Editor</th>
    </tr>
  </thead>
  <tbody>
   <tr>
      <td align="center" width="50%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/crop-rotate-editor.gif?raw=true" alt="Crop-Rotate-Editor" />
      </td>
      <td align="center" width="50%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/filter-editor.gif?raw=true" alt="Filter-Editor" />
      </td>
    </tr>
  </tbody>
</table>

<table>
  <thead>
    <tr>
      <th align="center">Emoji-Editor</th>
      <th align="center">Sticker/ Widget Editor</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center" width="50%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/emoji-editor.gif?raw=true" alt="Emoji-Editor" />
      </td>
      <td align="center" width="50%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/sticker-editor.gif?raw=true" alt="Sticker-Widget-Editor" />
      </td>
    </tr>
  </tbody>
</table>



## Features

- ✅ Painting-Editor
  - ✅ Color picker
  - ✅ Multiple forms like arrow, rectangle, circle and freestyle
- ✅ Text-Editor
  - ✅ Color picker
  - ✅ Align-Text => left, right and center
  - ✅ Change Text Scale
  - ✅ Multiple background modes like in whatsapp
- ✅ Crop-Rotate-Editor
- ✅ Filter-Editor
- ✅ Blur-Editor
- ✅ Emoji-Picker
- ✅ Move and scalable layers
- ✅ Helper lines for better positioning
- ✅ Undo and redo function
- ✅ Use your image directly from memory, asset, file or network
- ✅ Each icon can be changed
- ✅ Any text can be translated
- ✅ Many custom configurations for each subeditor
- ✅ Custom theme for each editor
- ✅ Selectable design mode between Material and Cupertino
- ✅ Interactive layers
- ✅ Hit detection for painted layers
- ✅ Loading of stickers or widgets in the editor
- ✅ Reorder layer level
- ✅ WhatsApp Theme
- ✅ Movable background image
- ✅ Improved layer movement and scaling functionality for desktop devices


#### Future Features
- ✨ Text-layer with an improved hit-box and ensure it's vertically centered on all devices
- ✨ Enhanced crop editor with improved performance (No dependencies on `image_editor` and `extended_image`)


## Getting started

### Android

To enable smooth hit vibrations from a helper line, you need to add the `VIBRATE` permission to your `AndroidManifest.xml` file.

``` xml
<uses-permission android:name="android.permission.VIBRATE"/>
```

### Web

If you're displaying emoji on the web and want them to be colored by default (especially if you're not using a custom font like Noto Emoji), you can achieve this by adding the `useColorEmoji: true` parameter to your `index.html`, as shown in the code snippet below:

<details>
  <summary>Show code example</summary>

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
</details>

<br/>

To ensure compatibility with older Android phones and ensure that all filters you use work correctly, it's advisable to consider using the Canvaskit renderer. The default HTML renderer may encounter issues with certain filters on some devices.

To enable the Canvaskit renderer by default for better compatibility with mobile web devices, you can do the following in your `index.html`:

<details>
  <summary>Show code example</summary>

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
            useColorEmoji: true,
            renderer:'canvaskit', // add this parameter
          }).then(function (appRunner) {
            appRunner.runApp();
          });
        }
      });
    });
  </script>
</body>
```
</details>
<br/>

By making this change, you can enhance filter compatibility and ensure a smoother experience on older Android phones and various mobile web devices.


### iOS, macOS, Linux, Windows

No further action is required.


<br/>


## Usage

Import first the image editor like below:
```dart
import 'package:pro_image_editor/pro_image_editor.dart';
```

#### Open the editor in a new page

```dart
void _openEditor() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProImageEditor.network(
        'https://picsum.photos/id/237/2000',
        onImageEditingComplete: (byte) async {
          /*
            `Your code for handling the edited image. Upload it to your server as an example.`

            You can choose whether you want to use await, so that the loading-dialog remains visible until your code is also ready, 
            or without async, so that the loading-dialog closes immediately.
          */
          Navigator.pop(context);
        },
      ),
    ),
  );
}
```

#### Show the editor inside of a widget 

```dart
@override
Widget build(BuildContext context) {
    return Scaffold(
        body: ProImageEditor.network(
          'https://picsum.photos/id/237/2000',
           onImageEditingComplete: (Uint8List bytes) async {
              /*
               `Your code for handling the edited image. Upload it to your server as an example.`

               You can choose whether you want to use await, so that the loading-dialog remains visible until your code is also ready, 
               or without async, so that the loading-dialog closes immediately.
              */
           },
        ),
    );
}
```

#### Own stickers or widgets

To display stickers or widgets in the ProImageEditor, you have the flexibility to customize and load your own content. The `buildStickers` method allows you to define your own logic for loading stickers, whether from a backend, assets, or local storage, and then push them into the editor. The example below demonstrates how to load images that can serve as stickers and then add them to the editor:

<details>
  <summary>Show code example</summary>

```dart
ProImageEditor.network(
  'https://picsum.photos/id/156/2000',
  onImageEditingComplete: (bytes) async {
    Navigator.pop(context);
  },
  configs: ProImageEditorConfigs(
    stickerEditorConfigs: StickerEditorConfigs(
      enabled: true,
      buildStickers: (setLayer) {
         return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Container(
            color: const Color.fromARGB(255, 224, 239, 251),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 150,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: 21,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                Widget widget = ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.network(
                    'https://picsum.photos/id/${(index + 3) * 3}/2000',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      return AnimatedSwitcher(
                        layoutBuilder: (currentChild, previousChildren) {
                          return SizedBox(
                            width: 120,
                            height: 120,
                            child: Stack(
                              fit: StackFit.expand,
                              alignment: Alignment.center,
                              children: <Widget>[
                                ...previousChildren,
                                if (currentChild != null) currentChild,
                              ],
                            ),
                          );
                        },
                        duration: const Duration(milliseconds: 200),
                        child: loadingProgress == null
                            ? child
                            : Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                      );
                    },
                  ),
                );
                return GestureDetector(
                  onTap: () => setLayer(widget),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: widget,
                  ),
                );
              },
            ),
          ),
        );
      },
    ),
  ),
),
```
</details>

#### WhatsApp design

The image editor offers a WhatsApp-themed option that mirrors the popular messaging app's design.
The editor also follows the small changes that exist in the Material (Android) and Cupertino (iOS) version.

<details>
  <summary>Show code example</summary>
  
```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => ProImageEditor.network(
      'https://picsum.photos/id/176/2000',
      onImageEditingComplete: (bytes) async {
         /*
          Your code for handling the edited image. Upload it to your server as an example.

          You can choose whether you want to use await, so that the loading-dialog remains visible until your code is also ready, 
          or without async, so that the loading-dialog closes immediately.
        */
        Navigator.pop(context);
      },
      configs: ProImageEditorConfigs(
        textEditorConfigs: TextEditorConfigs(
          whatsAppCustomTextStyles: [
            GoogleFonts.roboto(),
            GoogleFonts.averiaLibre(),
            GoogleFonts.lato(),
            GoogleFonts.comicNeue(),
            GoogleFonts.actor(),
            GoogleFonts.odorMeanChey(),
            GoogleFonts.nabla(),
          ],
        ),
        imageEditorTheme: const ImageEditorTheme(
          editorMode: ThemeEditorMode.whatsapp,
          helperLine: HelperLineTheme(
            horizontalColor: Color.fromARGB(255, 129, 218, 88),
            verticalColor: Color.fromARGB(255, 129, 218, 88),
          ),
        ),
        paintEditorConfigs: const PaintEditorConfigs(
          initialStrokeWidth: 5,
        ),
        filterEditorConfigs: FilterEditorConfigs(
          whatsAppFilterTextOffsetY: 90,
          filterList: [
            ColorFilterGenerator(
              name: "None",
              filters: [],
            ),
            ColorFilterGenerator(
              name: "Pop",
              filters: [
                ColorFilterAddons.colorOverlay(255, 225, 80, 0.08),
                ColorFilterAddons.saturation(0.1),
                ColorFilterAddons.contrast(0.05),
              ],
            ),
            ColorFilterGenerator(
              name: "B&W",
              filters: [
                ColorFilterAddons.grayscale(),
                ColorFilterAddons.colorOverlay(100, 28, 210, 0.03),
                ColorFilterAddons.brightness(0.1),
              ],
            ),
            ColorFilterGenerator(
              name: "Cool",
              filters: [
                ColorFilterAddons.addictiveColor(0, 0, 20),
              ],
            ),
            ColorFilterGenerator(
              name: "Chrome",
              filters: [
                ColorFilterAddons.contrast(0.15),
                ColorFilterAddons.saturation(0.2),
              ],
            ),
            ColorFilterGenerator(
              name: "Film",
              filters: [
                ColorFilterAddons.brightness(.05),
                ColorFilterAddons.saturation(-0.03),
              ],
            ),
          ],
        ),
        stickerEditorConfigs: StickerEditorConfigs(
          enabled: true,
          onSearchChanged: (value) {
            /// Filter your stickers
            debugPrint(value);
          },
          buildStickers: (setLayer) {
            List<String> demoTitels = ['Recent', 'Favorites', 'Shapes', 'Funny', 'Boring', 'Frog', 'Snow', 'More'];
            List<Widget> slivers = [];
            int offset = 0;
            for (var element in demoTitels) {
              slivers.addAll([
                _buildDemoStickersTitle(element),
                _buildDemoStickers(offset, setLayer),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ]);
              offset += 20;
            }

            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                    child: CustomScrollView(
                      slivers: slivers,
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  color: Colors.grey.shade800,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.watch_later_outlined),
                        color: Colors.white,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.mood),
                        color: Colors.white,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.pets),
                        color: Colors.white,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.coronavirus),
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        customWidgets: ImageEditorCustomWidgets(
          whatsAppBottomWidget: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 7, 16, 12),
                  child: TextField(
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      filled: true,
                      isDense: true,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 7.0),
                        child: Icon(
                          Icons.add_photo_alternate_rounded,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                      hintText: 'Add a caption...',
                      hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 238, 238, 238),
                        fontWeight: FontWeight.w400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: const Color(0xFF202D35),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 7, 16, 12),
                  color: Colors.black38,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: const Color(0xFF202D35),
                        ),
                        child: const Text(
                          'Alex Frei',
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.send),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF0DA886),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ),
  ),
);
```
</details>

#### Highly configurable

Customize the image editor to suit your preferences. Of course, each class like `I18nTextEditor` includes more configuration options.

<details>
  <summary>Show code example</summary>

```dart
return Scaffold(
    appBar: AppBar(
      title: const Text('Pro-Image-Editor')
    ),
    body: ProImageEditor.network(
        'https://picsum.photos/id/237/2000',
            key: _editor,
            onImageEditingComplete: (Uint8List bytes) async {
              /*
               `Your code for handling the edited image. Upload it to your server as an example.`

               You can choose whether you want to use await, so that the loading-dialog remains visible until your code is also ready, 
               or without async, so that the loading-dialog closes immediately.
              */
            },
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
                  stickerEditor: I18nStickerEditor(),
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
                  stickerEditor: StickerEditorTheme(),
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
                  stickerEditor: IconsStickerEditor(),
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
              stickerEditorConfigs: StickerEditorConfigs(
                enabled: true,
                buildStickers: (setLayer) {
                  return ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Container(
                      color: const Color.fromARGB(255, 224, 239, 251),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 150,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                        itemCount: 21,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          Widget widget = ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: Image.network(
                              'https://picsum.photos/id/${(index + 3) * 3}/2000',
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          );
                          return GestureDetector(
                            onTap: () => setLayer(widget),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: widget,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
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
    )
);
```
</details>

#### Custom AppBar

Customize the AppBar with your own widgets. The same is also possible with the BottomBar.

<details>
  <summary>Show code example</summary>

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class Demo extends StatefulWidget {
  const Demo({super.key});

  @override
  State<Demo> createState() => DemoState();
}

class DemoState extends State<Demo> {
  final _editorKey = GlobalKey<ProImageEditorState>();
  late StreamController _updateAppBarStream;

  @override
  void initState() {
    _updateAppBarStream = StreamController.broadcast();
    super.initState();
  }

  @override
  void dispose() {
    _updateAppBarStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProImageEditor.network(
      'https://picsum.photos/id/237/2000',
      key: _editorKey,
      onImageEditingComplete: (byte) async {
        Navigator.pop(context);
      },
      onUpdateUI: () {
        _updateAppBarStream.add(null);
      },
      configs: ProImageEditorConfigs(
        customWidgets: ImageEditorCustomWidgets(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            foregroundColor: Colors.white,
            backgroundColor: Colors.black,
            actions: [
              StreamBuilder(
                  stream: _updateAppBarStream.stream,
                  builder: (_, __) {
                    return IconButton(
                      tooltip: 'Cancel',
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      icon: const Icon(Icons.close),
                      onPressed: _editorKey.currentState?.closeEditor,
                    );
                  }),
              const Spacer(),
              IconButton(
                tooltip: 'Custom Icon',
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(
                  Icons.bug_report,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
              StreamBuilder(
                stream: _updateAppBarStream.stream,
                builder: (_, __) {
                  return IconButton(
                    tooltip: 'Undo',
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    icon: Icon(
                      Icons.undo,
                      color: _editorKey.currentState?.canUndo == true ? Colors.white : Colors.white.withAlpha(80),
                    ),
                    onPressed: _editorKey.currentState?.undoAction,
                  );
                },
              ),
              StreamBuilder(
                stream: _updateAppBarStream.stream,
                builder: (_, __) {
                  return IconButton(
                    tooltip: 'Redo',
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    icon: Icon(
                      Icons.redo,
                      color: _editorKey.currentState?.canRedo == true ? Colors.white : Colors.white.withAlpha(80),
                    ),
                    onPressed: _editorKey.currentState?.redoAction,
                  );
                },
              ),
              StreamBuilder(
                  stream: _updateAppBarStream.stream,
                  builder: (_, __) {
                    return IconButton(
                      tooltip: 'Done',
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      icon: const Icon(Icons.done),
                      iconSize: 28,
                      onPressed: _editorKey.currentState?.doneEditing,
                    );
                  }),
            ],
          ),
          appBarPaintingEditor: AppBar(
            automaticallyImplyLeading: false,
            foregroundColor: Colors.white,
            backgroundColor: Colors.black,
            actions: [
              StreamBuilder(
                  stream: _updateAppBarStream.stream,
                  builder: (_, __) {
                    return IconButton(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _editorKey.currentState?.paintingEditor.currentState?.close,
                    );
                  }),
              const SizedBox(width: 80),
              const Spacer(),
              StreamBuilder(
                  stream: _updateAppBarStream.stream,
                  builder: (_, __) {
                    return IconButton(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      icon: const Icon(
                        Icons.line_weight_rounded,
                        color: Colors.white,
                      ),
                      onPressed: _editorKey.currentState?.paintingEditor.currentState?.openLineWeightBottomSheet,
                    );
                  }),
              StreamBuilder(
                  stream: _updateAppBarStream.stream,
                  builder: (_, __) {
                    return IconButton(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        icon: Icon(
                          _editorKey.currentState?.paintingEditor.currentState?.fillBackground == true
                              ? Icons.format_color_reset
                              : Icons.format_color_fill,
                          color: Colors.white,
                        ),
                        onPressed: _editorKey.currentState?.paintingEditor.currentState?.toggleFill);
                  }),
              const Spacer(),
              IconButton(
                tooltip: 'Custom Icon',
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(
                  Icons.bug_report,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
              StreamBuilder(
                  stream: _updateAppBarStream.stream,
                  builder: (_, __) {
                    return IconButton(
                      tooltip: 'Undo',
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      icon: Icon(
                        Icons.undo,
                        color: _editorKey.currentState?.paintingEditor.currentState?.canUndo == true ? Colors.white : Colors.white.withAlpha(80),
                      ),
                      onPressed: _editorKey.currentState?.paintingEditor.currentState?.undoAction,
                    );
                  }),
              StreamBuilder(
                  stream: _updateAppBarStream.stream,
                  builder: (_, __) {
                    return IconButton(
                      tooltip: 'Redo',
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      icon: Icon(
                        Icons.redo,
                        color: _editorKey.currentState?.paintingEditor.currentState?.canRedo == true ? Colors.white : Colors.white.withAlpha(80),
                      ),
                      onPressed: _editorKey.currentState?.paintingEditor.currentState?.redoAction,
                    );
                  }),
              StreamBuilder(
                  stream: _updateAppBarStream.stream,
                  builder: (_, __) {
                    return IconButton(
                      tooltip: 'Done',
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      icon: const Icon(Icons.done),
                      iconSize: 28,
                      onPressed: _editorKey.currentState?.paintingEditor.currentState?.done,
                    );
                  }),
            ],
          ),
          appBarTextEditor: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            actions: [
              StreamBuilder(
                  stream: _updateAppBarStream.stream,
                  builder: (_, __) {
                    return IconButton(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _editorKey.currentState?.textEditor.currentState?.close,
                    );
                  }),
              const Spacer(),
              IconButton(
                tooltip: 'Custom Icon',
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(
                  Icons.bug_report,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
              StreamBuilder(
                  stream: _updateAppBarStream.stream,
                  builder: (_, __) {
                    return IconButton(
                      onPressed: _editorKey.currentState?.textEditor.currentState?.toggleTextAlign,
                      icon: Icon(
                        _editorKey.currentState?.textEditor.currentState?.align == TextAlign.left
                            ? Icons.align_horizontal_left_rounded
                            : _editorKey.currentState?.textEditor.currentState?.align == TextAlign.right
                                ? Icons.align_horizontal_right_rounded
                                : Icons.align_horizontal_center_rounded,
                      ),
                    );
                  }),
              StreamBuilder(
                  stream: _updateAppBarStream.stream,
                  builder: (_, __) {
                    return IconButton(
                      onPressed: _editorKey.currentState?.textEditor.currentState?.toggleBackgroundMode,
                      icon: const Icon(Icons.layers_rounded),
                    );
                  }),
              const Spacer(),
              StreamBuilder(
                  stream: _updateAppBarStream.stream,
                  builder: (_, __) {
                    return IconButton(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      icon: const Icon(Icons.done),
                      iconSize: 28,
                      onPressed: _editorKey.currentState?.textEditor.currentState?.done,
                    );
                  }),
            ],
          ),
          appBarCropRotateEditor: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            actions: [
              StreamBuilder(
                  stream: _updateAppBarStream.stream,
                  builder: (_, __) {
                    return IconButton(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _editorKey.currentState?.cropRotateEditor.currentState?.close,
                    );
                  }),
              const Spacer(),
              IconButton(
                tooltip: 'Custom Icon',
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(
                  Icons.bug_report,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
              StreamBuilder(
                  stream: _updateAppBarStream.stream,
                  builder: (_, __) {
                    return IconButton(
                      icon: const Icon(Icons.rotate_90_degrees_ccw_outlined),
                      onPressed: _editorKey.currentState?.cropRotateEditor.currentState?.rotate,
                    );
                  }),
              StreamBuilder(
                  stream: _updateAppBarStream.stream,
                  builder: (_, __) {
                    return IconButton(
                      key: const ValueKey('pro-image-editor-aspect-ratio-btn'),
                      icon: const Icon(Icons.crop),
                      onPressed: _editorKey.currentState?.cropRotateEditor.currentState?.openAspectRatioOptions,
                    );
                  }),
              const Spacer(),
              StreamBuilder(
                  stream: _updateAppBarStream.stream,
                  builder: (_, __) {
                    return IconButton(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      icon: const Icon(Icons.done),
                      iconSize: 28,
                      onPressed: _editorKey.currentState?.cropRotateEditor.currentState?.done,
                    );
                  }),
            ],
          ),
          appBarFilterEditor: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            actions: [
              StreamBuilder(
                  stream: _updateAppBarStream.stream,
                  builder: (_, __) {
                    return IconButton(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _editorKey.currentState?.filterEditor.currentState?.close,
                    );
                  }),
              const Spacer(),
              IconButton(
                tooltip: 'Custom Icon',
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(
                  Icons.bug_report,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
              StreamBuilder(
                  stream: _updateAppBarStream.stream,
                  builder: (_, __) {
                    return IconButton(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      icon: const Icon(Icons.done),
                      iconSize: 28,
                      onPressed: _editorKey.currentState?.filterEditor.currentState?.done,
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
```
</details>

#### Import-Export state history

The state history from the image editor can be exported and imported. However, it's important to note that the crop and rotate feature currently only allows exporting the final cropped image and not individual states. Additionally, all sticker widgets are converted into images and saved in that format during the export process.

##### Export example


<details>
  <summary>Show code example</summary>

```dart
 await _editor.currentState?.exportStateHistory(
    // All configurations are optional
    configs: const ExportEditorConfigs(
      exportPainting: true,
      exportText: true,
      exportCropRotate: false,
      exportFilter: true,
      exportEmoji: true,
      exportSticker: true,
      historySpan: ExportHistorySpan.all,
    ),
  ).toJson(); // or => toMap(), toFile()
```
</details>

##### Import example

<details>
  <summary>Show code example</summary>

```dart
 _editor.currentState?.importStateHistory(
    // or => fromMap(), fromJsonFile()
    ImportStateHistory.fromJson( 
      /* Json-String from your exported state history */,
      configs: const ImportEditorConfigs(
        mergeMode: ImportEditorMergeMode.replace,
        recalculateSizeAndPosition: true,
      ),
    ),
  );
```
</details>

##### Initial import example

If you wish to open the editor directly with your exported state history, you can do so by utilizing the import feature. Simply load the exported state history into the editor, and it will recreate the previous editing session, allowing you to continue where you left off.

<details>
  <summary>Show code example</summary>

```dart
ProImageEditor.memory(
  bytes,
  key: _editor,
  onImageEditingComplete: (bytes) async {
    /* Your code for handling the edited image. Upload it to your server as an example. */
  },
  configs: ProImageEditorConfigs(
    initStateHistory: ImportStateHistory.fromJson( 
      /* Json-String from your exported state history */,
      configs: const ImportEditorConfigs(
        mergeMode: ImportEditorMergeMode.replace,
        recalculateSizeAndPosition: true,
      ),
    ),
  ),
);
```
</details>

## Documentation

### Interactive layers

Each layer, whether it's an emoji, text, or painting, is interactive, allowing you to manipulate them in various ways. You can move and scale layers using intuitive gestures. Holding a layer with one finger enables you to move it across the canvas. Holding a layer with one finger and using another to pinch or spread allows you to scale and rotate the layer.

On desktop devices, you can click and hold a layer with the mouse to move it. Additionally, using the mouse wheel lets you scale the layer. To rotate a layer, simply press the 'Shift' or 'Ctrl' key while interacting with it.


### Editor Widget
| Property                        | Description                                                                                               |
|---------------------------------|-----------------------------------------------------------------------------------------------------------|
| `byteArray`                     | Image data as a `Uint8List` from memory.                                                                  |
| `file`                          | File object representing the image file.                                                                  |
| `assetPath`                     | Path to the image asset.                                                                                  |
| `networkUrl`                    | URL of the image to be loaded from the network.                                                           |
| `onImageEditingComplete`        | Callback function that is invoked when editing is finished and returns the edited image as a `Uint8List`. |
| `allowCompleteWithEmptyEditing` | Whether [onImageEditingComplete] call with empty editing.                                                 |                                                |
| `configs`                       | Configuration options for the image editor.                                                               |


#### Constructors

##### `ProImageEditor.memory`

Creates a `ProImageEditor` widget for editing an image from memory.

##### `ProImageEditor.file`

Creates a `ProImageEditor` widget for editing an image from a file.

##### `ProImageEditor.asset`

Creates a `ProImageEditor` widget for editing an image from an asset.

##### `ProImageEditor.network`

Creates a `ProImageEditor` widget for editing an image from a network URL.

### ProImageEditorConfigs
 | Property Name              | Description                                                                                                                    | Default Value                                               |
|---------------------------|--------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------|
| `i18n`                    | Internationalization settings for the Image Editor.                                                                            | `I18n()`                                       |
| `helperLines`             | Configuration options for helper lines in the Image Editor.                                                                    | `HelperLines()`                                |
| `customWidgets`           | Custom widgets to be used in the Image Editor.                                                                                 | `ImageEditorCustomWidgets()`                   |
| `imageEditorTheme`        | Theme settings for the Image Editor.                                                                                           | `ImageEditorTheme()`                           |
| `icons`                   | Icons to be used in the Image Editor.                                                                                          | `ImageEditorIcons()`                           |
| `paintEditorConfigs`      | Configuration options for the Paint Editor.                                                                                    | `PaintEditorConfigs()`                         |
| `textEditorConfigs`       | Configuration options for the Text Editor.                                                                                     | `TextEditorConfigs()`                          |
| `cropRotateEditorConfigs` | Configuration options for the Crop and Rotate Editor.                                                                          | `CropRotateEditorConfigs()`                    |
| `filterEditorConfigs`     | Configuration options for the Filter Editor.                                                                                   | `FilterEditorConfigs()`                        |
| `blurEditorConfigs`       | Configuration options for the Blur Editor.                                                                                     | `BlurEditorConfigs()`                          |
| `emojiEditorConfigs`      | Configuration options for the Emoji Editor.                                                                                    | `EmojiEditorConfigs()`                         |
| `stickerEditorConfigs`    | Configuration options for the Sticker Editor.                                                                                  | `StickerEditorConfigs()`                       |
| `designMode`              | The design mode for the Image Editor.                                                                                          | `ImageEditorDesignModeE.material`              |
| `theme`                   | The theme to be used for the Image Editor.                                                                                     | `null`                                         |
| `heroTag`                 | A unique hero tag for the Image Editor widget.                                                                                 | `'Pro-Image-Editor-Hero'`                      |
| `activePreferredOrientations` | The editor currently supports only 'portraitUp' orientation. After closing the editor, it will revert to your default settings. | `[DeviceOrientation.portraitUp, DeviceOrientation.portraitDown, DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]` |


<details>
  <summary><b>i18n</b> </summary>
 
| Property             | Description                                                   | Default Value             |
|----------------------|---------------------------------------------------------------|---------------------------|
| `paintEditor`        | Translations and messages specific to the painting editor.    | `I18nPaintingEditor()`    |
| `textEditor`         | Translations and messages specific to the text editor.        | `I18nTextEditor()`        |
| `cropRotateEditor`   | Translations and messages specific to the crop and rotate editor. | `I18nCropRotateEditor()` |
| `filterEditor`       | Translations and messages specific to the filter editor.      | `I18nFilterEditor()`      |
| `blurEditor`         | Translations and messages specific to the blur editor.        | `I18nBlurEditor()`        |
| `emojiEditor`        | Translations and messages specific to the emoji editor.       | `I18nEmojiEditor()`       |
| `stickerEditor`      | Translations and messages specific to the sticker editor.     | `I18nStickerEditor()`     |
| `various`            | Translations and messages for various parts of the editor.    | `I18nVarious()`           |
| `cancel`             | The text for the "Cancel" button.                             | `'Cancel'`                |
| `undo`               | The text for the "Undo" action.                               | `'Undo'`                  |
| `redo`               | The text for the "Redo" action.                               | `'Redo'`                  |
| `done`               | The text for the "Done" action.                               | `'Done'`                  |
| `remove`             | The text for the "Remove" action.                             | `'Remove'`                |
| `doneLoadingMsg`     | Message displayed while changes are being applied.            | `'Changes are being applied'` |

#### `i18n paintEditor`

| Property                 | Description                                                    | Default Value      |
|--------------------------|----------------------------------------------------------------|--------------------|
| `bottomNavigationBarText`| Text for the bottom navigation bar item                        | `'Paint'`            |
| `freestyle`              | Text for the "Freestyle" painting mode                         | `'Freestyle'`        |
| `arrow`                  | Text for the "Arrow" painting mode                             | `'Arrow'`            |
| `line`                   | Text for the "Line" painting mode                              | `'Line'`             |
| `rectangle`              | Text for the "Rectangle" painting mode                         | `'Rectangle'`        |
| `circle`                 | Text for the "Circle" painting mode                            | `'Circle'`           |
| `dashLine`               | Text for the "Dash line" painting mode                         | `'Dash line'`        |
| `lineWidth`              | Text for the "Line width" tooltip                              | `'Line width'`       |
| `toggleFill`             | Text for the "Toggle fill" tooltip                             | `'Toggle fill'`      |
| `undo`                   | Text for the "Undo" button                                     | `'Undo'`             |
| `redo`                   | Text for the "Redo" button                                     | `'Redo'`             |
| `done`                   | Text for the "Done" button                                     | `'Done'`             |
| `back`                   | Text for the "Back" button                                     | `'Back'`             |
| `smallScreenMoreTooltip` | Tooltip text for the "More" option on small screens            | `'More'`             |


#### `i18n textEditor`

| Property                  | Description                                         | Default Value       |
|---------------------------|-----------------------------------------------------|---------------------|
| `bottomNavigationBarText` | Text for the bottom navigation bar item             | `'Text'`            |
| `inputHintText`           | Placeholder text displayed in the text input field  | `'Enter text'`      |
| `done`                    | Text for the "Done" button                          | `'Done'`            |
| `back`                    | Text for the "Back" button                          | `'Back'`            |
| `textAlign`               | Text for the "Align text" setting                   | `'Align text'`      |
| `fontScale`               | Text for the "Font Scale" setting                   | `'Font Scale'`      |
| `backgroundMode`          | Text for the "Background mode" setting              | `'Background mode'` |
| `smallScreenMoreTooltip`  | Tooltip text for the "More" option on small screens | `'More'`            |


#### `i18n cropRotateEditor`

| Property                 | Description                                        | Default Value                    |
|--------------------------|----------------------------------------------------|----------------------------------|
| `bottomNavigationBarText`| Text for the bottom navigation bar item            | `'Crop/ Rotate'`                   |
| `rotate`                 | Text for the "Rotate" tooltip                      | `'Rotate'`                         |
| `ratio`                  | Text for the "Ratio" tooltip                       | `'Ratio'`                          |
| `back`                   | Text for the "Back" button                          | `'Back'`                           |
| `done`                   | Text for the "Done" button                          | `'Done'`                           |
| `applyChangesDialogMsg`  | Text for the message during the application of changes| `'Please wait while applying changes...'` |
| `prepareImageDialogMsg`  | Text for the message when preparing the image      | `'Please wait while preparing the image...'` |
| `aspectRatioFree`        | Text for the "Free" aspect ratio option             | `'Free'`                           |
| `aspectRatioOriginal`    | Text for the "Original" aspect ratio option         | `'Original'`                       |
| `smallScreenMoreTooltip` | Tooltip text for the "More" option on small screens| `'More'`                           |


#### `i18n filterEditor`

| Property                 | Description                                        | Default Value                    |
|--------------------------|----------------------------------------------------|----------------------------------|
| `applyFilterDialogMsg`   | Text displayed when a filter is being applied    | `'Filter is being applied.'`       |
| `bottomNavigationBarText`| Text for the bottom navigation bar item            | `'Filter'`                         |
| `back`                   | Text for the "Back" button in the Filter Editor   | `'Back'`                           |
| `done`                   | Text for the "Done" button in the Filter Editor   | `'Done'`                           |
| `filters`                | Internationalization settings for individual filters| `I18nFilters()`                              |


#### `i18n blurEditor`

| Property                 | Description                                        | Default Value                    |
|--------------------------|----------------------------------------------------|----------------------------------|
| `applyBlurDialogMsg`     | Text displayed when a filter is being applied     | `'Blur is being applied.'`      |
| `bottomNavigationBarText`| Text for the bottom navigation bar item           | `'Blur'`                           |
| `back`                   | Text for the "Back" button in the Blur Editor     | `'Back'`                           |
| `done`                   | Text for the "Done" button in the Blur Editor     | `'Done'`                           |


#### `i18n emojiEditor`
| Property                  | Description                                                            | Default Value |
|---------------------------|------------------------------------------------------------------------|---------------|
| `bottomNavigationBarText` | Text for the bottom navigation bar item that opens the Emoji Editor.   | 'Emoji'       |


#### `i18n stickerEditor`
| Property                  | Description                                                            | Default Value |
|---------------------------|------------------------------------------------------------------------|---------------|
| `bottomNavigationBarText` | Text for the bottom navigation bar item that opens the Sticker Editor. | 'Stickers'    |


#### `i18n various`

| Property                      | Description                                                             | Default Value                                         |
| ----------------------------- | ----------------------------------------------------------------------- | ----------------------------------------------------- |
| `loadingDialogMsg`            | Text for the loading dialog message.                                    | `'Please wait...'`                                      |
| `closeEditorWarningTitle`     | Title for the warning message when closing the Image Editor.            | `'Close Image Editor?'`                                 |
| `closeEditorWarningMessage`   | Warning message when closing the Image Editor.                          | `'Are you sure you want to close the Image Editor? Your changes will not be saved.'` |
| `closeEditorWarningConfirmBtn`| Text for the confirmation button in the close editor warning dialog.    | `'OK'`                                                  |
| `closeEditorWarningCancelBtn` | Text for the cancel button in the close editor warning dialog.         | `'Cancel'`                                              |
</details>


<details>
  <summary><b>helperLines</b></summary>

| Property             | Description                                                                                   | Default Value |
|----------------------|-----------------------------------------------------------------------------------------------|---------------|
| `showVerticalLine`   | Specifies whether to show the vertical helper line.                                           | `true`        |
| `showHorizontalLine` | Specifies whether to show the horizontal helper line.                                         | `true`        |
| `showRotateLine`     | Specifies whether to show the rotate helper line.                                             | `true`        |
| `hitVibration`       | Controls whether haptic feedback is enabled when a layer intersects with a helper line. When set to `true`, haptic feedback is triggered when a layer's position or boundary intersects with a helper line, providing tactile feedback to the user. This feature enhances the user experience by providing feedback on layer alignment. By default, this option is set to `true`, enabling haptic feedback for hit detection with helper lines. You can set it to `false` to disable haptic feedback. | `true`        |
</details>


<details>
  <summary><b>customWidgets</b></summary>

| Property                | Description                                                           |
| ----------------------- | --------------------------------------------------------------------- |
| `removeLayer`           | A custom widget for removing a layer or element from the editor interface. |
| `appBar`                | A custom app bar widget for the top navigation bar.                   |
| `appBarPaintingEditor`  | A custom app bar widget for the painting editor component.            |
| `appBarTextEditor`      | A custom app bar widget for the text editor component.                |
| `appBarCropRotateEditor`| A custom app bar widget for the crop and rotate editor component.     |
| `appBarFilterEditor`    | A custom app bar widget for the filter editor component.              |
| `appBarBlurEditor`      | A custom app bar widget for the blur editor component.                |
| `bottomNavigationBar`   | A custom widget for the bottom navigation bar.                        |
</details>

<details>
  <summary><b>imageEditorTheme</b></summary>

| Property                   | Description                                                       | Default Value                                     |
| -------------------------- | ----------------------------------------------------------------- | -------------------------------------------------- |
| `paintingEditor`           | Theme for the painting editor.                                    | `PaintingEditorTheme()`                            |
| `textEditor`               | Theme for the text editor.                                        | `TextEditorTheme()`                                |
| `cropRotateEditor`         | Theme for the crop & rotate editor.                               | `CropRotateEditorTheme()`                          |
| `filterEditor`             | Theme for the filter editor.                                      | `FilterEditorTheme()`                              |
| `blurEditor`               | Theme for the blur editor.                                        | `BlurEditorTheme()`                                |
| `emojiEditor`              | Theme for the emoji editor.                                       | `EmojiEditorTheme()`                               |
| `stickerEditor`            | Theme for the sticker editor.                                     | `StickerEditorTheme()`                               |
| `helperLine`               | Theme for helper lines in the image editor.                       | `HelperLineTheme()`                                |
| `background`               | Background color for the image editor.                            | `imageEditorBackgroundColor`                       |
| `loadingDialogTextColor`   | Text color for loading dialogs.                                   | `imageEditorTextColor`                             |
| `uiOverlayStyle`           | System UI overlay style for the image editor.                      | See default values in the class definition        |
| `layerHoverCursor`         | Cursor style when hovering over a layer.                           | `SystemMouseCursors.move`     |

#### Theme paintingEditor
| Property                        | Description                                           | Default Value       |
| ------------------------------- | ----------------------------------------------------- | ------------------- |
| `appBarBackgroundColor`         | Background color of the app bar in the painting editor. | `imageEditorAppBarColor` (Default theme value) |
| `appBarForegroundColor`         | Foreground color (text and icons) of the app bar.    | `Color(0xFFE1E1E1)` |
| `background`                    | Background color of the painting editor.             | `imageEditorBackgroundColor` (Default theme value) |
| `bottomBarColor`                | Background color of the bottom navigation bar.       | `imageEditorAppBarColor` (Default theme value) |
| `bottomBarActiveItemColor`      | Color of active items in the bottom navigation bar.  | `imageEditorPrimaryColor` (Default theme value) |
| `bottomBarInactiveItemColor`    | Color of inactive items in the bottom navigation bar.| `Color(0xFFEEEEEE)` |
| `lineWidthBottomSheetColor`     | Color of the bottom sheet used to select line width.| `Color(0xFF252728)` |

#### Theme textEditor
| Property                        | Description                                           | Default Value       |
| ------------------------------- | ----------------------------------------------------- | ------------------- |
| `appBarBackgroundColor`         | Background color of the app bar in the text editor.  | `imageEditorAppBarColor` (Default theme value) |
| `appBarForegroundColor`         | Foreground color (text and icons) of the app bar.    | `Color(0xFFE1E1E1)` |
| `background`                    | Background color of the text editor.                 | `Color(0x9B000000)` |
| `inputHintColor`                | Color of input hints in the text editor.             | `Color(0xFFBDBDBD)` |
| `inputCursorColor`              | Color of the input cursor in the text editor.        | `imageEditorPrimaryColor` (Default theme value) |


#### Theme cropRotateEditor
| Property                        | Description                                           | Default Value       |
| ------------------------------- | ----------------------------------------------------- | ------------------- |
| `appBarBackgroundColor`         | Background color of the app bar in the crop and rotate editor. | `imageEditorAppBarColor` (Default theme value) |
| `appBarForegroundColor`         | Foreground color (text and icons) of the app bar.    | `Color(0xFFE1E1E1)` |
| `background`                    | Background color of the crop and rotate editor.     | `imageEditorBackgroundColor` (Default theme value) |
| `cropCornerColor`               | Color of the crop corners.                            | `imageEditorPrimaryColor` (Default theme value) |


#### Theme filterEditor
| Property                        | Description                                           | Default Value       |
| ------------------------------- | ----------------------------------------------------- | ------------------- |
| `appBarBackgroundColor`         | Background color of the app bar in the filter editor. | `imageEditorAppBarColor` (Default theme value) |
| `appBarForegroundColor`         | Foreground color (text and icons) of the app bar.    | `Color(0xFFE1E1E1)` |
| `background`                    | Background color of the filter editor.               | `imageEditorBackgroundColor` (Default theme value) |
| `previewTextColor`              | Color of the preview text.                            | `Color(0xFFE1E1E1)` |


#### Theme blurEditor
| Property                        | Description                                           | Default Value       |
| ------------------------------- | ----------------------------------------------------- | ------------------- |
| `appBarBackgroundColor`         | Background color of the app bar in the blur editor.   | `imageEditorAppBarColor` (Default theme value) |
| `appBarForegroundColor`         | Foreground color (text and icons) of the app bar.    | `Color(0xFFE1E1E1)` |
| `background`                    | Background color of the blur editor.                 | `imageEditorBackgroundColor` (Default theme value) |


#### Theme emojiEditor
| Property                  | Description                                           | Default Value                    |
| ------------------------- | ----------------------------------------------------- | -------------------------------- |
| `background`              | Background color of the emoji editor widget.          | `imageEditorBackgroundColor`     |
| `indicatorColor`          | Color of the category indicator.                      | `imageEditorPrimaryColor`        |
| `iconColorSelected`       | Color of the category icon when selected.             | `imageEditorPrimaryColor`        |
| `iconColor`               | Color of the category icons.                          | `Color(0xFF9E9E9E)`              |
| `skinToneDialogBgColor`   | Background color of the skin tone dialog.             | `Color(0xFF252728)`              |
| `skinToneIndicatorColor`  | Color of the small triangle next to skin tone emojis. | `Color(0xFF9E9E9E)`              |


#### Theme stickerEditor
| Property                  | Description                                           | Default Value                   |
| ------------------------- | ----------------------------------------------------- | ------------------------------- |


#### Theme helperLine
| Property             | Description                                             | Default Value   |
| -------------------- | ------------------------------------------------------- | ---------------- |
| `horizontalColor`    | Color of horizontal helper lines.                       | `Color(0xFF1565C0)` (Blue) |
| `verticalColor`      | Color of vertical helper lines.                         | `Color(0xFF1565C0)` (Blue) |
| `rotateColor`        | Color of rotation helper lines.                         | `Color(0xFFE91E63)` (Pink) |
</details>

<details>
  <summary><b>icons</b></summary>

| Property              | Description                                          | Default Value              |
| --------------------- | ---------------------------------------------------- | -------------------------- |
| `closeEditor`         | The icon for closing the editor without saving.      | `Icons.clear`              |
| `doneIcon`            | The icon for applying changes and closing the editor.| `Icons.done`               |
| `backButton`          | The icon for the back button.                        | `Icons.arrow_back`         |
| `applyChanges`        | The icon for applying changes in the editor.         | `Icons.done`               |
| `undoAction`          | The icon for undoing the last action.                | `Icons.undo`               |
| `redoAction`          | The icon for redoing the last undone action.         | `Icons.redo`               |
| `removeElementZone`   | The icon for removing an element/layer like an emoji.| `Icons.delete_outline_rounded` |
| `paintingEditor`      | Customizable icons for the Painting Editor component.| `IconsPaintingEditor`      |
| `textEditor`          | Customizable icons for the Text Editor component.    | `IconsTextEditor`          |
| `cropRotateEditor`    | Customizable icons for the Crop and Rotate Editor component.| `IconsCropRotateEditor` |
| `filterEditor`        | Customizable icons for the Filter Editor component.  | `IconsFilterEditor`        |
| `blurEditor`          | Customizable icons for the Blur Editor component.    | `IconsBlurEditor`          |
| `emojiEditor`         | Customizable icons for the Emoji Editor component.   | `IconsEmojiEditor`         |
| `stickerEditor`       | Customizable icons for the Sticker Editor component. | `IconsStickerEditor`       |

#### icons paintingEditor
| Property       | Description                                     | Default Value         |
| -------------- | ----------------------------------------------- | ----------------------|
| `bottomNavBar` | The icon for the bottom navigation bar.         | `Icons.edit_rounded`  |
| `lineWeight`   | The icon for adjusting line weight.             | `Icons.line_weight_rounded` |
| `freeStyle`    | The icon for the freehand drawing tool.         | `Icons.edit`          |
| `arrow`        | The icon for the arrow drawing tool.            | `Icons.arrow_right_alt_outlined` |
| `line`         | The icon for the straight line drawing tool.    | `Icons.horizontal_rule` |
| `fill`         | The icon for filling the background.            | `Icons.format_color_fill` |
| `noFill`       | The icon for not filling the background.        | `Icons.format_color_reset` |
| `rectangle`    | The icon for the rectangle drawing tool.        | `Icons.crop_free`     |
| `circle`       | The icon for the circle drawing tool.           | `Icons.lens_outlined` |
| `dashLine`     | The icon for the dashed line drawing tool.      | `Icons.power_input`   |

#### icons textEditor
| Property         | Description                                        | Default Value                           |
|------------------|----------------------------------------------------|-----------------------------------------|
| `bottomNavBar`   | The icon for the bottom navigation bar.            | `Icons.text_fields`                     |
| `alignLeft`      | The icon for aligning text to the left.            | `Icons.align_horizontal_left_rounded`   |
| `alignCenter`    | The icon for aligning text to the center.          | `Icons.align_horizontal_center_rounded` |
| `alignRight`     | The icon for aligning text to the right.           | `Icons.align_horizontal_right_rounded`  |
| `fontScale`      | The icon for changing font scale.                  | `Icons.format_size_rounded`             |
| `resetFontScale` | The icon for resetting font scale to preset value. | `Icons.refresh_rounded`                 |
| `backgroundMode` | The icon for toggling background mode.             | `Icons.layers_rounded`                  |


#### icons cropRotateEditor
| Property        | Description                   | Default Value                            |
| --------------- | ----------------------------- | ---------------------------------------- |
| `bottomNavBar`  | Icon for bottom navigation bar| `Icons.crop_rotate_rounded`              |
| `rotate`        | Icon for the rotate action    | `Icons.rotate_90_degrees_ccw_outlined`   |
| `aspectRatio`   | Icon for the aspect ratio action | `Icons.crop`                          |

#### icons filterEditor
| Property        | Description                    | Default Value  |
| --------------- | ------------------------------ | -------------- |
| `bottomNavBar`  | Icon for bottom navigation bar | `Icons.filter` |

#### icons blurEditor
| Property        | Description                    | Default Value   |
| --------------- | ------------------------------ | --------------- |
| `bottomNavBar`  | Icon for bottom navigation bar | `Icons.blur_on` |

#### icons emojiEditor
| Property        | Description                          | Default Value                       |
| --------------- | ------------------------------------ | ----------------------------------- |
| `bottomNavBar`  | Icon for bottom navigation bar       | `Icons.sentiment_satisfied_alt_rounded` |


#### icons stickerEditor
| Property        | Description                          | Default Value                       |
| --------------- | ------------------------------------ | ----------------------------------- |
| `bottomNavBar`  | Icon for bottom navigation bar       | `Icons.layers_outlined`             |

</details>

<details>
  <summary><b>paintEditorConfigs</b></summary>
 
| Property                        | Description                                       | Default Value                |
| --------------------------------| ------------------------------------------------- | -----------------------------|
| `enabled`                        | Indicates whether the paint editor is enabled.     | `true`                       |
| `hasOptionFreeStyle`             | Indicates whether the free-style drawing option is available. | `true`  |
| `hasOptionArrow`                 | Indicates whether the arrow drawing option is available. | `true`    |
| `hasOptionLine`                  | Indicates whether the line drawing option is available.  | `true`   |
| `hasOptionRect`                  | Indicates whether the rectangle drawing option is available.  | `true`  |
| `hasOptionCircle`                | Indicates whether the circle drawing option is available.  | `true`  |
| `hasOptionDashLine`              | Indicates whether the dash line drawing option is available. | `true`  |
| `showColorPicker`                | Indicates whether the color picker is visible.           | `true`   |
| `canToggleFill`                  | Indicates whether the fill option can be toggled.         | `true`  |
| `canChangeLineWidth`             | Indicates whether the line width can be changed.         | `true`  |
| `initialFill`                   | Indicates the initial fill state.                       | `false`  |
| `freeStyleHighPerformanceScaling` | Enables high-performance scaling for free-style drawing. | Platform-specific (mobile: `true`, desktop: `false`) |
| `freeStyleHighPerformanceMoving` | Enables high-performance moving for free-style drawing. | Platform-specific (mobile-web: `true`, other: `false`) |
| `initialStrokeWidth`             | Indicates the initial stroke width.                    | `10.0`   |
| `initialColor`                  | Indicates the initial drawing color.                   | `Color(0xffff0000)`   |
| `initialPaintMode`              | Indicates the initial paint mode.                      | `PaintModeE.freeStyle` |
</details>

<details>
  <summary><b>textEditorConfigs</b></summary>

| Property                     | Description                                              | Default Value                                  |
|------------------------------|----------------------------------------------------------|------------------------------------------------|
| `enabled`                    | Indicates whether the text editor is enabled.            | `true`                                         |
| `canToggleTextAlign`         | Determines if the text alignment options can be toggled. | `true`                                         |
| `canToggleBackgroundMode`    | Determines if the background mode can be toggled.        | `true`                                         |
| `canChangeFontScale`         | Determines if the font scale can be change.              | `true`                                         |
| `initFontSize`               | The initial font size for text.                          | `24.0`                                         |
| `initFontScale`              | The initial font scale for text.                         | `1.0`                                          |
| `maxFontScale`               | The max font scale for text.                             | `3.0`                                          |
| `minFontSize`                | The min font scale for text.                             | `0.3`                                          |
| `initialTextAlign`           | The initial text alignment for the layer.                | `TextAlign.center`                             |
| `initialBackgroundColorMode` | The initial background color mode for the layer.         | `LayerBackgroundColorModeE.backgroundAndColor` |
</details>

<details>
  <summary><b>cropRotateEditorConfigs</b></summary>

| Property              | Description                                       | Default Value           |
|-----------------------|---------------------------------------------------|-------------------------|
| `enabled`             | Indicates whether the editor is enabled.         | `true`                  |
| `canRotate`           | Indicates whether the image can be rotated.     | `true`                  |
| `canChangeAspectRatio`| Indicates whether the aspect ratio can be changed. | `true`                  |
| `initAspectRatio`     | The initial aspect ratio for cropping.           | `CropAspectRatios.custom` |
| `allowedAspectRatios` | The allowed aspect ratios for cropping.          | `List with all options` |
</details>

<details>
  <summary><b>filterEditorConfigs</b></summary>

| Property      | Description                                     | Default Value |
|---------------|-------------------------------------------------|---------------|
| `enabled`     | Indicates whether the filter editor is enabled. | `true`        |
| `filterList`  | A list of color filter generators to apply.    | `null`        |
</details>

<details>
  <summary><b>blurEditorConfigs</b></summary>

| Property      | Description                                     | Default Value |
|---------------|-------------------------------------------------|---------------|
| `enabled`     | Indicates whether the blur editor is enabled.   | `true`        |
| `maxBlur`     | The maximum of blur to apply.                   | `2.0`         |
</details>

<details>
  <summary><b>emojiEditorConfigs</b></summary>

| Property                               | Description                                                                                           | Default Value         |
|----------------------------------------|-------------------------------------------------------------------------------------------------------|-----------------------|
| `enabled`                              | Indicates whether the emoji editor is enabled.                                                        | `true`                |
| `initScale`                            | The initial scale for displaying emojis.                                                              | `5.0`                 |
| `recentTabBehavior`                    | Defines the behavior of the recent tab (Recent, Popular).                                              | `RecentTabBehavior.RECENT` |
| `enableSkinTones`                      | Enables the feature to select skin tones for certain emojis.                                           | `true`                |
| `recentsLimit`                         | Limits the number of recently used emojis that will be saved.                                          | `28`                  |
| `textStyle`                            | Custom emoji text style to apply to emoji characters in the grid.                                      | `TextStyle(fontFamilyFallback: ['Apple Color Emoji'])` |
| `checkPlatformCompatibility`           | Verify that emoji glyph is supported by the platform (Android only).                                    | `true`                |
| `emojiSet`                             | Custom emojis; if set, overrides default emojis provided by the library.                                | `null`                |
| `initCategory`                         | The initial [Category] that will be selected. The corresponding category button in the bottom bar will be darkened. | `Category.RECENT`     |
| `verticalSpacing`                      | Vertical spacing between emojis.                                                                       | `0`                   |
| `horizontalSpacing`                    | Horizontal spacing between emojis.                                                                     | `0`                   |
| `gridPadding`                          | The padding of the GridView, default is [EdgeInsets.zero].                                             | `EdgeInsets.zero`     |
| `replaceEmojiOnLimitExceed`            | Determines whether to replace the latest emoji in the recents list when the limit is exceeded.       | `false`               |
| `categoryIcons`                        | Determines the icons to display for each [Category].                                                    | `CategoryIcons()`     |
| `customSkinColorOverlayHorizontalOffset`| Customize skin color overlay horizontal offset, especially useful when EmojiPicker is not aligned to the left border of the screen. | `null` |
</details>

<details>
  <summary><b>stickerEditorConfigs</b></summary>

| Feature           | Description                                              | Default Value |
|-------------------|----------------------------------------------------------|---------------|
| `enabled`         | Enables or disables the sticker editor.                  | `false`       |
| `initWidth`       | Sets the initial width of stickers in logical pixels.    | `100`         |
| `buildStickers`   | A callback to build custom stickers in the editor.       |               |
</details>




<br/>

### Contributing

I welcome contributions from the open-source community to make this project even better. Whether you want to report a bug, suggest a new feature, or contribute code, I appreciate your help.

#### Bug Reports and Feature Requests

If you encounter a bug or have an idea for a new feature, please open an issue on my [GitHub Issues](https://github.com/hm21/pro_image_editor/issues) page. I will review it and discuss the best approach to address it.

#### Code Contributions

If you'd like to contribute code to this project, please follow these steps:

1. Fork the repository to your GitHub account.
2. Clone your forked repository to your local machine.

```bash
git clone https://github.com/hm21/pro_image_editor.git
```

<br/>

### Inspiration

This package is inspired by the [image_editor_plus](https://pub.dev/packages/image_editor_plus) package, which is also a great tool for image editing in Flutter.

<br/>

### Included Packages

This package uses several Flutter packages to provide a seamless editing experience. Here's a list of the packages used in this project:

- [image_editor](https://pub.dev/packages/image_editor) 
- [extended_image](https://pub.dev/packages/extended_image) 
- [rounded_background_text](https://pub.dev/packages/rounded_background_text)
- [colorfilter_generator](https://pub.dev/packages/colorfilter_generator)
- [emoji_picker_flutter](https://pub.dev/packages/emoji_picker_flutter)
- [screenshot](https://pub.dev/packages/screenshot)
- [vibration](https://pub.dev/packages/vibration)
- [image](https://pub.dev/packages/image)
- [http](https://pub.dev/packages/http)
- [defer_pointer](https://pub.dev/packages/defer_pointer)

These packages play a crucial role in enabling various features and functionalities in this package.
