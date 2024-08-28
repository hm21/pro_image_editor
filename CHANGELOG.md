# Changelog

## 5.2.2
- **FIX**(Frosted-Glass): Resolve issue that loading-dialog didn't use the text from the i18n class.

## 5.2.1
- **REFACTOR**(vars): remove deprecated variables

## 5.2.0
- **BREAKING** **FEAT**(Callback): Added the `ImageInfos` parameter to the `onDone` callback in the crop-rotate-editor.
- **FEAT**(Config): Add `copyWith` method to all config classes.
- **DOCS**(Example): Add an example how to start with the crop-rotate-editor and move than to the main-editor.
- **CHORE**(Dependency): Update `emoji_picker_flutter` dependency to version `3.0.0`.
- **CHORE**(Dependency): Update `vibration` dependency to version `2.0.0`.
- **CHORE**(Dependency): Update `mime` dependency to version `1.0.6`.

## 5.1.4
- **FIX**(Crop-Editor): Ensure the editor respect the maximum output size.


## 5.1.3
- **FIX**(Crop-Editor): Occasionally, image generation may fail due to issues related to internal Flutter widget builds. In such cases, we immediately retry the generation to ensure the final image is produced. 
Note that this issue primarily occurs in debug mode and it was very rare in release mode.


## 5.1.2
- **FIX**(Crop-Editor): Ensure custom aspect ratio is applied when no changes are made.


## 5.1.1
- **FIX**(Frosted-Glass-Design): Ensure configuration options such as `canReset` function correctly.
- **DOCS**(Contributors): Include contributor avatars in the README file.


