<img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/logo.jpg?raw=true" alt="Logo" />

<p>
    <a href="https://pub.dartlang.org/packages/pro_image_editor">
        <img src="https://img.shields.io/pub/v/pro_image_editor.svg" alt="pub package">
    </a>
    <a href="https://github.com/sponsors/hm21">
        <img src="https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23f5372a" alt="Sponsor">
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

<a href="https://hm21.github.io/pro_image_editor">Demo Website</a>

## Table of contents

- **[📷 Preview](#preview)**
- **[✨ Features](#features)**
- **[🔧 Setup](#setup)**
- **[❓ Usage](#usage)**
- **[📽️ Video-Editor](#video-editor)**
- **[💖 Sponsors](#sponsors)**
- **[📦 Included Packages](#included-packages)**
- **[🤝 Contributors](#contributors)**
- **[📜 License](LICENSE)**
- **[📜 Notices](NOTICES)**



## Preview
<table>
  <thead>
    <tr>
      <th align="center">Grounded-Design</th>
      <th align="center">Frosted-Glass-Design</th>
      <th align="center">WhatsApp-Design</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center" width="33.3%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/preview/grounded-design.gif?raw=true" alt="Grounded-Design" />
      </td>
      <td align="center" width="33.3%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/preview/frosted-glass-design.gif?raw=true" alt="Frosted-Glass-Design" />
      </td>
      <td align="center" width="33.3%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/preview/whatsapp-design.gif?raw=true" alt="WhatsApp-Design" />
      </td>
    </tr>
  </tbody>
</table>
<table>
  <thead>
    <tr>
      <th align="center">Ai-Commands</th>
      <th align="center">Ai-Remove-Background</th>
      <th align="center">Ai-Replace-Background</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center" width="33.3%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/preview/ai-command.gif?raw=true" alt="Ai-Commands" />
      </td>
      <td align="center" width="33.3%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/preview/ai-remove-background.gif?raw=true" alt="Ai-Remove-Background" />
      </td>
      <td align="center" width="33.3%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/preview/ai-replace-background.gif?raw=true" alt="Ai-Replace-Background" />
      </td>
    </tr>
  </tbody>
</table>
<table>
  <thead>
    <tr>
      <th align="center">Paint-Editor</th>
      <th align="center">Text-Editor</th>
      <th align="center">Crop-Rotate-Editor</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center" width="33.3%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/preview/paint-editor.gif?raw=true" alt="Paint-Editor" />
      </td>
      <td align="center" width="33.3%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/preview/text-editor.gif?raw=true" alt="Text-Editor" />
      </td>
      <td align="center" width="33.3%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/preview/crop-rotate-editor.gif?raw=true" alt="Crop-Rotate-Editor" />
      </td>
    </tr>
  </tbody>
</table>
<table>
  <thead>
    <tr>
      <th align="center">Filter-Editor</th>
      <th align="center">Emoji-Editor</th>
      <th align="center">Sticker/ Widget Editor</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center" width="33.3%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/preview/filter-editor.gif?raw=true" alt="Filter-Editor" />
      </td>
      <td align="center" width="33.3%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/preview/emoji-editor.gif?raw=true" alt="Emoji-Editor" />
      </td>
      <td align="center" width="33.3%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/preview/sticker-editor.gif?raw=true" alt="Sticker-Widget-Editor" />
      </td>
    </tr>
  </tbody>
</table>


## Features
 
### 🧩 Editor Modules

- 🎨 **Paint Editor**: Draw freehand with various brushes, shapes (like circles and arrows), and apply blur or pixelation for censoring.
- 🅰️ **Text Editor**: Add and style text with full customization.  
- ✂️ **Crop & Rotate Editor**: Crop, flip, and rotate images with ease.  
- 🎛️ **Tune Adjustments**: Adjust brightness, contrast, saturation, and more.  
- 📸 **Filter Editor**: Apply custom or predefined image filters.  
- 💧 **Blur Editor**: Add blur to any part of the image.  
- 😀 **Emoji Picker**: Quickly insert emojis into your design.  
- 🖼️ **Sticker Editor**: Add and manage custom image stickers.  


### 🚀 Performance & Architecture

- 🧵 **Multi-Threading**  
  - Use isolates for background tasks on native platforms.  
  - Use web workers for background tasks in web environments.  
  - Auto- or manually configure the number of active background processors based on device capabilities.  

### 🛠️ Core Features

- 🖼️ **Flexible Image Input**: Load images from memory, assets, files, or network.  
- 🌍 **i18n Support**: Translate every string in the UI.  
- 🎚️ **Per-Editor Configuration**: Each module offers extensive customization options.  
- 🧱 **Fully Customizable**: Swap icons, styles, and widgets for any subeditor.  
- 📐 **Helper Lines**: Snap and align objects more accurately.  
- ↩️ **Undo/Redo** support for non-destructive editing.  
- 🔁 **Movable Background Image**: Position the base image as needed.  
- 🔀 **Reorder Layers**: Change layer stacking order dynamically.  
- 🎯 **Interactive Layers**: Select and manipulate each element with precision.  
- 🖌️ **Hit Detection**: Paint layers support interactive selection.  
- 🔍 **Zoom Support**: Zoom in/out in both paint and main editor views.  
- 🖱️ **Enhanced Desktop UX**: Fine-tuned movement and scaling on desktop platforms.  
- 🧲 **Multiselect Support**: Select multiple elements at once.  

### 🎨 Themes

- 🪵 **Grounded Theme**  
- 🧊 **Frosted Glass Theme**  
- 💬 **WhatsApp Theme** 

### 🔗 Integration

- 🤖 **AI Assistant**: Integrate ChatGPT, Gemini, or other AI models to assist with image editing via smart suggestions or direct commands.
- 🎥 **Video Editor**: Seamlessly combine image and video editing workflows.



## Setup

#### Web

<details>
  <summary>Show web setup</summary>

If you're displaying emoji on the web and want them to be colored by default (especially if you're not using a custom font like Noto Emoji), you can achieve this by adding the `useColorEmoji: true` parameter to your `flutter_bootstrap.js` file, as shown in the code snippet below:

```js
{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
    serviceWorkerSettings: {
        serviceWorkerVersion: {{flutter_service_worker_version}},
    },
    onEntrypointLoaded: function (engineInitializer) {
      engineInitializer.initializeEngine({
        useColorEmoji: true, // add this parameter
        renderer: 'canvaskit'
      }).then(function (appRunner) {
        appRunner.runApp();
      });
    }
});
```
<br/>

You can view the full web example [here](https://github.com/hm21/pro_image_editor/tree/stable/example/web).

</details>

#### Android, iOS, macOS, Linux, Windows

No additional setup required.

#### Apps that still use `package:flutter/material.dart`

Since v14 the editor is built on [`material_ui`](https://pub.dev/packages/material_ui) and [`cupertino_ui`](https://pub.dev/packages/cupertino_ui), which Flutter is decoupling from the SDK. If your app has not migrated its own `MaterialApp` yet, hand it the localizations of those packages, otherwise the editor's app bars, dialogs and bottom sheets throw `No MaterialLocalizations found`:

```dart
import 'package:material_ui/material_ui.dart' as material_ui;

MaterialApp(
  localizationsDelegates: [
    ...material_ui.GlobalMaterialLocalizations.delegates,
    // Your existing delegates, e.g. the ones from flutter_localizations.
  ],
  // ...
);
```


<br/>


## Usage

```dart
import 'package:pro_image_editor/pro_image_editor.dart';

@override
Widget build(BuildContext context) {
  return ProImageEditor.network(
    'https://picsum.photos/id/237/2000',
    callbacks: ProImageEditorCallbacks(
      onImageEditingComplete: (Uint8List bytes) async {
        /*
          Your code to process the edited image, such as uploading it to your server.

          You can choose to use await to keep the loading dialog visible until 
          your code completes, or run it without async to close the loading dialog immediately.

          By default, the image bytes are in JPG format.
        */
        Navigator.pop(context);
      },
        /* 
        Optional: If you want haptic feedback when a line is hit, similar to WhatsApp, 
        you can use the code below along with the vibration package.

          mainEditorCallbacks: MainEditorCallbacks(
            helperLines: HelperLinesCallbacks(
              onLineHit: () {
                Vibration.vibrate(duration: 3);
              }
            ),
          ),
        */
    ),
  );
}
```

#### Designs

The editor offers three prebuilt designs:
- [Grounded](https://github.com/hm21/pro_image_editor/blob/stable/example/lib/features/design_examples/grounded_example.dart)
- [Frosted-Glass](https://github.com/hm21/pro_image_editor/blob/stable/example/lib/features/design_examples/frosted_glass_example.dart)
- [WhatsApp](https://github.com/hm21/pro_image_editor/blob/stable/example/lib/features/design_examples/whatsapp_example.dart)

#### Extended-Configurations

The editor provides extensive customization options, allowing you to modify text, icons, colors, and widgets to fit your needs. It also includes numerous callbacks for full control over its functionality.

Check out the web [demo](https://hm21.github.io/pro_image_editor/) to explore all possibilities. You can find the example code for all demos [here](https://github.com/hm21/pro_image_editor/tree/stable/example/lib/features).


## Video-Editor

The editor supports full video generation on Android, iOS, and macOS. Support for Windows and Linux is coming soon.

To keep the image editor lightweight, you’ll need to manually add the video player package of your choice. For rendering the video, you can use my package [pro_video_editor](https://pub.dev/packages/pro_video_editor), which is also used in the example.

An example of how to implement the video editor with a specific video player can be found [here](https://github.com/hm21/pro_image_editor/tree/stable/example/lib/features/video_examples), and a simpler example using just the default [video_player](https://pub.dev/packages/video_player) is available [here](https://github.com/hm21/pro_video_editor/blob/stable/example/lib/features/editor/pages/video_editor_basic_example_page.dart).





## Sponsors 
<p align="center">
  <a href="https://github.com/sponsors/hm21">
    <img src='https://raw.githubusercontent.com/hm21/sponsors/main/sponsorkit/sponsors.svg'/>
  </a>
</p>


## Included Packages

A big thanks to the authors of these amazing packages.

- Packages created by the Dart team:
  - [http](https://pub.dev/packages/http)
  - [plugin_platform_interface](https://pub.dev/packages/plugin_platform_interface)
  - [vector_math](https://pub.dev/packages/vector_math)
  - [web](https://pub.dev/packages/web)


- Packages that are used with a minor modified version, but are not a direct dependency:
  - [archive](https://pub.dev/packages/archive)
  - [defer_pointer](https://pub.dev/packages/defer_pointer)
  - [emoji_picker_flutter](https://pub.dev/packages/emoji_picker_flutter)
  - [image](https://pub.dev/packages/image)
  - [mime](https://pub.dev/packages/mime)

## Contributors
<a href="https://github.com/hm21/pro_image_editor/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=hm21/pro_image_editor" />
</a>

Made with [contrib.rocks](https://contrib.rocks).