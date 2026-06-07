import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/core/mixins/converted_configs.dart';
import '/core/mixins/editor_configs_mixin.dart';
import '/core/models/editor_callbacks/pro_image_editor_callbacks.dart';
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/shared/widgets/extended/extended_pop_scope.dart';
import '/shared/widgets/reactive_widgets/reactive_custom_appbar.dart';
import '../models/video_clip.dart';
import '../models/video_clip_editor_response.dart';
import '../widgets/clips_editor_app_bar.dart';
import '../widgets/clips_editor_list_tile.dart';
import 'clips_editor_edit_page.dart';

/// The main page of the clips editor, displaying and managing multiple clips.
class ClipsEditorPage extends StatefulWidget with SimpleConfigsAccess {
  /// Constructs a `ClipsEditorPage` widget.
  const ClipsEditorPage({
    super.key,
    this.configs = const ProImageEditorConfigs(),
    this.callbacks = const ProImageEditorCallbacks(),
    this.initialClips,
    required this.theme,
    required this.videoDuration,
  });

  @override
  final ProImageEditorConfigs configs;

  @override
  final ProImageEditorCallbacks callbacks;

  /// Theme that should be applied to the clips editor page.
  final ThemeData theme;

  /// The duration from the video.
  final Duration videoDuration;

  /// A list of video clips that will be initially loaded into the clips editor.
  final List<VideoClip>? initialClips;

  @override
  createState() => ClipsEditorPageState();
}

