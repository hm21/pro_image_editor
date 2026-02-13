import 'package:flutter/widgets.dart';

import '/features/clips_editor/pages/clips_editor_edit_page.dart';
import '/features/clips_editor/pages/clips_editor_page.dart';
import '/shared/widgets/reactive_widgets/reactive_custom_appbar.dart';
import '/shared/widgets/reactive_widgets/reactive_custom_widget.dart';
import 'utils/custom_widgets_typedef.dart';

/// Builder signature for creating an clips editor app bar.
typedef ClipsEditorAppBarBuilder = ReactiveAppbar? Function(
  ClipsEditorPageState editorState,
  Stream<void> rebuildStream,
);

/// Builder signature for creating an clips editor bottom bar.
typedef ClipsEditorBottomBarBuilder = ReactiveWidget? Function(
  ClipsEditorPageState editorState,
  Stream<void> rebuildStream,
);

/// Signature for building a custom "Add Clip" button widget.
///
/// Provides access to the current [ClipsEditorPageState], a [rebuildStream]
/// that triggers UI updates, and the [addClip] function to add new clips.
typedef ClipsEditorAddClipButton = ReactiveWidget? Function(
  ClipsEditorPageState editorState,
  Stream<void> rebuildStream,
  VoidCallback addClip,
);

/// Builder signature for creating a clips editor edit page app bar.
typedef ClipsEditorEditAppBarBuilder = ReactiveAppbar? Function(
  ClipsEditorEditPageState editorState,
  Stream<void> rebuildStream,
);

/// Builder signature for creating a clips editor edit page bottom bar.
typedef ClipsEditorEditBottomBarBuilder = ReactiveWidget? Function(
  ClipsEditorEditPageState editorState,
  Stream<void> rebuildStream,
);

/// Builder signature for creating a custom processing overlay widget.
///
/// Displayed when video clips are being merged. The [progress] value
/// ranges from 0.0 to 1.0 indicating the merge progress.
typedef ClipsEditorProcessingOverlayBuilder = Widget Function(
  ClipsEditorPageState editorState,
  double progress,
);

/// A collection of customizable widgets used in the clips editor UI.
///
/// Provides optional builders for the app bar, bottom bar, and
/// individual Clips track items.
class ClipsEditorWidgets {
  /// Creates an instance of [ClipsEditorWidgets].
  const ClipsEditorWidgets({
    this.appBar,
    this.bottomBar,
    this.addVideoClipButton,
    this.editClipAppBar,
    this.editClipBottomBar,
    this.processingOverlay,
    this.bodyItems,
    this.editPageBodyItems,
  });

  /// Builder for a custom reactive app bar in the Clips editor.
  ///
  /// Called with the current [ClipsEditorPageState] and a [rebuildStream]
  /// to reactively update the app bar UI.
  final ClipsEditorAppBarBuilder? appBar;

  /// Builder for a custom reactive bottom bar in the Clips editor.
  ///
  /// Called with the current [ClipsEditorPageState] and a [rebuildStream]
  /// to rebuild the bottom bar when the editor state changes.
  final ClipsEditorBottomBarBuilder? bottomBar;

  /// A custom widget used as the "Add Clip" button in the editor.
  final ClipsEditorAddClipButton? addVideoClipButton;

  /// Builder for a custom reactive app bar in the clips editor edit page.
  ///
  /// Called with the current [ClipsEditorEditPageState] and a [rebuildStream]
  /// to reactively update the app bar UI when editing individual clips.
  final ClipsEditorEditAppBarBuilder? editClipAppBar;

  /// Builder for a custom reactive bottom bar in the clips editor edit page.
  ///
  /// Called with the current [ClipsEditorEditPageState] and a [rebuildStream]
  /// to rebuild the bottom bar UI when editing individual clips.
  final ClipsEditorEditBottomBarBuilder? editClipBottomBar;

  /// Builder for a custom processing overlay shown during clip merging.
  ///
  /// If provided, replaces the default progress indicator overlay.
  /// The [progress] parameter indicates the merge progress (0.0 to 1.0).
  final ClipsEditorProcessingOverlayBuilder? processingOverlay;

  /// {@macro customBodyItem}
  final CustomBodyItems<ClipsEditorPageState>? bodyItems;

  /// {@macro customBodyItem}
  final CustomBodyItems<ClipsEditorEditPageState>? editPageBodyItems;

  /// Returns a copy of this object with the provided overrides.
  ClipsEditorWidgets copyWith({
    ClipsEditorAppBarBuilder? appBar,
    ClipsEditorBottomBarBuilder? bottomBar,
    ClipsEditorAddClipButton? addVideoClipButton,
    ClipsEditorEditAppBarBuilder? editClipAppBar,
    ClipsEditorEditBottomBarBuilder? editClipBottomBar,
    ClipsEditorProcessingOverlayBuilder? processingOverlay,
    CustomBodyItems<ClipsEditorPageState>? bodyItems,
    CustomBodyItems<ClipsEditorEditPageState>? editPageBodyItems,
  }) {
    return ClipsEditorWidgets(
      appBar: appBar ?? this.appBar,
      bottomBar: bottomBar ?? this.bottomBar,
      addVideoClipButton: addVideoClipButton ?? this.addVideoClipButton,
      editClipAppBar: editClipAppBar ?? this.editClipAppBar,
      editClipBottomBar: editClipBottomBar ?? this.editClipBottomBar,
      processingOverlay: processingOverlay ?? this.processingOverlay,
      bodyItems: bodyItems ?? this.bodyItems,
      editPageBodyItems: editPageBodyItems ?? this.editPageBodyItems,
    );
  }
}
