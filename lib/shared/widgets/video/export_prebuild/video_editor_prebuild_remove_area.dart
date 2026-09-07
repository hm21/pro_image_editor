import 'package:material_ui/material_ui.dart';
import '/features/main_editor/main_editor.dart';

/// A widget representing the remove area in the video editor.
///
/// This widget displays a delete zone where layers can be dragged
/// for removal.
class VideoEditorRemoveArea extends StatelessWidget {
  /// Creates a [VideoEditorRemoveArea] widget.
  ///
  /// Requires a [removeAreaKey], [editor] state, and a [rebuildStream]
  /// to update the UI when necessary.
  const VideoEditorRemoveArea({
    super.key,
    required this.removeAreaKey,
    required this.editor,
    required this.rebuildStream,
    required this.isLayerBeingTransformed,
  });

  /// The global key for the remove area container.
  final GlobalKey removeAreaKey;

  /// The state of the [ProImageEditor].
  final ProImageEditorState editor;

  /// A stream that triggers UI rebuilds.
  final Stream<void> rebuildStream;

  /// Indicates whether a layer is currently being transformed.
  final bool isLayerBeingTransformed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: StreamBuilder(
          stream: rebuildStream,
          builder: (context, snapshot) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: isLayerBeingTransformed
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        key: removeAreaKey,
                        height: kToolbarHeight,
                        width: kToolbarHeight,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF44336).withAlpha(
                            editor.layerInteractionManager.hoverRemoveBtn
                                ? 255
                                : 100,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: Icon(
                            editor.mainEditorConfigs.icons.removeElementZone,
                            size: 28,
                          ),
                        ),
                      ),
                    )
                  : SizedBox.shrink(key: UniqueKey()),
            );
          },
        ),
      ),
    );
  }
}
