# Changelog

## Version 4.1.0
- **feat(zoom)**: Paint-Editor and Main-Editor are now zoomable. An example of how to enable this can be found [here](https://github.com/hm21/pro_image_editor/blob/74982d6c8e3e3d2d16e8f77821f9bcd839863c23/example/lib/pages/zoom_move_editor_example.dart)

## Version 4.0.10
- **feat(text-editor)**: Add autocorrect and enableSuggestions configs. This was requsted in [#132](https://github.com/hm21/pro_image_editor/issues/132)
- **fix(text-editor)**: Remove duplicate text-shadow from invisible text-field. This resolves issue [#131](https://github.com/hm21/pro_image_editor/issue/131).

## Version 4.0.9
- **fix(emoji-picker)**: Ensure the emoji-picker is rendered inside the safe areas. This resolves issue [#126](https://github.com/hm21/pro_image_editor/issue/126).

## Version 4.0.8
- **fix(crop-rotate-editor)**: Resolve incorrect transformation issue in crop editor.
- **fix(export-import)**: Correct image transformation on history reapply. This resolves issue [#120](https://github.com/hm21/pro_image_editor/discussions/120).
- **fix(export-import)**: Resolve sticker persistence and transformation issues in history reapply. This resolves issue [#121](https://github.com/hm21/pro_image_editor/discussions/121).

## Version 4.0.7
- **fix(sticker-export)**: Resolve incorrect export from sticker images causing lower resolution.
- **feat(custom-widget)**: Add custom widgets for font-size bottom sheet. This was requsted in [#123](https://github.com/hm21/pro_image_editor/issues/123)

## Version 4.0.6
- **feat(layer-scale)**: Add ability to set minimum and maximum scale factor for layers. This was requsted in [#122](https://github.com/hm21/pro_image_editor/issues/122)

## Version 4.0.5
- **fix(text-editor)**: Resolve misapplication of secondary color. This resolve issue [#105](https://github.com/hm21/pro_image_editor/discussions/105).
- **fix(text-editor)**: Resolve issue where text styles (bold/italic/underline) are not saved in history. This resolves issue [#118](https://github.com/hm21/pro_image_editor/discussions/118).


## Version 4.0.4
- **feat(text-editor)**: Added the ability to programmatically set the secondary color next to the primary color.

## Version 4.0.3
- **feat(decode-image)**: Ability to decode the image from external, allowing to change the background image dynamically, which was requested in [#110](https://github.com/hm21/pro_image_editor/discussions/110). 
- **fix(layer-position)**: Ensure layers are rendered from center even without bottombar. This resolves issue [#113](https://github.com/hm21/pro_image_editor/issue/113). 

## Version 4.0.2
- **refactor(designs)**: Made the "Frosted-Glass" and "WhatsApp" designs more compact, making them easier to implement with less code.

## Version 4.0.1
- **fix(import-history)**: Resolve incorrect multiple importing from state history. This resolve issue [#106](https://github.com/hm21/pro_image_editor/discussions/106).

## Version 4.0.0
Detailed information about this release and why these breaking-changes are necessary can be found [here](https://github.com/hm21/pro_image_editor/discussions/109).

#### **Breaking Changes:**
- Remove hardcoded `WhatsApp-Design`.
- Rewrite the entire logic of `customWidgets`.
- Move `initialColor` and `initialStrokeWidth` from `paintEditorConfigs` to `imageEditorTheme-paintingEditor`.

#### **feat:**
- Add new design `Frosted-Glass`.
- The `WhatsApp` theme is now fully editable.
- Smaller build size and minimal performance boost because the Whatsapp design is no longer hardcoded.
- Make it easier to use `customWidget`.
- Editor design is now more customizable.

## Version 3.0.15
- **feat(callbacks)**: Add to the main-editor callbacks `onTap`, `onDoubleTap` and `onLongPress` which was requested in [#104](https://github.com/hm21/pro_image_editor/issues/104).

## Version 3.0.14
- **feat(custom-widget)**: Add custom widgets to the line-width bottomsheet in the Paint Editor, which was requested in [#103](https://github.com/hm21/pro_image_editor/discussions/103).
- **fix(sticker-export-import)** Fix the issue that the sticker size change after export/import them. This resolve issue [#83](https://github.com/hm21/pro_image_editor/discussions/83).

## Version 3.0.13
- **fix(state-history)**: Resolve incorrect import/export from transform-configs. This resolve issue [#102](https://github.com/hm21/pro_image_editor/discussions/102).

## Version 3.0.12
- **fix(import-history)**: Resolve incorrect import of fontfamily and fontscale. This issue was discussed in [#83](https://github.com/hm21/pro_image_editor/discussions/83).

## Version 3.0.11
- **feat(remove-all-layers)**: Add method to remove all layers as requested in [#80](https://github.com/hm21/pro_image_editor/issues/80).

## Version 3.0.10
- **feat(hover-remove-btn)**: Extend the remove area so that it always detects the layer hovering correctly, even if the user creates a custom widget with a different position for it.

## Version 3.0.9
- **fix(hover-remove-btn)**: Ensure remove area works correctly on iOS rotated devices. This fix [GitHub issue #75](https://github.com/hm21/pro_image_editor/issues/75).

## Version 3.0.8
- **feat(custom-color-picker)**: Add currently selected color to custom color picker widget.

## Version 3.0.7
#### **Breaking Changes:**
- The property `generateOnlyDrawingBounds` has been renamed to `captureOnlyDrawingBounds`.

#### **feat:**
- The editor will now capture by default only the area from the background image and cut all layers outside. To disable this behavior, you can set the flag `captureOnlyBackgroundImageArea` to `false` in the configurations, like below:
```dart
configs: ProImageEditorConfigs(
  imageGenerationConfigs: const ImageGeneratioConfigs(
    captureOnlyBackgroundImageArea: false,
  ),
),
```
- Visually overlay the background color with opacity over layers outside the capture area.
- New mode in the paint-editor to erase painted layers.


## Version 3.0.6
- **fix(layer)**: call setState when adding a new layer from external source
- **fix(web_worker)**: remove web_worker.dart from web build to resolve lint errors

## Version 3.0.5
- **feat(custom-slider)**: add a custom widget to replace the slider in the filter and blur editor.
- **feat(custom-color-picker)**: add a custom widget to replace the color picker in the text and paint editor.
- **feat(custom-crop-aspect-ratio)**: add a custom widget to replace the aspect ratio picker.
- **fix(main-editor)**: correct image and layer display when bottombar or appbar is not visible.

## Version 3.0.4
- **feat(hero)**: enable hero animation when opening the editor

## Version 3.0.3
- **fix(done-editing)**: allow users to continue editing after pressing done if the image-editor doesn't close

## Version 3.0.2
- **chore(example)**: also release example in pub.dev for pubpoints

## Version 3.0.1
- **docs(preview-videos)**: update preview videos to version 3.0.0

## Version 3.0.0 New Crop-Rotate-Editor
Replace the existing crop-rotate editor, which depended on the `extended_image` and `image_editor` package, with a new solution that doesn't depend on this packages.


#### **Breaking Changes:**
- Move `onImageEditingComplete`, `onCloseEditor` and `onUpdateUI` callbacks inside `callbacks: ProImageEditorCallbacks()`.
- Change the `allowCompleteWithEmptyEditing` config to `allowEmptyEditCompletion`. Use it new like this `configs: ProImageEditorConfigs(imageGenerationConfigs: ImageGeneratioConfigs(allowEmptyEditCompletion: false))`. The default value is now also `true` and not `false` anymore.
- Change the layer initial offset position to the center of the screen, not the top left.
- Rename `ColorFilterGenerator` to `FilterModel`.
- Changed the logic of overlaying multiple layers, which may produce different results than before.
- Default `maxBlur` configuration is now 5.0 instead of 2.0.
- Move `editorBoxConstraintsBuilder` from `configs` to `imageEditorTheme`.

#### **feat:**
- Crop-Rotate-Editor
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
- Painting-Editor
  - Standalone drawing of signatures or paintings
- Emoji-Editor
  - Infinite scrolling through all categories
  - Optional as `DraggableScrollableSheet` 
- Sticker-Editor
  - Optional as `DraggableScrollableSheet` 
- Standalone editors "Painting, Crop-Rotate, Filter, Blur"
- Option to generate thumbnails first and the final image later for faster results with high-resolution images
- Generate configs to change things like the output format 
 

#### **fix:**
- Layer rendering outside the background image now works everywhere.
- The editor no longer depends on packages that only work with supported "native" functionality, which ensures that the editor works on all platforms. This fixes issue #23.

#### **perf:**
- Changes are handled internally across all editors, so there's no conversion delay when opening or closing the Crop-Rotate Editor.
- Image generation is now isolated from the main thread, speeding up the process significantly. On the web, it runs inside separate web workers.
- Filters recalculate matrix only when they change and not after every state refresh.
- Faster emoji rendering when scrolling in the Emoji Editor.

<br/>

## Version 2.7.11
- **merge**: pull request [#60](https://github.com/hm21/pro_image_editor/issues/60) from diegotori/editor_bottom_sheet_constraints. 
    - BoxConstraints support when opening editors in bottom sheets.

## Version 2.7.10
- **fix**: resolve loading-dialog issue with Asuka package closes [GitHub issue #48](https://github.com/hm21/pro_image_editor/issues/48).

## Version 2.7.9
- **chore**: Update the `screenshot` package so that it's compatible with Flutter 3.22.0. This fix [GitHub issue #45](https://github.com/hm21/pro_image_editor/issues/45).

## Version 2.7.8
- **feat**: Added option for layers to be selected upon creation. Details in [GitHub issue #44](https://github.com/hm21/pro_image_editor/issues/44).

## Version 2.7.7
- **fix**: Deselect all layers when finished editing, resolving [GitHub issue #42](https://github.com/hm21/pro_image_editor/issues/42).

## Version 2.7.6
- **feat:** Allow users to create a custom bottomBar for the text editor. Details in [GitHub issue #40](https://github.com/hm21/pro_image_editor/issues/40)

## Version 2.7.5
- **fix**: Corrected pixelRatio and layer interaction calculations in ProImageEditor for smaller screen areas, ensuring accuracy across various device sizes. See [GitHub issue #37](https://github.com/hm21/pro_image_editor/issues/37).

## Version 2.7.4
- **fix**: Migrated all emoji editor theme configurations from `EmojiEditorConfigs` to `EmojiEditorTheme` inside `ImageEditorTheme`, resolving [GitHub issue #38](https://github.com/hm21/pro_image_editor/issues/38).

## Version 2.7.3
- **fix**: Correct platform conditional to include web check. Details in [GitHub issue #35](https://github.com/hm21/pro_image_editor/issues/35)

## Version 2.7.2
- **feat**: Added a function in `customWidgets` within `configs` to show a custom `closeWarningDialog`.

## Version 2.7.1
- **feat**: Introduces the ability for users to specify the initial offset position for new layers.

## Version 2.7.0
- **feat**: Layers can now be selected for rotation, scaling, and deletion, enhancing user control and editing capabilities.
- **feat**: Improved functionality particularly on desktop devices, where users can now manipulate layers more efficiently.
- **feat**: Introduced keyboard shortcuts: **Ctrl+Z** for undo and **Ctrl+Shift+Z** for redo actions, streamlining workflow and enhancing user experience.
- **fix**: Fixed an issue where rotated layers with unequal width and height couldn't be tapped in the corners, ensuring consistent interaction regardless of rotation.

## Version 2.6.8
- **feat**: Renamed the property `whatsAppCustomTextStyles` to `customTextStyles` in the `TextEditorConfigs`. This change allows users to set multiple fonts also in the simple editor.
- **feat**: Prepare some code for a new layer interaction feature that allows users to select a layer and then rotate or scale them.

## Version 2.6.7
- **fix**: correct layer interaction to handle multiple layers
- **refactor**: improve code readability for better maintainability

## Version 2.6.6
- **refactor:** Update editor code examples

## Version 2.6.5
- **feat:** Make `stateHistory` and `activeLayers` public and add `moveLayerListPosition` method to improve layer management functionality.

## Version 2.6.4
- **fix(iOS):** resolve editor error on iOS devices with cupertino design when editing completion

## Version 2.6.3
- **feat:** Add preview screen to sample application for displaying edited images
- **chore:** Update emoji_picker_flutter dependency to version 2.2.0

## Version 2.6.2
- **feat:** Add a custom widget option to the Whatsapp design. This allows user to create same as in whatsapp, a text field with a send button or any other widget they want.

## Version 2.6.1
- **docs:** Update README for better image viewing

## Version 2.6.0
- **feat:** Added prebuilt design option inspired by WhatsApp design. Now the image editor includes a prebuilt design that closely resembles the visual style of WhatsApp, offering users a familiar and intuitive editing experience.

## Version 2.5.8
- **chore:** Dependency updates

## Version 2.5.7
#### Breaking Changes
- Changed the way aspect ratios and the initial value are set.
- I18n for crop aspect ratios must now be set in the crop-rotate editor configs.

## Version 2.5.6
- **feat:** Allow users to set only the required crop aspect ratios. Details in [GitHub issue #20](https://github.com/hm21/pro_image_editor/issues/20)

## Version 2.5.5
- **fix:** Fix flutter analyze tests and format code.

## Version 2.5.4
- **feat:** Add the `strokeWidthOnChanged` callback. Details in [GitHub pull #19](https://github.com/hm21/pro_image_editor/pull/19)

## Version 2.5.3
- **feat:** Customize dialog colors in Cupertino design. Details in [GitHub pull #18](https://github.com/hm21/pro_image_editor/pull/18)

## Version 2.5.2
- **fix:** The `allowCompleteWithEmptyEditing` logic was dropped by the committing. Details in [GitHub pull #17](https://github.com/hm21/pro_image_editor/pull/17)

## Version 2.5.1
- **feat:** Set theme for alert dialog. Details in [GitHub pull #16](https://github.com/hm21/pro_image_editor/pull/16)

## Version 2.5.0
- **feat:** New editor `Blur-Editor`. Details in [GitHub pull #15](https://github.com/hm21/pro_image_editor/pull/15)

## Version 2.4.6
- **feat:** Add `Change Font Scale` feature to text editor. Details in [GitHub pull #14](https://github.com/hm21/pro_image_editor/pull/14)

## Version 2.4.5
- **feat:** Add parameter `allowCompleteWithEmptyEditing`. Details in [GitHub pull #11](https://github.com/hm21/pro_image_editor/pull/11)

## Version 2.4.4
- **fix:** Hotfix for transparent images that are not displaying correctly after crop/rotate. Details in [GitHub issue #10](https://github.com/hm21/pro_image_editor/issues/10)

## Version 2.4.3
- **Refactor:** Upgrade Flutter to latest version and fix new analyze issues.

## Version 2.4.2
- **feat:** Add landscape mode for device orientation, details in [GitHub issue #7](https://github.com/hm21/pro_image_editor/issues/7)

## Version 2.4.1
- **fix:** Hotfix to close the editor with custom parameters, details in [GitHub issue #6](https://github.com/hm21/pro_image_editor/issues/6)

## Version 2.4.0
#### Breaking Changes
- Updated `emoji_picker_flutter` dependency to version 2.0.0. This version introduces significant enhancements, including:
  - Improved configuration options for better customization.
  - Addition of a new search function for easier emoji discovery.
  - Expanded design options for enhanced visual appearance.

## Version 2.3.2
- **style:** Enclose if statement in block in pro_image_editor_main.dart

## Version 2.3.1
- **fix:** fix overflow bug in BottomAppBar, details in [GitHub issue #5](https://github.com/hm21/pro_image_editor/issues/5)

## Version 2.3.0
- **feat:** Enhance state history management

## Version 2.2.3
- **feat:** Improved the fly animation within the Hero widget to provide a smoother and more visually appealing experience.

## Version 2.2.2
- **fix:** example bug for `emojiSet`, details in [GitHub issue #2](https://github.com/hm21/pro_image_editor/issues/2)

## Version 2.2.1
- **fix:** close warning bug, details in [GitHub issue #1](https://github.com/hm21/pro_image_editor/issues/1)

## Version 2.2.0
- **feat:** Added functionality to extend the bottomAppBar with custom widgets, providing users with more flexibility in customizing the bottom bar.

## Version 2.1.1
- **style** Improved Dart code formatting

## Version 2.1.0
- **feat:** Added functionality to extend the appbar with custom widgets, providing users with more flexibility in customizing the app's header.

## Version 2.0.0
- **feat:** Introducing the "Sticker" editor for seamless loading of stickers and widgets directly into the editor.

## Version 1.0.3
- **docs** Update README.md with improved preview image

## Version 1.0.2
- **feat:** Improved accessibility: `ProImageEditorConfigs` is now directly exported for easier integration and usage.


## Version 1.0.1
- **docs** Updated images in README.md for enhanced clarity
- **docs** Added documentation to adaptive_dialog.dart for better code understanding
- **style** Formatted Dart code across various modules for improved consistency

## Version 1.0.0
- **feat:** PaintingEditor
- **feat:** TextEditor
- **feat:** CropRotateEditor
- **feat:** FilterEditor
- **feat:** EmojiEditor