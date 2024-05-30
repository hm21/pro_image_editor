# Changelog

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