## 5.1.0
- **FEAT**(Layer Management): Added method `replaceLayer` to enable replacing an existing layer at a specified index, enhancing layer management and history tracking capabilities.
- **FEAT**(Sticker Interaction): Added callback `onTapEditSticker` to display an edit button on stickers when tapped, allowing for customizable sticker editing interactions. This was requested in [#188](https://github.com/hm21/pro_image_editor/issues/188).


## 5.0.3
- **REFACTOR**(config): Rename 'editorIsZoomable' to 'enableZoom'
- **FIX**(config): Correct typo `initinalTransformConfigs` to 'initialTransformConfigs'
- **STYLE**(spelling): Correct spelling errors in code comments and documentation


## 5.0.2

- **STYLE**(lint): Add extensive lint tests across multiple components to enhance code quality


## 5.0.1

- **FIX**(loading-dialog): The loading dialog will now close correctly regardless of the animation builder's state, preventing potential UI freezes or blocks.


## 5.0.0

> **Breaking Changes** 
The package now supports Flutter `3.24`, which changes the `onPopInvoked` method.
Introduced a new loading dialog as a singleton class.

- **FEAT**(loading-dialog): Replaced the existing loading dialog with a new solution which use `Overlay` instead of `Navigator.push`. This provides more control over the dialog's hide process and prevents it from affecting other widgets.
- **REFACTOR**(editor): Renamed `transformConfigs` to `initTransformConfigs`.
- **FIX**(flutter-version): Updated deprecated code for Flutter 3.24 compatibility.
- **CHORE**: Removed the `awaitLoadingDialogContext` configuration as it is no longer required.

## 4.3.6

- **FEAT**(text-editor): Enable access to FocusNode and TextControl for enhanced editor control.

## 4.3.5

- **FIX**(frosted-glass): Adjust frosted glass example icon button size.
- **FEAT**(filter-button): Updated the text color of the selected filter to visually indicate which filter is currently active, enhancing user interaction and clarity.


## 4.3.4

- **FIX**(loading-dialog): close loading dialog after generation process completes.


## 4.3.3

- **FIX**(layout): Resolve right overflow issue on small size phones in the paint-editor. This was merged from the pull request [#178](https://github.com/hm21/pro_image_editor/pull/178).


## 4.3.2

- **FIX**(paint-validator): Resolve right overflow issue. This resolves the issue [#177](https://github.com/hm21/pro_image_editor/issues/177).


## 4.3.1

- **FEAT**(crop-rotate-editor): Allow users to read and update the aspect ratio using custom methods. This was requested in [#169](https://github.com/hm21/pro_image_editor/issues/169).


## 4.3.0

- **FEAT**(draw-opacity): Add an option to let the user change the opacity of the drawing. This was discussed in [#167](https://github.com/hm21/pro_image_editor/discussions/167).


## 4.2.9

- **FIX**(done-button): Disable 'Done' button until image is decoded. This resolves the issue [#166](https://github.com/hm21/pro_image_editor/issues/166).


## 4.2.8

- **FIX**(dialog-mode): Resolve issue where the subEditorPage had the wrong size in the dialog. This resolves the issue [#164](https://github.com/hm21/pro_image_editor/issues/164).


## 4.2.7

- **FIX**(text-editor): Resolve issue where cursor size change with long text. This resolves issue [#154](https://github.com/hm21/pro_image_editor/issues/154).


## 4.2.6

- **FIX**(content-recorder): Remove visible border in captured images when user added layers from outside. This resolves issue [#156](https://github.com/hm21/pro_image_editor/issues/156).


## 4.2.5

- **FIX**(zoom-paint-editor): Prevent bottombar from wrapping items to a new line. This resolves issue [#152](https://github.com/hm21/pro_image_editor/issues/152).


## 4.2.4

- **FIX**(import): Ensure to set correct emoji size after image rotation and history restore. This resolves issue [#151](https://github.com/hm21/pro_image_editor/issues/151).


## 4.2.3

- **FIX**(content-recorder): Ensure final generated image respects bounds after rotation when `captureOnlyBackgroundImageArea` is `true`. This resolves issue [#145](https://github.com/hm21/pro_image_editor/issue/145).


## 4.2.2

- **FIX**(PopScope): Check if route already popped in `onPopInvoked` and avoid showing close warning dialog if already popped.
- **FEAT**(Callbacks): Added new callback to `MainEditorCallbacks` which is triggered when `onPopInvoked`.


## 4.2.1

- **FEAT**(theme): Added option to change foreground and background color of layer interaction buttons.


## 4.2.0

- **FEAT**(ContentRecorderController): Changed the logic how the `ContentRecorderController` records invisible widgets. This makes the image editor backward compatible to older Flutter versions <= `3.19.x`.


## 4.1.1

- **FIX**(vibration):  The `Vibration.hasVibrator` check will now only happen if the user has enabled hitVibration in the helper-line configs. This resolves issue [#139](https://github.com/hm21/pro_image_editor/issue/139).


## 4.1.0

- **FEAT**(zoom): Paint-Editor and Main-Editor has now option for zooming. An example of how to enable this can be found [here](https://github.com/hm21/pro_image_editor/blob/stable/example/lib/pages/zoom_move_editor_example.dart)


## 4.0.10

- **FEAT**(text-editor): Add autocorrect and enableSuggestions configs. This was requested in [#132](https://github.com/hm21/pro_image_editor/issues/132)
- **FIX**(text-editor): Remove duplicate text-shadow from invisible text-field. This resolves issue [#131](https://github.com/hm21/pro_image_editor/issue/131).


## 4.0.9

- **FIX**(emoji-picker): Ensure the emoji-picker is rendered inside the safe areas. This resolves issue [#126](https://github.com/hm21/pro_image_editor/issue/126).


## 4.0.8

- **FIX**(crop-rotate-editor): Resolve incorrect transformation issue in crop editor.
- **FIX**(export-import): Correct image transformation on history reapply. This resolves issue [#120](https://github.com/hm21/pro_image_editor/discussions/120).
- **FIX**(export-import): Resolve sticker persistence and transformation issues in history reapply. This resolves issue [#121](https://github.com/hm21/pro_image_editor/discussions/121).


## 4.0.7

- **FIX**(sticker-export): Resolve incorrect export from sticker images causing lower resolution.
- **FEAT**(custom-widget): Add custom widgets for font-size bottom sheet. This was requested in [#123](https://github.com/hm21/pro_image_editor/issues/123)


## 4.0.6

- **FEAT**(layer-scale): Add ability to set minimum and maximum scale factor for layers. This was requested in [#122](https://github.com/hm21/pro_image_editor/issues/122)


## 4.0.5

- **FIX**(text-editor): Resolve misapplication of secondary color. This resolve issue [#105](https://github.com/hm21/pro_image_editor/discussions/105).
- **FIX**(text-editor): Resolve issue where text styles (bold/italic/underline) are not saved in history. This resolves issue [#118](https://github.com/hm21/pro_image_editor/discussions/118).



## 4.0.4

- **FEAT**(text-editor): Added the ability to programmatically set the secondary color next to the primary color.


## 4.0.3

- **FEAT**(decode-image): Ability to decode the image from external, allowing to change the background image dynamically, which was requested in [#110](https://github.com/hm21/pro_image_editor/discussions/110). 
- **FIX**(layer-position): Ensure layers are rendered from center even without bottombar. This resolves issue [#113](https://github.com/hm21/pro_image_editor/issue/113). 


## 4.0.2

- **REFACTOR**(designs): Made the "Frosted-Glass" and "WhatsApp" designs more compact, making them easier to implement with less code.


## 4.0.1

- **FIX**(import-history): Resolve incorrect multiple importing from state history. This resolve issue [#106](https://github.com/hm21/pro_image_editor/discussions/106).


## 4.0.0

> Detailed information about this release and why these breaking-changes are necessary can be found [here](https://github.com/hm21/pro_image_editor/discussions/109).

- **BREAKING** **FEAT**: Remove hardcoded `WhatsApp-Design`.
- **BREAKING** **FEAT**: Rewrite the entire logic of `customWidgets`.
- **BREAKING** **FEAT**: Move `initialColor` and `initialStrokeWidth` from `paintEditorConfigs` to `imageEditorTheme-paintingEditor`.

- **FEAT**: Add new design `Frosted-Glass`.
- **FEAT**: The `WhatsApp` theme is now fully editable.
- **FEAT**: Smaller build size and minimal performance boost because the Whatsapp design is no longer hardcoded.
- **FEAT**: Make it easier to use `customWidget`.
- **FEAT**: Editor design is now more customizable.


## 3.0.15

- **FEAT**(callbacks): Add to the main-editor callbacks `onTap`, `onDoubleTap` and `onLongPress` which was requested in [#104](https://github.com/hm21/pro_image_editor/issues/104).


## 3.0.14

- **FEAT**(custom-widget): Add custom widgets to the line-width bottomsheet in the Paint Editor, which was requested in [#103](https://github.com/hm21/pro_image_editor/discussions/103).
- **FIX**(sticker-export-import) Fix the issue that the sticker size change after export/import them. This resolve issue [#83](https://github.com/hm21/pro_image_editor/discussions/83).


## 3.0.13

- **FIX**(state-history): Resolve incorrect import/export from transform-configs. This resolve issue [#102](https://github.com/hm21/pro_image_editor/discussions/102).


## 3.0.12

- **FIX**(import-history): Resolve incorrect import of fontfamily and font-scale. This issue was discussed in [#83](https://github.com/hm21/pro_image_editor/discussions/83).


## 3.0.11

- **FEAT**(remove-all-layers): Add method to remove all layers as requested in [#80](https://github.com/hm21/pro_image_editor/issues/80).


## 3.0.10

- **FEAT**(hover-remove-btn): Extend the remove area so that it always detects the layer hovering correctly, even if the user creates a custom widget with a different position for it.


## 3.0.9

- **FIX**(hover-remove-btn): Ensure remove area works correctly on iOS rotated devices. This fix [GitHub issue #75](https://github.com/hm21/pro_image_editor/issues/75).


## 3.0.8

- **FEAT**(custom-color-picker): Add currently selected color to custom color picker widget.


## 3.0.7

#### **BREAKING-CHANGES**:
- **BREAKING** **FEAT**: The property `generateOnlyDrawingBounds` has been renamed to `captureOnlyDrawingBounds`.

- **FEAT**: The editor will now capture by default only the area from the background image and cut all layers outside. To disable this behavior, you can set the flag `captureOnlyBackgroundImageArea` to `false` in the configurations, like below:
```dart
configs: ProImageEditorConfigs(
  imageGenerationConfigs: const imageGenerationConfigs(
    captureOnlyBackgroundImageArea: false,
  ),
),
```
- **FEAT**: Visually overlay the background color with opacity over layers outside the capture area.
- **FEAT**: New mode in the paint-editor to erase painted layers.



## 3.0.6

- **FIX**(layer): call setState when adding a new layer from external source
- **FIX**(web_worker): remove web_worker.dart from web build to resolve lint errors


## 3.0.5

- **FEAT**(custom-slider): add a custom widget to replace the slider in the filter and blur editor.
- **FEAT**(custom-color-picker): add a custom widget to replace the color picker in the text and paint editor.
- **FEAT**(custom-crop-aspect-ratio): add a custom widget to replace the aspect ratio picker.
- **FIX**(main-editor): correct image and layer display when bottombar or appbar is not visible.


## 3.0.4

- **FEAT**(hero): enable hero animation when opening the editor


## 3.0.3

- **FIX**(done-editing): allow users to continue editing after pressing done if the image-editor doesn't close


## 3.0.2

- **CHORE**(example): also release example in pub.dev for pub-points


## 3.0.1

- **DOCS**(preview-videos): update preview videos to version 3.0.0


## 3.0.0 New Crop-Rotate-Editor

> Replace the existing crop-rotate editor, which depended on the `extended_image` and `image_editor` package, with a new solution that doesn't depend on this packages.


- **BREAKING** **FEAT**: Move `onImageEditingComplete`, `onCloseEditor` and `onUpdateUI` callbacks inside `callbacks: ProImageEditorCallbacks()`.
- **BREAKING** **FEAT**: Change the `allowCompleteWithEmptyEditing` config to `allowEmptyEditCompletion`. Use it new like this `configs: ProImageEditorConfigs(imageGenerationConfigs: imageGenerationConfigs(allowEmptyEditCompletion: false))`. The default value is now also `true` and not `false` anymore.
- **BREAKING** **FEAT**: Change the layer initial offset position to the center of the screen, not the top left.
- **BREAKING** **FEAT**: Rename `ColorFilterGenerator` to `FilterModel`.
- **BREAKING** **FEAT**: Changed the logic of overlaying multiple layers, which may produce different results than before.
- **BREAKING** **FEAT**: Default `maxBlur` configuration is now 5.0 instead of 2.0.
- **BREAKING** **FEAT**: Move `editorBoxConstraintsBuilder` from `configs` to `imageEditorTheme`.

- **FEAT**: Crop-Rotate-Editor
  - Double tap to zoom in and out
  - Multiple cursor support
  - Undo/Redo function
  - Reset function
  - Flip function
  - Animated rotation
  - Keyboard shortcut support
  - More theme and configuration options
  - Hero animation for image and layers
  - Round "cropper" for profile pictures
- **FEAT**: Painting-Editor
  - Standalone drawing of signatures or paintings
- **FEAT**: Emoji-Editor
  - Infinite scrolling through all categories
  - Optional as `DraggableScrollableSheet` 
- **FEAT**: Sticker-Editor
  - Optional as `DraggableScrollableSheet` 
- **FEAT**: Standalone editors "Painting, Crop-Rotate, Filter, Blur"
- **FEAT**: Option to generate thumbnails first and the final image later for faster results with high-resolution images
- **FEAT**: Generate configs to change things like the output format 

- **FIX**: Layer rendering outside the background image now works everywhere.
- **FIX**: The editor no longer depends on packages that only work with supported "native" functionality, which ensures that the editor works on all platforms. This fixes issue #23.

- **PERF**: Changes are handled internally across all editors, so there's no conversion delay when opening or closing the Crop-Rotate Editor.
- **PERF**: Image generation is now isolated from the main thread, speeding up the process significantly. On the web, it runs inside separate web workers.
- **PERF**: Filters recalculate matrix only when they change and not after every state refresh.
- **PERF**: Faster emoji rendering when scrolling in the Emoji Editor.

<br/>


## 2.7.11

- **MERGE**: pull request [#60](https://github.com/hm21/pro_image_editor/issues/60) from diegotori/editor_bottom_sheet_constraints. 
    - BoxConstraints support when opening editors in bottom sheets.


## 2.7.10

- **FIX**: resolve loading-dialog issue with Asuka package closes [GitHub issue #48](https://github.com/hm21/pro_image_editor/issues/48).


## 2.7.9

- **CHORE**: Update the `screenshot` package so that it's compatible with Flutter 3.22.0. This fix [GitHub issue #45](https://github.com/hm21/pro_image_editor/issues/45).


## 2.7.8

- **FEAT**: Added option for layers to be selected upon creation. Details in [GitHub issue #44](https://github.com/hm21/pro_image_editor/issues/44).


## 2.7.7

- **FIX**: Deselect all layers when finished editing, resolving [GitHub issue #42](https://github.com/hm21/pro_image_editor/issues/42).


## 2.7.6

- **FEAT**: Allow users to create a custom bottomBar for the text editor. Details in [GitHub issue #40](https://github.com/hm21/pro_image_editor/issues/40)


## 2.7.5

- **FIX**: Corrected pixelRatio and layer interaction calculations in ProImageEditor for smaller screen areas, ensuring accuracy across various device sizes. See [GitHub issue #37](https://github.com/hm21/pro_image_editor/issues/37).


## 2.7.4

- **FIX**: Migrated all emoji editor theme configurations from `EmojiEditorConfigs` to `EmojiEditorTheme` inside `ImageEditorTheme`, resolving [GitHub issue #38](https://github.com/hm21/pro_image_editor/issues/38).


## 2.7.3

- **FIX**: Correct platform conditional to include web check. Details in [GitHub issue #35](https://github.com/hm21/pro_image_editor/issues/35)


## 2.7.2

- **FEAT**: Added a function in `customWidgets` within `configs` to show a custom `closeWarningDialog`.


## 2.7.1

- **FEAT**: Introduces the ability for users to specify the initial offset position for new layers.


## 2.7.0

- **FEAT**: Layers can now be selected for rotation, scaling, and deletion, enhancing user control and editing capabilities.
- **FEAT**: Improved functionality particularly on desktop devices, where users can now manipulate layers more efficiently.
- **FEAT**: Introduced keyboard shortcuts: **Ctrl+Z**: for undo and **Ctrl+Shift+Z**: for redo actions, streamlining workflow and enhancing user experience.
- **FIX**: Fixed an issue where rotated layers with unequal width and height couldn't be tapped in the corners, ensuring consistent interaction regardless of rotation.


## 2.6.8

- **FEAT**: Renamed the property `whatsAppCustomTextStyles` to `customTextStyles` in the `TextEditorConfigs`. This change allows users to set multiple fonts also in the simple editor.
- **FEAT**: Prepare some code for a new layer interaction feature that allows users to select a layer and then rotate or scale them.


## 2.6.7

- **FIX**: correct layer interaction to handle multiple layers
- **REFACTOR**: improve code readability for better maintainability


## 2.6.6

- **REFACTOR**: Update editor code examples


## 2.6.5

- **FEAT**: Make `stateHistory` and `activeLayers` public and add `moveLayerListPosition` method to improve layer management functionality.


## 2.6.4

- **FIX**(iOS)**: resolve editor error on iOS devices with cupertino design when editing completion


## 2.6.3

- **FEAT**: Add preview screen to sample application for displaying edited images
- **CHORE**: Update emoji_picker_flutter dependency to version 2.2.0


## 2.6.2

- **FEAT**: Add a custom widget option to the Whatsapp design. This allows user to create same as in whatsapp, a text field with a send button or any other widget they want.


## 2.6.1

- **DOCS**: Update README for better image viewing


## 2.6.0

- **FEAT**: Added prebuilt design option inspired by WhatsApp design. Now the image editor includes a prebuilt design that closely resembles the visual style of WhatsApp, offering users a familiar and intuitive editing experience.


## 2.5.8

- **CHORE**: Dependency updates


## 2.5.7

- **BREAKING** **FEAT**: Changed the way aspect ratios and the initial value are set.
- **BREAKING** **FEAT**: I18n for crop aspect ratios must now be set in the crop-rotate editor configs.


## 2.5.6

- **FEAT**: Allow users to set only the required crop aspect ratios. Details in [GitHub issue #20](https://github.com/hm21/pro_image_editor/issues/20)


## 2.5.5

- **FIX**: Fix flutter analyze tests and format code.


## 2.5.4

- **FEAT**: Add the `strokeWidthOnChanged` callback. Details in [GitHub pull #19](https://github.com/hm21/pro_image_editor/pull/19)


## 2.5.3

- **FEAT**: Customize dialog colors in Cupertino design. Details in [GitHub pull #18](https://github.com/hm21/pro_image_editor/pull/18)


## 2.5.2

- **FIX**: The `allowCompleteWithEmptyEditing` logic was dropped by the committing. Details in [GitHub pull #17](https://github.com/hm21/pro_image_editor/pull/17)


## 2.5.1

- **FEAT**: Set theme for alert dialog. Details in [GitHub pull #16](https://github.com/hm21/pro_image_editor/pull/16)


## 2.5.0

- **FEAT**: New editor `Blur-Editor`. Details in [GitHub pull #15](https://github.com/hm21/pro_image_editor/pull/15)


## 2.4.6

- **FEAT**: Add `Change Font Scale` feature to text editor. Details in [GitHub pull #14](https://github.com/hm21/pro_image_editor/pull/14)


## 2.4.5

- **FEAT**: Add parameter `allowCompleteWithEmptyEditing`. Details in [GitHub pull #11](https://github.com/hm21/pro_image_editor/pull/11)


## 2.4.4

- **FIX**: Hotfix for transparent images that are not displaying correctly after crop/rotate. Details in [GitHub issue #10](https://github.com/hm21/pro_image_editor/issues/10)


## 2.4.3

- **REFACTOR**: Upgrade Flutter to latest version and fix new analyze issues.


## 2.4.2

- **FEAT**: Add landscape mode for device orientation, details in [GitHub issue #7](https://github.com/hm21/pro_image_editor/issues/7)


## 2.4.1

- **FIX**: Hotfix to close the editor with custom parameters, details in [GitHub issue #6](https://github.com/hm21/pro_image_editor/issues/6)


## 2.4.0

- **BREAKING** **CHORE**: Updated `emoji_picker_flutter` dependency to version 2.0.0. This version introduces significant enhancements, including:
  - Improved configuration options for better customization.
  - Addition of a new search function for easier emoji discovery.
  - Expanded design options for enhanced visual appearance.


## 2.3.2

- **STYLE**: Enclose if statement in block in pro_image_editor_main.dart


## 2.3.1

- **FIX**: fix overflow bug in BottomAppBar, details in [GitHub issue #5](https://github.com/hm21/pro_image_editor/issues/5)


## 2.3.0

- **FEAT**: Enhance state history management


## 2.2.3

- **FEAT**: Improved the fly animation within the Hero widget to provide a smoother and more visually appealing experience.


## 2.2.2

- **FIX**: example bug for `emojiSet`, details in [GitHub issue #2](https://github.com/hm21/pro_image_editor/issues/2)


## 2.2.1

- **FIX**: close warning bug, details in [GitHub issue #1](https://github.com/hm21/pro_image_editor/issues/1)


## 2.2.0

- **FEAT**: Added functionality to extend the bottomAppBar with custom widgets, providing users with more flexibility in customizing the bottom bar.


## 2.1.1

- **STYLE**: Improved Dart code formatting


## 2.1.0

- **FEAT**: Added functionality to extend the appbar with custom widgets, providing users with more flexibility in customizing the app's header.


## 2.0.0

- **FEAT**: Introducing the "Sticker" editor for seamless loading of stickers and widgets directly into the editor.


## 1.0.3

- **DOCS**: Update README.md with improved preview image


## 1.0.2

- **FEAT**: Improved accessibility: `ProImageEditorConfigs` is now directly exported for easier integration and usage.


## 1.0.1

- **DOCS**: Updated images in README.md for enhanced clarity
- **DOCS**: Added documentation to adaptive_dialog.dart for better code understanding
- **STYLE**: Formatted Dart code across various modules for improved consistency


## 1.0.0

- **FEAT**: PaintingEditor
- **FEAT**: TextEditor
- **FEAT**: CropRotateEditor
- **FEAT**: FilterEditor
- **FEAT**: EmojiEditor