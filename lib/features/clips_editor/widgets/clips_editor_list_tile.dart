import 'package:flutter/material.dart';

import '/core/models/editor_callbacks/pro_image_editor_callbacks.dart';
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/editor_image.dart';
import '/shared/widgets/auto_image.dart';
import '../models/video_clip.dart';

/// Tile widget that renders an [ClipsListTile] inside a list.
class ClipsListTile extends StatefulWidget {
  /// Creates an instance of [ClipsListTile].
  const ClipsListTile({
    super.key,
    required this.configs,
    required this.callbacks,
    required this.clip,
    this.onTap,
  });

  /// Configuration options for the Image Editor.
  final ProImageEditorConfigs configs;

  /// The callback handlers for editor actions.
  final ProImageEditorCallbacks callbacks;

  /// The video clip currently being processed or edited.
  final VideoClip clip;

  /// Callback when the tile is tapped.
  final Function()? onTap;

  @override
  State<ClipsListTile> createState() => _ClipsListTileState();
}

class _ClipsListTileState extends State<ClipsListTile> {
  late final Future<EditorImage?> _thumbnailFuture;

  @override
  void initState() {
    super.initState();

    _thumbnailFuture = _createThumbnailImage();
  }

  Future<EditorImage?> _createThumbnailImage() async {
    if (widget.clip.image != null) {
      return widget.clip.image;
    }

    final callback = widget.callbacks.clipsEditorCallbacks?.onReadKeyFrame;
    if (callback == null) return null;

    final result = await callback(widget.clip);
    return EditorImage.memory(result);
  }

  @override
  Widget build(BuildContext context) {
    return _buildClipsTile(context);
  }

  Widget _buildClipsTile(BuildContext context) {
    return ListTile(
      leading: _buildLeading(),
      title: Text(
        widget.clip.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: widget.clip.subtitle != null
          ? Text(
              widget.clip.subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      onTap: widget.onTap,
    );
  }

  Widget _buildLeading() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        // Important that progress-spinner will not overflow.
        width: 50,
        height: 50,
        child: FutureBuilder(
            future: _thumbnailFuture,
            builder: (_, snapshot) {
              final image = snapshot.data;

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: image == null
                    ? _buildFallbackThumbnail()
                    : AutoImage(
                        image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        configs: widget.configs,
                      ),
              );
            }),
      ),
    );
  }

  Widget _buildFallbackThumbnail() {
    final color = widget.configs.clipsEditor.style.clipThumbnailBackground;
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withAlpha(80),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        widget.configs.clipsEditor.icons.clipThumbnail,
        color: color,
        size: 24,
      ),
    );
  }
}
