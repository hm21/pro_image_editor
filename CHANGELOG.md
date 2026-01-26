# Changelog

## 11.18.3
- **FEAT**(paint-editor): Add freestyle arrow modes (`freeStyleArrowStart`, `freeStyleArrowEnd`, `freeStyleArrowStartEnd`) to draw freehand paths with arrowheads at the start, end, or both ends.

## 11.18.2
- **FEAT**(EditorSafeArea): Add convenience constructors `none`, `symmetric`, and `fromLTRB` for easier safe area configuration.
- **FIX**(HelperLines): Resolves the issue of horizontal lines not showing up when the editor overflows the screen.

## 11.18.1
- **FIX**(filter-editor): Ensure that the applied filters can also be removed.

## 11.18.0
- **FEAT**(filter-editor): Restore previously applied filter when `enableMultiSelection` is disabled, allowing users to toggle between filters instant of stacking filters.

## 11.17.0
- **FEAT**(paint-editor): Add hexagon shape tool. More details in PR [#738](https://github.com/hm21/pro_image_editor/pull/738).

## 11.16.0
- **FIX**(text-editor): Persist text shadow properties when exporting and importing state history. More details in PR [#733](https://github.com/hm21/pro_image_editor/pull/733).

## 11.15.6
- **FEAT**(text-editor): Add an optional background and borders to the text editor input field. More details in PR [#735](https://github.com/hm21/pro_image_editor/pull/735).

## 11.15.5
- **FEAT**(network-image): Added optional `networkHeaders` to the `EditorImage`. More details in PR [#729](https://github.com/hm21/pro_image_editor/pull/729).

## 11.15.4
- **FIX**(widget-layer): Resolve the issue of the optional `width` being applied incorrectly.

## 11.15.3
- **FEAT**(widget-layer): Add optional `width` property.

## 11.15.2
- **FEAT**(crop-rotate-editor): Add new callback `onTransformUpdateEnd` that returns all transformation changes whenever a value in the crop-rotate editor is modified.

## 11.15.1
- **FEAT**(text-editor): Add config `enableAutoWrapOnLayer` to the `TextEditorConfigs` which allows for deciding whether the layer applies the editor's auto wrapping or not. More details in PR [#720](https://github.com/hm21/pro_image_editor/pull/720).

## 11.15.0
- **FEAT**(crop-editor): Add `setScale` method to cropRotateEditor for programmatically setting the scale factor.

## 11.14.2
- **FIX**(main-editor): Resolve issue where `onLayerTapUp` is never called.
- **FIX**(main-editor): Prevent the 'getSelectedLayer' function from throwing an exception when a layer is not found.

## 11.14.1
- **FIX**(main-editor): Prevent dual editor opening (paint and text) when a text layer that is inside a paint layer is tapped with Apple pencil.

## 11.14.0
- **FEAT**(crop-editor): Add `cropOverlayOpacity` and `cropOverlayInteractionOpacity` to control the opacity outside the crop area when editing an image.

## 11.13.0
- **FEAT**(text-editor): Add `enableImageBoundaryTextWrap` property to `TextEditorConfigs` to automatically wrap text at the actual image boundaries instead of screen boundaries. More details in PR [#704](https://github.com/hm21/pro_image_editor/pull/704).
- **FIX**(main-editor): Resolve apple pencil tap detection for text layer editing. More details in PR [#705](https://github.com/hm21/pro_image_editor/pull/705).

## 11.12.2
- **FEAT**(main-editor): Make scaling actions done through desktop interactions (mouse scroll or keyboard) consistent between layer types and proportional to the current size of the layer.

## 11.12.1
- **FIX**(RTL): Resolve incorrect layer selection box location. Resolves issue [#698](https://github.com/hm21/pro_image_editor/issues/698). 

## 11.12.0
- **FEAT**(text-editor): Added `enableTapOutsideToSave` configuration to `TextEditorConfigs` to control whether tapping outside the text field saves the text annotation. 
- **FIX**(paint-editor): Resolve draw delay in the freestyle mode. Resolves issue [#696](https://github.com/hm21/pro_image_editor/issues/696).

## 11.11.0
- **FEAT**(dashDotLine): Added new paint-mode "dashDotLine".

## 11.10.1
- **FIX**(callbacks): Resolve issue where the callback `onDone` in mainEditorCallbacks is not triggered. Resolves issue [#681](https://github.com/hm21/pro_image_editor/issues/681).

## 11.10.0
- **FEAT**: Add support for blank editors via `ProImageEditor.blank` constructor, allowing creation of editors without an initial image.

## 11.9.1
- **FIX**(text-editor): Resolve the issue of the theme changing during the hero flight. Resolves issue [#677](https://github.com/hm21/pro_image_editor/issues/677).

## 11.9.0
- **FEAT**(main-editor): Introduced `tools` in `MainEditorConfigs` to configure available sub-editors and their order, replacing old `enableModeX` flags with a cleaner list-based API.  
- **FEAT**(paint-editor): Introduced `tools` in `PaintEditorConfigs` to define available paint modes and their order, deprecating individual `enableModeX` flags.  
- **FEAT**(crop-rotate-editor): Introduced `tools` in `CropRotateEditorConfigs` with a new `CropRotateTool` enum for rotate, flip, aspect ratio, and reset actions, deprecating the old `showXButton` flags.  

## 11.8.0
- **FEAT**(callbacks): Add `onEditLayer` to `PaintEditorCallbacks`, allowing custom paint-layer editing logic (e.g., via a side menu). This was requested in [#673](https://github.com/hm21/pro_image_editor/issues/673).
- **FEAT**(layers): Add `copyWith` method to all layer classes for easier cloning and modification.

## 11.7.0
- **FEAT**(sub-editors): Add `enableGesturePop` config to all sub-editors to control whether user back navigation (hardware back button, predictive back swipe) is allowed.

## 11.6.0
- **FEAT**(eraser): Extend the eraser in the paint editor so that its size and mode can be changed dynamically.

## 11.5.8
- **FIX**(eraser): Resolve the issue of delayed erasing. Resolves issue [#662](https://github.com/hm21/pro_image_editor/issues/662).

## 11.5.7
- **DOCS**(readme): Remove outdated information about HTML renderer support in Flutter.

## 11.5.6
- **FIX**(image-generation): Resolve issue where updating the background image could throw an error when exporting the image. Resolves issue [#652](https://github.com/hm21/pro_image_editor/issues/652).

## 11.5.5
- **FIX**(video-trim-bar): Resolve issue where `maxDuration` displayed an incorrect time span when its value exceeded the video duration. Resolves issue [#648](https://github.com/hm21/pro_image_editor/issues/648).

## 11.5.4
- **FIX**(iOS): Fixes scroll glitch in the bottom bar. Resolves issue [#640](https://github.com/hm21/pro_image_editor/issues/640).

## 11.5.3
- **FIX**(video-editor): Fixed issue where state history import didn't work in the video editor. Resolves video-editor discussion [#50](https://github.com/hm21/pro_video_editor/discussions/50).

## 11.5.2
- **FEAT**(style): Add missing `editSheetColor` to paint-editor styles.

## 11.5.1
- **FIX**(recorder): Fix slow image generation after transforming layers when layer-selection is disabled.
- **FIX**(emoji-picker): Fix null error in the console from the emoji picker. Resolves issue [#642](https://github.com/hm21/pro_image_editor/issues/642).
- **FEAT**(debug): Add extensive `debugFillProperties` for better debugging.

## 11.5.0
- **FEAT**(eraser): The eraser in the PaintEditor now removes only partial areas of the painting by default, instead of the entire object. This behavior can be adjusted in the PaintEditorConfigs using `eraserMode` and `eraserSize`.

## 11.4.1
- **REFACTOR**(flutter): Fix deprecated APIs after upgrading to flutter `3.35.0`.

## 11.4.0
- **REFACTOR**(flutter): Adapt the code to make it compatible with Flutter `3.35.0`.

## 11.3.0
- **FEAT**(text-editor): Replace `EditableText` with `TextField` to enhance text selection and overall input handling.

## 11.2.3
- **FIX**(multiselect): Resolve issue where layers could still be selected even when `enableSelection` for the layer was set to `false`. This resolves issue [#628](https://github.com/hm21/pro_image_editor/issues/628).

## 11.2.2
- **FIX**(main-editor): Resolve issue where the `replaceLayer` function broke the logic that ensured layers resized correctly when the screen size changed. This resolves issue [#624](https://github.com/hm21/pro_image_editor/issues/624) and issue [#626](https://github.com/hm21/pro_image_editor/issues/626).

## 11.2.1
- **FIX**(state-history): Resolve issue where updating the background-image overwrote previous states.

## 11.2.0
- **FEAT**(state-history): Added support for undo and redo when the background image is changed in the state history.

## 11.1.3
- **FIX**(text-editor): Fixed an issue where long text didn’t wrap correctly.
- **FIX**(video-editor): Fixed display issues with the trim bar, especially for maximum and minimum durations.

## 11.1.2
- **REFACTOR**(text-layer): Remove `colorPickerPosition` from `TextLayer` and related widgets.
- **FIX**(import/export): Resolve issue of import/export crashing when the minifier is enabled. This resolves issue [#613](https://github.com/hm21/pro_image_editor/issues/613).
- **FIX**(text-layer): Fixed lag in hero animation.
- **FIX**(text-layer): Fixed issue where edited text layers didn't update the state history.

## 11.1.1
- **FIX**(web-build): Fix web-build failure caused by int64 values. This resolves issue [#612](https://github.com/hm21/pro_image_editor/issues/612).

## 11.1.0
- **FEAT**(import-export): Improved minifier with configurable decimal rounding and boolean value minification.

## 11.0.1
- **FIX**(video-editor): Resolve incorrect behavior of `maxTrimDuration`.

## 11.0.0
- **FEAT**(multi-select): Layers can now be selected simultaneously using Ctrl, Shift, or long-press gestures.
- **FEAT**(grouping): Layers can be grouped for unified selection and movement.
- **FEAT**(main-editor): Added `selectAllLayers` and `unselectAllLayers` methods for bulk selection control.
- **FEAT**(main-editor): Introduced `enableMultiSelectMode` to allow instant multi-selection without modifier keys.
- **FEAT**(drag-selection): Added support for selecting multiple layers by dragging a rectangle around them.
- **FEAT**(mouse-actions): Added support for different mouse button actions such as pan, multi-select, and drag-select.
- **FEAT**(layer-configs): Added `enableKeyboardMultiSelection` and `enableLongPressMultiSelection` to `LayerInteractionConfigs` for dynamically enabling or disabling multi-selection via keyboard or long press.
- **FEAT**(remove-area): Applied `AnimatedSwitcher` to the remove area for smooth fade-in/out transitions.
- **FEAT**(crop-rotate-editor): Add `enableFlipAnimation` to `CropRotateEditorConfigs`, which enables flip animation by default.

<br/>

- **PERF**(GPU): Improved GPU performance by optimizing transformation and color filter matrices, especially beneficial when multiple filters or tune adjustments are applied.
- **PERF**(CPU): Replace the `rounded_background_text` package-code with a custom solution that significantly improves the CPU usage required for drawing calculations.
- **PERF**(RAM): Use cached sizes in the filter editor to display filter previews which reduce RAM usage. 

<br/>

- **FIX**(rounded_background_text): Resolved issue where two text lines with nearly identical widths would not render with correct rounding; now ensures both lines are treated as equally long.
- **FIX**(crop-rotate-editor): Resolve broken undo/redo functionality in the `CropRotateEditor`.

<br/>

#### Breaking Changes
- Removed `layerIndex` from `onTapEditSticker` in `StickerEditorCallbacks`.
- Removed `selectedLayerIndex` from `MainEditor`.
- Remove `ColorFilterAddons.opacity`.
- The way the editor handles multiple filters and tune adjustments has changed, so combinations might now appear slightly differently.
- Removed `enableFreeStyleHighPerformanceScaling`, `enableFreeStyleHighPerformanceMoving` and `enableFreeStyleHighPerformanceHero` from `PaintEditorConfigs`.

## 10.5.4
- **FEAT**(text-layers): Delete the edited 'TextLayers' if the new text is empty.

## 10.5.3
- **FIX**(helper-lines): Resolve lint issues after upgrading to `flutter_lints: ^6.0.0`.

## 10.5.2
- **FIX**(helper-lines): Resolve issue where helper lines are visible when hovering over the layer remove zone. This resolves issue [#561](https://github.com/hm21/pro_image_editor/issues/561).

## 10.5.1
- **FIX**(import-export): Resolve issue where importing from text layers throws an error and fails.

## 10.5.0
- **FEAT**(text-editor): Add `enableAutoOverflow` property to `TextEditorConfigs` to automatically wrap text when it exceeds the editor's visible area.

## 10.4.1
- **FIX**(paint-editor): Resolve issue where custom widgets weren't working in the new paint-layer editor.

## 10.4.0
- **FEAT**(paint-layer): PaintLayers can now be edited in the main-editor. This adds various new configurations to `I18nPaintEditor`, `PaintEditorConfigs`, `PaintEditorStyle`, and `PaintEditorWidgets`.
- **FIX**(paint-editor): Resolve issue where setting a color programmatically didn't update the color bar. This resolves issue [#552](https://github.com/hm21/pro_image_editor/issues/552).

## 10.3.2
- **FIX**(helper-lines): Resolve issue where layers wouldn't release when positioned very close (1–3 pixels) on the same axis.
- **FIX**(screen-resize): Resolve issue where layers resize incorrectly after image transformation. This resolves issue [#547](https://github.com/hm21/pro_image_editor/issues/547).

## 10.3.1
- **FIX**(crop-rotate-editor): Resolve rotation reset issue after changing aspect ratio.

## 10.3.0
- **FIX**(screen-resize): Resolve issue causing layers with custom `FractionalTranslation` to be misplaced.
- **FIX**(paint-editor): Resolve issue where layers didn't resize with the screen.
- **FIX**(paint-mode): Resolve issue where creating polygons didn't recognize tap events.
- **FEAT**(paint-editor): Eraser can now also remove existing paintings from other histories.

## 10.2.8
- **FIX**(helper-lines): Resolve issue where layers wouldn't release when sharing the same axis.
- **FIX**(helper-lines): Resolve issue where helperLine configs had no effect.

## 10.2.7
- **DOCS**(example): Add AI example demonstrating how the image editor can be controlled directly through AI text commands.
- **DOCS**(example): Add AI example showing how to add AI-generated images as stickers.
- **DOCS**(example): Add AI example illustrating how to replace the background with a newly generated image.
- **DOCS**(readme): Update the readme with previews of the new AI-generated content.

## 10.2.6
- **FIX**(paint-editor): Resolved an issue where the `opacityBottomSheetBackground` was not applying any effect. This resolves issue [#540](https://github.com/hm21/pro_image_editor/issues/540).

## 10.2.5
- **FEAT**(callbacks): Add `onStateHistoryChange` callback to `MainEditorCallbacks`.
- **FEAT**(callbacks): Add `onImageDecoded` callback to `MainEditorCallbacks`.
- **FEAT**(main-editor): Add `autoCorrectZoomOffset` and `AutoCorrectZoomScale` parameters to the `addLayer` method, allowing layers to be added inside the viewport even when the user is zoomed into a specific area of the editor.
- **FEAT**(main-editor): Add `closeSubEditor` method to close all subeditors.

## 10.2.4
- **FEAT**(layer-interaction): Add `releaseThreshold` to control snapping behavior for helper lines.
- **FEAT**(helper-lines): add `isDisabledAtZoom` property to control visibility based on zoom level.

## 10.2.3
- **FIX**(widget-layer): Resolved an issue where the edit button on editable `WidgetLayer` was visible even when interaction was disabled. This resolves issue [#532](https://github.com/hm21/pro_image_editor/issues/532).
- **FEAT**(callback): Add `onHoverRemoveAreaChange` to detect hover on remove area. This was requested in [#531](https://github.com/hm21/pro_image_editor/issues/531).

## 10.2.2
- **FIX**(export): Resolved an issue where exporting multiple layers could overwrite existing ones. This resolves issue [#527](https://github.com/hm21/pro_image_editor/issues/527).

## 10.2.1
- **FIX**(layer): Resolved an issue where importing a layer didn’t restore the `boxConstraints`.

## 10.2.0
- **FEAT**(layer): Show alignment guides when layers share the same x or y position.

## 10.1.2
- **FIX**(compat): Increased minimum Flutter SDK version to 3.32.0 to ensure compatibility with updated OverlayPortal APIs.

## 10.1.1
- **FIX**(gestures): Add new widget `GestureInterceptor` to prevent unnecessary gesture bubbling up the widget tree.

## 10.1.0
- **FEAT**(callbacks): Add new `onKeyboardEvent` callback to `MainEditorCallbacks`.

## 10.0.0
- **FEAT**(layer): Move the layer selection to the overlay to prevent it from being captured. This change allows layers to remain selected even after an interaction. The behavior can be controlled using the `keepSelectionOnInteraction` variable in the `LayerInteractionConfigs`.
- **FEAT**(layer-stack): Add `moveLayerForward` and `moveLayerBackward` to move a layer one step forward or backward in the stack.
- **FEAT**(layer-stack): Add `moveLayerToFront` and `moveLayerToBack` to move a layer to the top or bottom of the stack.
- **FEAT**(layer-stack): Add `getLayerStackIndex` to retrieve a layer's index in the stack.
- **FEAT**(layer): Add `duplicateLayer` to the `LayerCopyManager`.
- **FEAT**(callback): Add `onLayerTapDown` and `onLayerTapUp` to the `MainEditorCallbacks`.
- **FEAT**(layer): Add layer type identification for emoji, text, paint, and widget layers.
- **FEAT**(cropMode): The `CropMode` can now be dynamically switched inside the `cropRotateEditor` by updating the `cropMode` value.
- **FEAT**(crop-editor): The `CropEditor` now supports every aspect ratio for the round cropper, not just aspect ratio 1.
- **FEAT**(crop-editor): Changing the aspect ratio no longer resets other applied changes like flip or rotate.
- **FEAT**(paint-editor): Add `addPainting` method that allows to programmatically create new paintings.

<br/>

- **FIX**(text-layer): Resolve textLayer opening without requiring double-tap.
- **FIX**(autoSource): Resolve issue where an error is thrown when the 'file' argument in the 'autoSource' constructor is null. This resolves issue [#509](https://github.com/hm21/pro_image_editor/issues/509).
- **FIX**(text-editor): Resolve the issue of input text auto-wrapping, which does not happen in the main editor. This resolves issue [#469](https://github.com/hm21/pro_image_editor/issues/469). 
- **FIX**(paint-editor): Resolve the issue where drawings shift when the AppBar or BottomBar is missing in the main editor. This resolves issue [#410](https://github.com/hm21/pro_image_editor/issues/410). 

<br/>

- **DOCS**(example): Introduce a new [example](https://github.com/hm21/pro_image_editor/blob/stable/example/lib/features/layer_select_design_example.dart) to showcase a more contemporary layer selection design.

<br/>

- **TEST**: Added more than 200 new unit and widget tests to improve coverage and ensure more robust error detection.

<br/>

#### Breaking Changes
- Removed all deprecated configuration settings.
- Changed the layer selection system to use an overlay-based approach. This may lead to different results in certain edge cases. If you have implemented a custom selection behavior, review it to ensure compatibility.
- Remove the configuration `enableRoundCropper` from `CropRotateEditorConfigs` and add the configuration `initialCropMode`.


## 9.13.0
- **FEAT**(Text-Editor): Add the `inputTextFieldAlign` property to the `TextEditorConfigs` to dynamically align the input field. This was requested in [#502](https://github.com/hm21/pro_image_editor/issues/502).


## 9.12.0
- **FEAT**(import): Add `enableInitialEmptyState` to `ImportEditorConfigs` so the editor can replace the existing state history without including an empty first page.

## 9.11.2
- **FIX**(bottom-sheet): Wrap bottom sheets in `SafeArea` to ensure proper display within device safe zones.

## 9.11.1
- **FIX**(video-editor): Add missing `image` parameter to `GroundedFilterBar`.

## 9.11.0
- **FEAT**(video-editor): Added new parameters to `CompleteParameters` required for extending the editor with video editing.

<br/>


- **FIX**(video-editor): Fixed issue where filter previews were displayed incorrectly.
- **FIX**(video-editor): Fixed issue where the trim bar lost its state when moving a layer.

## 9.10.1
- **FIX**(double-tap): Resolve issue where double tapping still zooms even when `enableZoom` is set to `false`. This resolves issue [#484](https://github.com/hm21/pro_image_editor/issues/484).

## 9.10.0
- **FEAT**(polygon): Added new paint-mode "polygon".

## 9.9.5
- **FIX**(widget-layer): `copyWith` now correctly includes `exportConfigs`. 

## 9.9.4
- **FIX**(Main-Editor): Corrected editor name handling in `openPage` to ensure proper behavior of `onOpenSubEditor`, `onStartCloseSubEditor` and `onEndCloseSubEditor`. This resolves issue [#474](https://github.com/hm21/pro_image_editor/issues/474).

## 9.9.3
- **FIX**(Layers): Corrected size calculation to prevent layer shifting.
- **FIX**(Main-Editor): Fixed an issue where disabled layers blocked zoom gestures.

## 9.9.2
 - **FIX**(Crop-Rotate-Editor): Ensure the editor respects the `maxOutputSize` constraint.

## 9.9.1
 - **FIX**(Crop-Rotate-Editor): Prevent crashes when clamping values with reversed lower and upper limits. This resolves issue [#462](https://github.com/hm21/pro_image_editor/issues/462).

## 9.9.0
 - **FEAT**(Sticker-Editor): Added `builder` parameter to `StickerEditorConfigs`, which will replace `buildStickers` in the future. The new `builder` supports directly returning a `WidgetLayer` instead of just a `Widget`, enabling more flexibility and control.

## 9.8.2
 - **FIX**(Paint-Eraser): Resolved an issue where the layer eraser only worked when the user tapped on a layer.

## 9.8.1
 - **FIX**(Image-Generation): Resolved an issue that the image generation was slowly.

## 9.8.0
 - **FEAT**(Layer): Introduce `BoxConstraints` to `Layer` class for enhanced constraint management and layout control.

## 9.7.3
 - **FEAT**(Main-Editor): Add EditorSafeArea to the Main editor to follow SubEditor logic.

## 9.7.2
 - **FIX**(Tune-Editor): Ensure the back button works properly. This resolves issue [#449](https://github.com/hm21/pro_image_editor/issues/449).

## 9.7.1
 - **FIX**(Import): Ensure imported numbers are type-safe even if int and double are incorrect. This resolves issue [#447](https://github.com/hm21/pro_image_editor/issues/447).

## 9.7.0
- **FEAT**(image-converter): Add singleton `ImageConverter` class for format conversion without the image editor.

## 9.6.1
- **FIX**(double-tap): Resolved an issue where double-tapping interfered with pinch-to-zoom functionality. Resolves [#439](https://github.com/hm21/pro_image_editor/issues/439).
- **FIX**(hit-detection): Prevent layer hit detection errors by clamping inner dimensions. Resolves [#440](https://github.com/hm21/pro_image_editor/issues/440).

## 9.6.0
- **FEAT**(double-tap): Support double-tap to zoom in/out when zoom is enabled. More details in Feature-Request [#429](https://github.com/hm21/pro_image_editor/pull/429).

## 9.5.2
- **FIX**(zoom): Fixed issue where config `enableMainEditorZoomFactor` had no effect when creating a new text-layer. Resolves [#426](https://github.com/hm21/pro_image_editor/issues/426).

## 9.5.1
- **FIX**(onCompleteWithParameters): Return correct parameters on completion. Resolves [#403](https://github.com/hm21/pro_image_editor/issues/403).

## 9.5.0
- **FEAT**(callback): Added `copyWith` method to all callback models. More details in Feature-Request [#424](https://github.com/hm21/pro_image_editor/pull/424).
- **FEAT**(zoom): Preserved zoom state by sharing Matrix4 between paint and main editor

## 9.4.1
- **FEAT**(callback): Added `onSelectedLayerChanged` callback to notify when the selected layer changes. More details in PR [#423](https://github.com/hm21/pro_image_editor/pull/423).

## 9.4.0
- **FEAT**(jpeg-encoder): Add `jpegBackgroundColor` option to `ImageGenerationConfigs` to allow customization of JPEG background color.

<br/>


- **FIX**(crop_editor): Add missing copyWith parameters to ensure proper cloning of configuration states.
- **FIX**(PaintEditor.drawing): Ensure `cropToImageBounds` is `false` to prevent unintended cropping behavior.

## 9.3.0
- **FEAT**: Video editing has now been fully implemented in the image editor across all platforms except the web, for which support is not planned. For more details and a list of limitations, please refer to [that discussion](https://github.com/hm21/pro_image_editor/discussions/406) thread.

## 9.2.0
- **FEAT**: Added `clearLayerSelection` method to reset selected layers.
- **FEAT**: Added `selectLayerByIndex` method to select a layer using its index.
- **FEAT**: Added `selectLayerById` method to select a layer by its unique ID.

## 9.1.0
- **FEAT**: Replaced the external packages [`emoji_picker_flutter`](https://pub.dev/packages/emoji_picker_flutter), [`universal_io`](https://pub.dev/packages/universal_io), and [`flutter_web_plugins`](https://api.flutter.dev/flutter/flutter_web_plugins) with lightweight internal implementations.
  The editor now only relies on official Dart and Flutter packages, reducing dependencies and improving maintainability.
- **FEAT**: Added a new preview-only constructor for video editing: `ProImageEditor.video`.
  This feature allows previewing video edits but does not yet support video export.
  Example usage can be found [here](https://github.com/hm21/pro_image_editor/tree/stable/example/lib/features/video_examples).

## 9.0.7
- **FIX**(import): Resolve state restoration issue causing layer shift on cropped images. Resolves [#292](https://github.com/hm21/pro_image_editor/issues/292).

## 9.0.6
- **FIX**(state-history): Resolve issue where the state history limitation does not work when `enableBackgroundGeneration` is set to `false`.

## 9.0.5
- **FIX**(Wasm): Fixes an issue where image generation fails when using WebAssembly. Resolves [#391](https://github.com/hm21/pro_image_editor/issues/391).

## 9.0.4
- **DOCS**(readme): simplify README for better readability

## 9.0.3
- **FEAT**: Add getter `editorScaleFactor` to retrieve current scale factor. See pull request [#392](https://github.com/hm21/pro_image_editor/pull/392) for more details.

## 9.0.2
- **STYLE**: Improved Dart code formatting

## 9.0.1
- **FIX**(EditorImage): Support `File` type in addition to file path

## 9.0.0
- **FEAT**(callbacks): Add new callbacks that are triggered when a layer intersects with a helper line.
- **FEAT**(TextLayer): Improve the text layer hit box for better gesture recognition.
- **FEAT**(File): The file constructor in the main editor and sub-editors now supports adding just the file path in addition to the File itself.

<br/>

- **FIX**(Layers): Fix incorrect layer selection when drawing lines overlay other layers

#### Breaking Changes
- Removed the vibration package dependency and the support for internal feedback vibration. You can read more about this change and see example code on how to implement feedback support [here](https://github.com/hm21/pro_image_editor/discussions/386).
- Replaced `mime`, `image`, `archive`, and `crypto` packages with smaller, internally versions.
- Moved configuration `locale` inside `EmojiEditorConfigs` to `I18nEmojiEditor`.
- Changed the default behavior so that emoji search text is no longer automatically translated, reducing the size of the application by about 1.5MB. The example of how to enable auto-translation or translate a specific locale can be found [here](https://github.com/hm21/pro_image_editor/blob/stable/example/lib/features/emoji_translate_example.dart).
- Removed all deprecated configuration settings.


## 8.3.6
- **FIX**(design-grounded): Fixed an issue where the scrollbar in the grounded bottombar did not restore correctly after opening a subeditor.
- **FIX**(design-whatsapp): Fixed an issue where the filter in the WhatsApp design could not be deselected.

## 8.3.5
- **FIX**(layer-stack): Resolved an issue where the outside overlay color on layers depended on the crop_rotate_editor instead of the active subeditor.

## 8.3.4
- **FIX**(grounded-design): Resolved an issue in the grounded design where switching between screens caused an error due to the ScrollController.

## 8.3.3
- **FIX**(layer-interaction): Resolved an issue where layers with blocked interaction also prevented interaction with background layers. Resolves [#374](https://github.com/hm21/pro_image_editor/issues/374)

## 8.3.2
- **FIX**(emoji-editor): Resolved an issue where categoryViewConfig caused an error. Resolves [#373](https://github.com/hm21/pro_image_editor/issues/373).

## 8.3.1
- **REFACTOR**(configs): Rename configuration properties for clarity.

## 8.3.0
- **FEAT**(paint-editor): Add a new 'pixelate' paint mode to censor specific areas. This paint mode is only supported when using the Impeller rendering engine.
- **FEAT**(CensorConfigs): Add a new configuration option, `enableRoundArea`, which allows the censored area to be rounded instead of rectangular.

## 8.2.0
- **FEAT**(paint-editor): Add a new 'blur' paint mode to censor specific areas. 

## 8.1.12
- **FEAT**(layers): Add missing `showLayers` config to enable/disable layers in paint and crop editor.

## 8.1.11
- **FIX**(export): Resolve an issue where exporting the first state history did return all state histories. Resolves [#353](https://github.com/hm21/pro_image_editor/issues/353).

## 8.1.10
- **FEAT**(callback): Introduced `onEscapeButton` callback inside `MainEditorCallbacks` to allow external handling of the Escape key logic.

## 8.1.9
- **FIX**(text-editor): Ensure text editor layer scales correctly when editing.
Added `enableMainEditorZoomFactor` to `textEditorConfigs` to apply the zoom factor in the text editor as well. Resolves [#349](https://github.com/hm21/pro_image_editor/issues/349).

## 8.1.8
- **FIX**(export): Ensure filters, tune adjustments, and blur configs are exported for `ExportHistorySpan.current` and `ExportHistorySpan.currentAndForward`.

## 8.1.7
- **FEAT**(MainEditorConfigs): Add `enableEscapeButton` to enable or disable the escape button listener.

## 8.1.6
- **FEAT**(layer): Add meta field to layermodels for custom metadata in export/import.

## 8.1.5
- **FEAT**(export): Optimize the export process by including only parameters that were modified in tune adjustments. This reduces the exported file size.

## 8.1.4
- **FIX**(generation): Use `captureOnlyBackgroundImageArea` instead of `captureOnlyDrawingBounds` for background cropping.

## 8.1.3
- **PERF**(capture-image): Improved image capture performance by minimizing its impact on the main thread.

## 8.1.2
- **FIX**(paint-editor): Ensure bottombar selection updates in UI when changed.
- **FIX**(paint-editor): Correct appBar canRedo to use the proper function instead of canUndo.
- **FIX**(layer): Resolve issue where selecting layers that overlap did not function as expected. Resolves issue [#282](https://github.com/hm21/pro_image_editor/issues/282)
- **FIX**(import): Resolve issue where transformations exported from the crop-rotate editor were not properly imported.

## 8.1.1
- **FIX**(crop_rotate_editor): Fixed an issue where the crop-rotate editor would throw multiple errors when reopened. Resolves issue [#236](https://github.com/hm21/pro_image_editor/issues/236) and [#237](https://github.com/hm21/pro_image_editor/issues/237).
- **PERF**(mediaquery): Replaces MediaQuery.of(...) with MediaQuery.sizeOf(...) to optimize performance and minimize unnecessary widget rebuilds.

## 8.1.0
- **FEAT**(layer): Added new methods `lockAllLayers` and `unlockAllLayers` to the main editor, enabling direct locking or unlocking of all layers.

## 8.0.4
- **FIX**(export/import): Resolve an issue where exported stickers within the JSON file could no longer be imported. Resolves issue [#334](https://github.com/hm21/pro_image_editor/issues/334)

## 8.0.3
- **FIX**(blur-editor): Resolve issue where the slider animation does not work in the blur editor.
- **FIX**(layer-context-menu): Resolve issue where the context menu is incorrectly positioned when the editor is embedded within the screen.
- **CHORE**(dependencies): Update package `vibration` to `3.1.1`.

## 8.0.2
- **FIX**(paint-editor): Resolve issue where the paint editor did not use `appBarColor` from the style configuration. More details in PR [#333](https://github.com/hm21/pro_image_editor/pull/333)

## 8.0.1
- **FIX**(layer-interaction): Fix issue where layers remove-area still appear when attempting to move a layer, even when `enableMove` is set to `false`. Resolves issue [#332](https://github.com/hm21/pro_image_editor/issues/332)
- **FEAT**(layer-interaction): Introduce `enableEdit` to the layer interaction options, allowing users to disable direct editing of text layers.

## 8.0.0

#### Features
- **Layer Interaction Overhaul**:
  - Replaced the old `enableInteraction` property on layers with the new `LayerInteraction` class, introducing more specific configuration options:
    - `enableMove`, `enableScale`, `enableRotate`, and `enableSelection`.
  - This provides greater flexibility and precision in configuring layer interactions.

- **Customizable Interaction Widgets**:
  - Updated `LayerInteractionWidgets` with two new options:
    - **`children`**: Allows users to define their own interactive button designs when the layer is selected.
    - **`border`**: Enables users to customize the border appearance of selected layers for a fully tailored design.

#### Breaking Changes
- Removed all deprecated values, including:
  - `TextLayerData`
  - `PaintingLayerData`
  - `EmojiLayerData`
  - `StickerLayerData`
  - `ReactiveWidgetData`
  - `ReactiveAppbarData`
  - `serializeSticker`
  - `exportStickers`

## 7.6.5
- **CHORE**(dependencies): Update `emoji_picker_flutter` to `4.3.0`, `vibration` to `3.0.0` and `http` to `1.3.0`.

## 7.6.4
- **CHORE**(vibration): Updated the `vibration` package to version `2.1.0`.
- **FIX**(vibration): Resolved lint issues introduced by the package update.

## 7.6.3
- **FIX**(grounded-design): Fixed an issue where aspect ratios were incorrectly selected regardless of the `canChangeAspectRatio` flag.

## 7.6.2
- **DOCS**(readme): update readme to reflect latest changes

## 7.6.1
- **FIX**(paint-editor): Resolved an issue where the freestyle painter didn't update the painting in real-time until the user finished painting.

## 7.6.0
- **FEAT**(state-history): Improve internal state history to consume less RAM during in-app usage, enhancing performance in memory-constrained environments.
- **FEAT**(export/import): Introduce reference-based export mechanism to reduce redundancy and significantly minimize export file size.
- **FEAT**(export/import): Add `enableMinify` option to `ExportEditorConfigs` (enabled by default), which further reduces the output file size by minifying key structures. Even with minification disabled, export sizes are notably smaller due to optimizations.
- **REFACTOR**(tests): Reorganize tests by moving module-specific tests to `features` and `shared` directories for better maintainability.
- **TEST**(export/import): Add unit tests for `key_minifier` to ensure reliability of the minification process.

See pull request [#322](https://github.com/hm21/pro_image_editor/pull/322) for more details.

## 7.5.0
- **FEAT**(export/import): Improve widget-layer import/export to enable setting up a `widgetLoader` inside the `ImportEditorConfigs` that loads widgets using custom logic without converting them to `Uint8List`. See pull request [#315](https://github.com/hm21/pro_image_editor/pull/315) for more details.

## 7.4.0
- **FEAT**(emoji): Preload emoji font on web platforms when the main editor opens. This behavior can be enabled or disabled in the emojiEditor configuration using the `enablePreloadWebFont` flag.

## 7.3.2
- **FIX**(web): Resolved performance issues after implementing changes for WASM compatibility. Replaced `dartify` with `toDart`, improving conversion performance from an average of 600ms to 20ms.

## 7.3.1
- **FIX**(crop): Corrected an issue where cropping with specific aspect ratios did not work when the editor was embedded.

## 7.3.0
- **FEAT**(dependencies): Update `emoji_picker_flutter` to `4.2.0` and `image` to `4.5.2`. Adds support for custom translations in emoji editor for emoji search.

## 7.2.0
- **FEAT**(export-history): Introduce the `serializeSticker` parameter to `ExportEditorConfigs` to enable exporting only `StickerLayerData` without converting the sticker to a `Uint8List`. This change incorporates the updates from pull request [#306](https://github.com/hm21/pro_image_editor/pull/306).

## 7.1.1
- **FIX**(android): Resolve crop-drag conflicts with navigation gestures on android. This resolves issue [#303](https://github.com/hm21/pro_image_editor/issues/303)

## 7.1.0
- **FEAT**(Wasm): Replaced the `dart:html` and `dart:js` packages with `package:web` and `dart:js_interop` to enable WebAssembly (Wasm) support. 
The current Flutter version `3.27.1` has an open issue with the `ColorFiltered` widget. As a result, the tune and filter editor will not function in Wasm. Once Flutter resolves this issue, the editor should work without requiring further updates.

## 7.0.1
- **FIX**(zoom): Corrected the layer rotation calculation when the user drags the rotation button. This resolves issue [#266](https://github.com/hm21/pro_image_editor/issues/266)

## 7.0.0
### Changed
- **File Structure Update**:
  - Moved `custom widgets`, `icons`, and `theme` files into the `configs` directory for better organization.
  - Renamed all `theme` files to `styles` to better reflect their purpose.

### Breaking Changes
- File renaming and restructuring require updates to your configuration file:
  - `custom widgets`, `icons`, and `theme` files are now located directly in the `configs` directory of the editor.
  - All theme classes are renamed to end with `Style` for consistency.

For more details on why these breaking changes were made and what improvements they bring, check out that [GitHub discussion](https://github.com/hm21/pro_image_editor/discussions/298).



## 6.2.3
- **FIX**(layer): Resolve issue that layer reposition correctly after screen rotation. This resolves issue [#283](https://github.com/hm21/pro_image_editor/issues/283)

## 6.2.2
- **Fix**(version): Set minimum Flutter version to `3.27.0`. This resolves issue [#287](https://github.com/hm21/pro_image_editor/issues/287)

## 6.2.1
- **FIX**(lint): Resolve lint issues after upgrading to Flutter `3.27.0`

## 6.2.0
- **FEAT**(Main-Editor): Added `updateBackgroundImage` method to update the editor's background image.

## 6.1.6
- **STYLE**: Format dart code 

## 6.1.5
- **FIX**(import): Fixed an issue where imported layers didn't scale correctly on different screen sizes. This resolves issue [#272](https://github.com/hm21/pro_image_editor/issues/272)

## 6.1.4
- **FIX**(zoom): Fixed an issue where the minimum zoom level setting had no effect, ensuring proper enforcement of zoom boundaries in the viewer. This resolves issue [#266](https://github.com/hm21/pro_image_editor/issues/266)

## 6.1.3
- **FIX**(keyboard): resolve issue that escape key throw an error when the context menu is open. This resolves issue [#260](https://github.com/hm21/pro_image_editor/issues/260)

## 6.1.2
- **STYLE(AppBar)**: moved close action to AppBar's leading parameter for improved layout consistency.
- **STYLE(AppBar)**: updated IconButtons to use default 8-point all-around padding, enhancing visual balance.
- **STYLE(AppBar)**: adjusted loading indicator padding to a multiple of 2 to align with design system standards.

## 6.1.1
- **FIX**(CustomWidgets): resolve issue preventing user from using custom widget `removeLayerArea`.

## 6.1.0
- **FEAT**(Layer): Introduce the `enableInteraction` configuration in the `Layer` class to toggle interaction capabilities.
- **FEAT**(CustomWidgets): Add `bodyItemsRecorded` to all editors which can direct generate the final image. This option enables the recording of custom body widgets, enhancing frame functionality.
- **DOC**(Frame): Add an example how users can add a frame.

## 6.0.2
- **FIX**(Recorder): Resolve issue where the editor would incorrectly capture drawing boundaries if the user set `captureOnlyDrawingBounds` to `true`. This resolves issue [#249](https://github.com/hm21/pro_image_editor/issues/249)

## 6.0.1
- **FIX**(Generation-Configs): Removed unnecessary assert for `captureOnlyBackgroundImageArea` and `captureOnlyDrawingBounds`, which was blocking certain combinations for generating transparent images. Details discussed [here](https://github.com/hm21/pro_image_editor/issues/210#issuecomment-2433847115).

## 6.0.0
- **FEAT**(Tune-Editor): Introduced the new "Tune" editor, enabling users to adjust image contrast, saturation, and brightness for enhanced control over image tuning.

- **CHORE**(Dependency): Update `image` dependency to version `4.3.0`.
- **CHORE**(Dependency): Update `vibration` dependency to version `2.0.1`.
- **CHORE**(Dependency): Update `mime` dependency to version `2.0.0`.

- **FIX**(Example): Resolve the issue where the `movable_background_image` example displays the helper lines in the wrong position.
- **FIX**(Example): Resolve all linting issues in the example code.

## 5.4.2
- **FIX**(Paint-Editor): Resolve issue where undo-redo action capturing the incorrect image. This resolves issue [#239](https://github.com/hm21/pro_image_editor/issues/239)

## 5.4.1
- **FEAT**(Emoji-Editor): Update the emoji-editor to version `3.1.0` with custom view order configuration support.

## 5.4.0
- **FEAT**(Filter): Filter-preview widgets are now animated with a default fadeInUp effect.
- **FEAT**(Layer-Interaction): Toolbars will no longer hide by default when interacting with a layer. To restore the previous behavior, set `hideToolbarOnInteraction` to true in the `layerInteraction` settings.
- **FEAT**(Design): Introduced a new design theme called "Grounded".

## 5.3.0
- **FEAT**(Custom-Widgets): add custom widgets to replace layer interaction buttons (edit, remove, rotateScale)

## 5.2.3
- **FIX**(Import): Ensure imported numbers are type-safe even if int and double are incorrect. This resolves issue [#221](https://github.com/hm21/pro_image_editor/issues/221)

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

- **FIX**(vibration): The `Vibration.hasVibrator` check will now only happen if the user has enabled hitVibration in the helper-line configs. This resolves issue [#139](https://github.com/hm21/pro_image_editor/issue/139).


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

- **FIX**(text-editor): Resolve misapplication of secondary color. This resolves issue [#105](https://github.com/hm21/pro_image_editor/discussions/105).
- **FIX**(text-editor): Resolve issue where text styles (bold/italic/underline) are not saved in history. This resolves issue [#118](https://github.com/hm21/pro_image_editor/discussions/118).



## 4.0.4

- **FEAT**(text-editor): Added the ability to programmatically set the secondary color next to the primary color.


## 4.0.3

- **FEAT**(decode-image): Ability to decode the image from external, allowing to change the background image dynamically, which was requested in [#110](https://github.com/hm21/pro_image_editor/discussions/110). 
- **FIX**(layer-position): Ensure layers are rendered from center even without bottombar. This resolves issue [#113](https://github.com/hm21/pro_image_editor/issue/113). 


## 4.0.2

- **REFACTOR**(designs): Made the "Frosted-Glass" and "WhatsApp" designs more compact, making them easier to implement with less code.


## 4.0.1

- **FIX**(import-history): Resolve incorrect multiple importing from state history. This resolves issue [#106](https://github.com/hm21/pro_image_editor/discussions/106).


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
- **FIX**(sticker-export-import) Fix the issue that the sticker size change after export/import them. This resolves issue [#83](https://github.com/hm21/pro_image_editor/discussions/83).


## 3.0.13

- **FIX**(state-history): Resolve incorrect import/export from transform-configs. This resolves issue [#102](https://github.com/hm21/pro_image_editor/discussions/102).


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


## 3.0.0

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
- **FEAT**: Paint-Editor
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

- **FEAT**: PaintEditor
- **FEAT**: TextEditor
- **FEAT**: CropRotateEditor
- **FEAT**: FilterEditor
- **FEAT**: EmojiEditor