/// State responsible for rendering and managing the clips editor page.
class ClipsEditorPageState extends State<ClipsEditorPage>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  /// Helper stream to rebuild widgets.
  late final StreamController<void> _rebuildController;

  late final List<VideoClip> _videoClips =
      (widget.initialClips ?? widget.configs.clipsEditor.clips)
          .map((el) => el.copyWith())
          .toList();

  bool _isProcessing = false;
  double _progress = 0.0;
  double _pageFadeOpacity = 0.0;
  final Duration _pageFadeDuration = const Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();
    assert(
      clipsEditorConfigs.clips.isNotEmpty,
      'To use the clips editor, you must set at least one clip in the '
      '`ClipsEditorConfigs`. The first clip should be the original video '
      'that was used to open the editor.',
    );

    _rebuildController = StreamController.broadcast();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _pageFadeOpacity = 1;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _rebuildController.close();
    super.dispose();
  }

  /// Adds a new video clip to the editor.
  ///
  /// If [value] is not provided, the [onAddClip] callback is invoked
  /// to let the user pick or create a new clip.
  Future<void> addClip([VideoClip? value]) async {
    assert(
      callbacks.clipsEditorCallbacks?.onAddClip != null,
      'To add video clips, the [onAddClip] callback inside '
      '[clipsEditorCallbacks] must be provided.',
    );

    final result = value ?? await callbacks.clipsEditorCallbacks!.onAddClip!();
    if (mounted && result != null) {
      _videoClips.add(result);
      setState(() {});
    }
  }

  /// Opens the editor page for the given [clip].
  ///
  /// If the edited clip is removed during editing, it will also be
  /// removed from the current list.
  Future<void> editClip(VideoClip clip) async {
    bool? shouldRemove = await Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        transitionDuration: _pageFadeDuration,
        reverseTransitionDuration: _pageFadeDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        pageBuilder: (context, animation, secondaryAnimation) =>
            ClipsEditorEditPage(
              configs: configs,
              callbacks: callbacks,
              videoClip: clip,
            ),
      ),
    );

    if (shouldRemove == true) {
      _videoClips.removeWhere((value) => value == clip);
      setState(() {});
    }
  }

  /// Closes the editor without returning a selected track.
  Future<void> close() async {
    if (_pageFadeOpacity != 1 || _isProcessing) return;
    await _animatedPageLeave();

    if (mounted) Navigator.pop(context);

    callbacks.clipsEditorCallbacks?.onCloseEditor?.call();
  }

  /// Closes the editor and returns the currently selected track.
  Future<void> done() async {
    if (_pageFadeOpacity != 1 || _isProcessing) return;

    final originalClips =
        widget.initialClips ?? widget.configs.clipsEditor.clips;

    /// Merge the video clips when the user changed something
    if (!listEquals(originalClips, _videoClips)) {
      setState(() {
        _isProcessing = true;
        _progress = 0.0;
      });
      try {
        await callbacks.clipsEditorCallbacks?.onMergeClips?.call(_videoClips, (
          progress,
        ) {
          if (mounted) setState(() => _progress = progress);
        });
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
      if (!mounted) return;
    }

    await _animatedPageLeave();
    if (!mounted) return;

    callbacks.clipsEditorCallbacks?.onDone?.call();
    Navigator.pop(context, VideoClipEditorResponse(videoClips: _videoClips));
  }

  Future<void> _animatedPageLeave() async {
    _pageFadeOpacity = 0;
    setState(() {});
    await Future.delayed(_pageFadeDuration);
  }

  @override
  Widget build(BuildContext context) {
    final safeArea = clipsEditorConfigs.safeArea;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: clipsEditorConfigs.style.uiOverlayStyle,
      child: ExtendedPopScope(
        canPop: clipsEditorConfigs.enableGesturePop,
        child: Theme(
          data: widget.theme.copyWith(
            tooltipTheme: widget.theme.tooltipTheme.copyWith(preferBelow: true),
          ),
          child: SafeArea(
            top: safeArea.top,
            bottom: safeArea.bottom,
            left: safeArea.left,
            right: safeArea.right,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Scaffold(
                  resizeToAvoidBottomInset: false,
                  backgroundColor: clipsEditorConfigs.style.background,
                  appBar: _buildAppBar(constraints),
                  body: _buildBody(),
                  bottomNavigationBar: clipsEditorConfigs.widgets.bottomBar
                      ?.call(this, _rebuildController.stream),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the clips editor app bar.
  PreferredSizeWidget? _buildAppBar(BoxConstraints constraints) {
    if (clipsEditorConfigs.widgets.appBar != null) {
      return clipsEditorConfigs.widgets.appBar!(
        this,
        _rebuildController.stream,
      );
    }

    return ReactiveAppbar(
      builder: (context) => ClipsEditorAppBar(
        configs: clipsEditorConfigs,
        i18n: i18n.clipsEditor,
        onClose: _isProcessing ? null : close,
        onDone: _videoClips.isNotEmpty && !_isProcessing ? done : null,
      ),
      stream: _rebuildController.stream,
    );
  }

  /// Builds the list of clips and the blur background.
  Widget _buildBody() {
    final bool reversedList = clipsEditorConfigs.style.reversedClipsList;

    return Stack(
      fit: StackFit.expand,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: _pageFadeOpacity == 0 ? 0 : 20),
          curve: Curves.ease,
          duration: _pageFadeDuration,
          builder: (context, value, child) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: value, sigmaY: value),
              child: const SizedBox.expand(),
            );
          },
        ),
        AnimatedOpacity(
          duration: _pageFadeDuration,
          opacity: _pageFadeOpacity,
          child: Container(
            color: Colors.black45,
            child: ReorderableListView.builder(
              reverse: reversedList,
              padding: clipsEditorConfigs.style.bodyPadding,
              onReorderItem: (oldIndex, newIndex) {
                final item = _videoClips.removeAt(oldIndex);
                _videoClips.insert(newIndex, item);
                setState(() {});
              },
              itemCount: _videoClips.length,
              itemBuilder: (context, index) {
                final clip = _videoClips[index];
                return ClipsListTile(
                  key: ValueKey('VideoClip-${clip.id}'),
                  configs: configs,
                  callbacks: callbacks,
                  clip: _videoClips[index],
                  onTap: () => editClip(clip),
                );
              },
              header: reversedList ? _buildAddButton() : null,
              footer: reversedList ? null : _buildAddButton(),
            ),
          ),
        ),
        ...(clipsEditorConfigs.widgets.bodyItems?.call(
              this,
              _rebuildController.stream,
            ) ??
            []),
        if (_isProcessing)
          clipsEditorConfigs.widgets.processingOverlay?.call(this, _progress) ??
              Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: clipsEditorConfigs.style.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: _progress),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      builder: (context, animatedProgress, _) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 16,
                          children: [
                            SizedBox(
                              width: 200,
                              child: LinearProgressIndicator(
                                value: animatedProgress,
                              ),
                            ),
                            Text(
                              '${i18n.clipsEditor.processingClips} '
                              '${(animatedProgress * 100).toInt()}%',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontFeatures: [
                                      const FontFeature.tabularFigures(),
                                    ],
                                  ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildAddButton() {
    final style = clipsEditorConfigs.style;

    return clipsEditorConfigs.widgets.addVideoClipButton?.call(
          this,
          _rebuildController.stream,
          addClip,
        ) ??
        Padding(
          padding: const EdgeInsetsGeometry.fromLTRB(16, 24, 16, 12),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: style.addClipsButtonColor,
              side: BorderSide(
                color: style.addClipsButtonBorderColor,
                width: style.addClipsButtonBorderWidth,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: style.addClipsButtonBackground,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            ),
            onPressed: addClip,
            child: Text(
              i18n.clipsEditor.addVideoClip,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        );
  }
}
