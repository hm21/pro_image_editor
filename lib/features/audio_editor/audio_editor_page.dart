import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/core/mixins/converted_configs.dart';
import '/core/mixins/editor_configs_mixin.dart';
import '/core/models/editor_callbacks/pro_image_editor_callbacks.dart';
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/shared/widgets/extended/extended_pop_scope.dart';
import '/shared/widgets/reactive_widgets/reactive_custom_appbar.dart';
import 'models/audio_editor_response.dart';
import 'widgets/audio_editor_app_bar.dart';
import 'widgets/audio_track_list_tile.dart';

/// Page that allows the user to browse and select audio tracks for the editor.
class AudioEditorPage extends StatefulWidget with SimpleConfigsAccess {
  /// Constructs a `AudioEditorPage` widget.
  const AudioEditorPage({
    super.key,
    this.configs = const ProImageEditorConfigs(),
    this.callbacks = const ProImageEditorCallbacks(),
    required this.theme,
    required this.videoDuration,
    this.initialSelectedTrack,
  });

  @override
  final ProImageEditorConfigs configs;

  @override
  final ProImageEditorCallbacks callbacks;

  /// Theme that should be applied to the audio editor page.
  final ThemeData theme;

  /// The duration from the video.
  final Duration videoDuration;

  /// Initial selection audio track.
  final AudioTrack? initialSelectedTrack;

  @override
  createState() => AudioEditorPageState();
}

/// State responsible for rendering and managing the audio editor page.
class AudioEditorPageState extends State<AudioEditorPage>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  /// Helper stream to rebuild widgets.
  late final StreamController<void> _rebuildController;

  /// Tracks available in the current audio editor configuration.
  late final List<AudioTrack> _audioTracks = audioEditorConfigs.audioTracks;

  /// Notifier that keeps track of the currently selected audio track.
  final _selectedTrackNotifier = ValueNotifier<AudioTrack?>(null);

  double _pageFadeOpacity = 0.0;
  final Duration _pageFadeDuration = const Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();
    _rebuildController = StreamController.broadcast();
    if (widget.initialSelectedTrack != null) {
      selectTrack(widget.initialSelectedTrack!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _pageFadeOpacity = 1;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _selectedTrackNotifier.dispose();
    _rebuildController.close();
    super.dispose();
  }

  /// Handles tap on an audio track.
  Future<void> selectTrack(AudioTrack track) async {
    if (_selectedTrackNotifier.value == track) {
      return stopTrack(track);
    }

    _selectedTrackNotifier.value = track;

    assert(
      callbacks.audioEditorCallbacks?.onPlay != null,
      'In order to play music with the audio player of your choice, the '
      '`onPlay` callback inside `audioEditorCallbacks` is required.',
    );
    await callbacks.audioEditorCallbacks!.onPlay!(track);
    _rebuildController.add(null);
  }

  /// Updates the current playback start time.
  Future<void> updateStartTime(Duration startTime) async {
    if (_selectedTrackNotifier.value == null) return;
    _selectedTrackNotifier.value!.startTime = startTime;
    await callbacks.audioEditorCallbacks!.onStartTimeChange!(startTime);
  }

  /// Stops playback for the given [track] and clears the selection.
  Future<void> stopTrack(AudioTrack? track) async {
    _selectedTrackNotifier.value = null;

    assert(
      callbacks.audioEditorCallbacks?.onStop != null,
      'In order to play music with the audio player of your choice, the '
      '`onPlay` callback inside `audioEditorCallbacks` is required.',
    );
    await callbacks.audioEditorCallbacks!.onStop!(track);
    _rebuildController.add(null);
  }

  /// Closes the editor without returning a selected track.
  Future<void> close() async {
    if (_pageFadeOpacity != 1) return;
    await _animatedPageLeave();

    await stopTrack(_selectedTrackNotifier.value);
    if (mounted) Navigator.pop(context);

    callbacks.audioEditorCallbacks?.onCloseEditor?.call();
  }

  /// Closes the editor and returns the currently selected track.
  Future<void> done() async {
    if (_pageFadeOpacity != 1) return;
    await _animatedPageLeave();
    final track = _selectedTrackNotifier.value;
    await stopTrack(track);
    if (mounted) {
      Navigator.pop(
        context,
        AudioEditorResponse(track: track),
      );
    }

    callbacks.audioEditorCallbacks?.onDone?.call();
  }

  Future<void> _animatedPageLeave() async {
    _pageFadeOpacity = 0;
    setState(() {});
    await Future.delayed(_pageFadeDuration);
  }

  @override
  Widget build(BuildContext context) {
    final safeArea = audioEditorConfigs.safeArea;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: audioEditorConfigs.style.uiOverlayStyle,
      child: ExtendedPopScope(
        canPop: audioEditorConfigs.enableGesturePop,
        child: Theme(
          data: widget.theme.copyWith(
            tooltipTheme: widget.theme.tooltipTheme.copyWith(preferBelow: true),
          ),
          child: SafeArea(
            top: safeArea.top,
            bottom: safeArea.bottom,
            left: safeArea.left,
            right: safeArea.right,
            child: LayoutBuilder(builder: (context, constraints) {
              return Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: audioEditorConfigs.style.background,
                appBar: _buildAppBar(constraints),
                body: _buildBody(),
                bottomNavigationBar: audioEditorConfigs.widgets.bottomBar
                    ?.call(this, _rebuildController.stream),
              );
            }),
          ),
        ),
      ),
    );
  }

  /// Builds the audio editor app bar.
  PreferredSizeWidget? _buildAppBar(BoxConstraints constraints) {
    if (audioEditorConfigs.widgets.appBar != null) {
      return audioEditorConfigs.widgets.appBar!(
        this,
        _rebuildController.stream,
      );
    }

    return ReactiveAppbar(
      builder: (context) => AudioEditorAppBar(
        configs: audioEditorConfigs,
        i18n: i18n.audioEditor,
        onClose: close,
        onDone: done,
      ),
      stream: _rebuildController.stream,
    );
  }

  /// Builds the list of audio tracks and the blur background.
  Widget _buildBody() {
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
            child: ValueListenableBuilder(
                valueListenable: _selectedTrackNotifier,
                builder: (_, selectedTrack, __) {
                  return ListView.builder(
                    reverse: audioEditorConfigs.style.reversedTrackList,
                    padding: audioEditorConfigs.style.bodyPadding,
                    itemCount: _audioTracks.length,
                    itemBuilder: (context, index) {
                      final audioTrack = _audioTracks[index];

                      return AudioTrackListTile(
                        isSelected: audioTrack == selectedTrack,
                        videoDuration: widget.videoDuration,
                        audioTrack: audioTrack,
                        configs: configs,
                        onTap: () => selectTrack(
                          audioTrack,
                        ),
                      );
                    },
                  );
                }),
          ),
        ),
        ...(audioEditorConfigs.widgets.bodyItems?.call(
              this,
              _rebuildController.stream,
            ) ??
            []),
      ],
    );
  }
}
