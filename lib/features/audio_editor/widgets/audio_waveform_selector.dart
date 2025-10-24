import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';

/// Displays and allows selection of an audio waveform segment.
class AudioWaveformSelector extends StatefulWidget {
  /// Creates an [AudioWaveformSelector].
  const AudioWaveformSelector({
    super.key,
    required this.configs,
    required this.audioTrack,
    required this.videoDuration,
    this.amplitudes,
    this.onStartTimeChanged,
  });

  /// Editor configuration settings.
  final ProImageEditorConfigs configs;

  /// The audio track to visualize.
  final AudioTrack audioTrack;

  /// The total duration of the video.
  final Duration videoDuration;

  /// Optional precomputed waveform amplitudes.
  final List<double>? amplitudes;

  /// Called when the start time changes.
  final ValueChanged<Duration>? onStartTimeChanged;

  @override
  State<AudioWaveformSelector> createState() => _AudioWaveformSelectorState();
}

class _AudioWaveformSelectorState extends State<AudioWaveformSelector> {
  late final _style = widget.configs.audioEditor.style;

  late ScrollController _scrollController;
  final _rebuildController = StreamController.broadcast();
  int _currentStartTime = 0;
  final List<double> _amplitudes = [];

  late final double _waveformHeight = _style.startTimeWaveMaxHeight;
  late final double _waveItemWidth = _style.startTimeWaveItemWidth;
  late final double _waveItemSpacing = _style.startTimeWaveItemSpacing;
  late final double _totalItemWidth = _waveItemWidth + _waveItemSpacing;

  final double _outsideHorizontalPadding = 18;
  late final double _borderWidth = _style.startTimeSelectorSelectionBorderWidth;

  double _lastScreenWidth = 0;
  int _audioTrackItems = 0;

  @override
  void initState() {
    super.initState();
    _currentStartTime =
        (widget.audioTrack.startTime ?? Duration.zero).inMilliseconds;
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _rebuildController.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AudioWaveformSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioTrack != widget.audioTrack && _lastScreenWidth != 0) {
      _generateAmplitudes(_lastScreenWidth);
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    _rebuildController.add(null);
    super.setState(fn);
  }

  void _generateAmplitudes(double selectionWidth) {
    _lastScreenWidth = selectionWidth;

    _amplitudes.clear();

    if (widget.amplitudes != null) {
      _amplitudes.addAll(widget.amplitudes!);
    } else {
      // TODO: Extract real audio waveform data from the audio file
      // This should analyze the audio track and generate amplitude values
      // representing the actual sound levels at each time interval.
      // Consider using FFT or audio processing libraries to get frequency/amplitude data.
      // For now, generating random amplitudes as placeholder.
      final random = Random();
      final videoDuration = widget.videoDuration.inMilliseconds;
      final audioDuration = widget.audioTrack.duration.inMilliseconds;

      final double itemWidth = _waveItemWidth + _waveItemSpacing;

      final videoDurationItemCount = (selectionWidth / itemWidth).ceil();
      _audioTrackItems =
          (videoDurationItemCount * videoDuration / audioDuration).ceil();

      _amplitudes
        /* ..addAll(
          List.generate(videoDurationItemCount, (index) => 0),
        ) */
        ..addAll(
          List.generate(_audioTrackItems, (index) => random.nextDouble()),
        )
        ..addAll(
          List.generate(videoDurationItemCount, (index) => 0),
        );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {});
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0.0);
      }
    });
  }

  int _offsetToTime(double offset) {
    if (_amplitudes.isEmpty) return 0;

    final maxScrollExtent = _audioTrackItems * _totalItemWidth;
    final progress = offset / maxScrollExtent;

    final int audioDuration = widget.audioTrack.duration.inMilliseconds;

    final currentTimeInTimeline = (progress * audioDuration).round();

    return currentTimeInTimeline.clamp(0, audioDuration);
  }

  String _formatTime(double seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).floor().toString().padLeft(2, '0');
    final milliseconds =
        ((seconds % 1) * 100).floor().toString().padLeft(2, '0');

    return '$minutes:$remainingSeconds:$milliseconds';
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final offset = _scrollController.offset;
      final newTime = _offsetToTime(offset).toInt();

      if (newTime != _currentStartTime) {
        setState(() {
          _currentStartTime =
              newTime.clamp(0, widget.audioTrack.duration.inMilliseconds);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = widget.configs.theme ?? Theme.of(context);
    final Color backgroundColor = _style.startTimeSelectorBackground;

    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
            BorderRadius.circular(_style.startTimeSelectorBorderRadius),
        border: Border.all(
          color: _style.startTimeSelectorBorderColor,
          width: _style.startTimeSelectorBorderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with time display
          widget.configs.audioEditor.widgets.startTimeDisplay?.call(
                _rebuildController.stream,
                _currentStartTime,
              ) ??
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: _outsideHorizontalPadding,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _style.startTimeSelectorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _formatTime(_currentStartTime / 1000),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _style.startTimeSelectorColor,
                    fontWeight: FontWeight.w600,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
              ),

          // Waveform area
          Stack(
            children: [
              /// Scrollable waveform
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification) {
                    _onScroll();
                  } else if (notification is ScrollEndNotification) {
                    _onScroll();
                    widget.onStartTimeChanged?.call(
                      Duration(milliseconds: _currentStartTime),
                    );
                  }
                  return false;
                },
                child: SizedBox(
                  height: _waveformHeight + _borderWidth * 4,
                  child: ListView.builder(
                    clipBehavior: Clip.hardEdge,
                    itemCount: _amplitudes.length,
                    padding: EdgeInsets.symmetric(
                        horizontal: _outsideHorizontalPadding),
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (_, index) {
                      final amplitude = _amplitudes[index];
                      final double height = max(
                        4.0,
                        _waveformHeight * amplitude,
                      );
                      return Align(
                        alignment: Alignment.center,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(right: _waveItemSpacing),
                          width: _waveItemWidth,
                          height: height,
                          decoration: BoxDecoration(
                            color: _style.startTimeSelectorWaveColor,
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              /// Outside shadow left
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                width: _outsideHorizontalPadding,
                child: ColoredBox(
                  color: backgroundColor.withAlpha(220),
                ),
              ),

              /// Outside shadow right
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                width: _outsideHorizontalPadding,
                child: ColoredBox(
                  color: backgroundColor.withAlpha(220),
                ),
              ),

              // Selection area indicator
              Positioned(
                left: _outsideHorizontalPadding,
                right: _outsideHorizontalPadding,
                top: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: LayoutBuilder(builder: (_, constraints) {
                    if (_lastScreenWidth != constraints.maxWidth) {
                      _generateAmplitudes(constraints.maxWidth);
                    }
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _style.startTimeSelectorSelectionBorderColor,
                          width: _borderWidth,
                        ),
                        borderRadius: BorderRadius.circular(
                          _style.startTimeSelectorSelectionBorderRadius,
                        ),
                        color: _style.startTimeSelectorSelectionBorderColor
                            .withValues(alpha: 0.1),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
