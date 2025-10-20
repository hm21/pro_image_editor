import '/features/clips_editor/pages/clips_editor_page.dart';
import '/shared/widgets/reactive_widgets/reactive_custom_appbar.dart';
import '/shared/widgets/reactive_widgets/reactive_custom_widget.dart';

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
  Function() addClip,
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

  /// Returns a copy of this object with the provided overrides.
  ClipsEditorWidgets copyWith({
    ClipsEditorAppBarBuilder? appBar,
    ClipsEditorBottomBarBuilder? bottomBar,
    ClipsEditorAddClipButton? addVideoClipButton,
  }) {
    return ClipsEditorWidgets(
      appBar: appBar ?? this.appBar,
      bottomBar: bottomBar ?? this.bottomBar,
      addVideoClipButton: addVideoClipButton ?? this.addVideoClipButton,
    );
  }
}
