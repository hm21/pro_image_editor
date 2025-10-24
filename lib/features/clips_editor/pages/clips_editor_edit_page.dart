import 'dart:async';

import 'package:flutter/material.dart';

import '/core/mixins/converted_configs.dart';
import '/core/mixins/editor_configs_mixin.dart';
import '/core/models/editor_callbacks/pro_image_editor_callbacks.dart';
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/video/trim_duration_span_model.dart';
import '/shared/controllers/video_controller.dart';
import '/shared/widgets/video/video_editor_configurable.dart';
import '/shared/widgets/video/video_editor_controls_widget.dart';
import '../models/video_clip.dart';
import '../widgets/clips_editor_edit_app_bar.dart';

/// A page for editing a single video clip within the clips editor.
class ClipsEditorEditPage extends StatefulWidget with SimpleConfigsAccess {
  /// Creates a [ClipsEditorEditPage].
  const ClipsEditorEditPage({
    super.key,
    required this.configs,
    required this.callbacks,
    required this.videoClip,
  });

  @override
  final ProImageEditorConfigs configs;

  @override
  final ProImageEditorCallbacks callbacks;

  /// The video clip being edited.
  final VideoClip videoClip;

  @override
  State<ClipsEditorEditPage> createState() => ClipsEditorEditPageState();
}

/// State for [ClipsEditorEditPage].
class ClipsEditorEditPageState extends State<ClipsEditorEditPage>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  final _rebuildController = StreamController.broadcast();
  late final _controller = ProVideoController(
    videoPlayer: const SizedBox.shrink(),
    videoDuration: widget.videoClip.duration,
    initialResolution: Size.zero,
    fileSize: 0,
    initialTrimSpan: widget.videoClip.trimSpan,
    thumbnails: widget.videoClip.thumbnails,
  );

  @override
  void initState() {
    super.initState();
    _setupKeyFrames();
  }

  @override
  void dispose() {
    _controller.dispose();
    _rebuildController.close();
    super.dispose();
  }

  void _setupKeyFrames() async {
    if (_controller.thumbnails == null || _controller.thumbnails!.isEmpty) {
      final result = await callbacks.clipsEditorCallbacks?.onReadKeyFrames
          ?.call(widget.videoClip);
      if (!mounted || result == null) return;
      _controller.thumbnails = result.map(MemoryImage.new).toList();
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    _rebuildController.add(null);
    super.setState(fn);
  }

  /// Closes the editor.
  void close() {
    Navigator.pop(context);
  }

  /// Removes the clip.
  void remove() {
    Navigator.pop(context, true);
  }

  /// Saves changes and exits.
  void done() {
    widget.videoClip.trimSpan = TrimDurationSpan(
      start: _controller.startTime,
      end: _controller.endTime,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: clipsEditorConfigs.widgets.editClipBottomBar?.call(
        this,
        _rebuildController.stream,
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    if (clipsEditorConfigs.widgets.editClipAppBar != null) {
      return clipsEditorConfigs.widgets.editClipAppBar!(
        this,
        _rebuildController.stream,
      );
    }

    return ClipsEditorEditAppBar(
      configs: configs.clipsEditor,
      i18n: i18n.clipsEditor,
      onClose: close,
      onDone: done,
      onRemove: remove,
    );
  }

  Widget _buildBody() {
    return VideoEditorConfigurable(
      controller: _controller,
      child: GestureDetector(
        onTap: _controller.togglePlayState,
        child: Stack(
          alignment: Alignment.center,
          children: [
            callbacks.clipsEditorCallbacks?.onBuildPlayer
                    ?.call(_controller, widget.videoClip) ??
                const SizedBox.shrink(),
            Padding(
              padding: widget.configs.clipsEditor.style.editPageBodyPadding,
              child: VideoEditorControlsWidget(
                initialTrimSpan: widget.videoClip.trimSpan,
              ),
            ),
            ...(clipsEditorConfigs.widgets.editPageBodyItems?.call(
                  this,
                  _rebuildController.stream,
                ) ??
                []),
          ],
        ),
      ),
    );
  }
}
