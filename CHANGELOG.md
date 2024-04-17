# Changelog

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
- **Enhancement:** Improved the fly animation within the Hero widget to provide a smoother and more visually appealing experience.

## Version 2.2.2
- **fix:** example bug for `emojiSet`, details in [GitHub issue #2](https://github.com/hm21/pro_image_editor/issues/2)

## Version 2.2.1
- **fix:** close warning bug, details in [GitHub issue #1](https://github.com/hm21/pro_image_editor/issues/1)

## Version 2.2.0
- Added functionality to extend the bottomAppBar with custom widgets, providing users with more flexibility in customizing the bottom bar.

## Version 2.1.1
- Improved Dart code formatting

## Version 2.1.0
- Added functionality to extend the appbar with custom widgets, providing users with more flexibility in customizing the app's header.

## Version 2.0.0
- Introducing the "Sticker" editor for seamless loading of stickers and widgets directly into the editor.

## Version 1.0.3
- Update README.md with improved preview image

## Version 1.0.2
- Improved accessibility: `ProImageEditorConfigs` is now directly exported for easier integration and usage.


## Version 1.0.1
- Updated images in README.md for enhanced clarity
- Formatted Dart code across various modules for improved consistency
- Added documentation to adaptive_dialog.dart for better code understanding

## Version 1.0.0
- Implement PaintingEditor
- Implement TextEditor
- Implement CropRotateEditor
- Implement FilterEditor
- Implement EmojiEditor