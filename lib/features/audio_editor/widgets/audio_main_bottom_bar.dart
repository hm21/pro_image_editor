import 'package:flutter/material.dart';

import '/core/models/editor_callbacks/audio_editor_callbacks.dart';
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/shared/controllers/video_controller.dart';

/// A bottom navigation bar widget for the Audio Editor main screen.
class AudioMainBottomBar extends StatefulWidget {
  /// Creates an [AudioMainBottomBar] widget.
  const AudioMainBottomBar({
    super.key,
    required this.configs,
    required this.controller,
    required this.audioEditorCallbacks,
    required this.onSelectAudioTrack,
    required this.onConfirmChanges,
  });

  /// Configuration settings for the image and audio editor.
  ///
  /// Defines internationalization options, UI behavior, and general
  /// editor settings used by the Audio Editor.
  final ProImageEditorConfigs configs;

  /// The controller managing the state and playback of the current video or
  /// audio.
  final ProVideoController controller;

  /// A set of callbacks used for handling events within the Audio Editor.
  ///
  /// Provides hooks for integrating custom behavior when user interactions
  /// occur in the audio editing interface.
  final AudioEditorCallbacks? audioEditorCallbacks;

  /// Called when the user selects or wants to change the audio track.
  ///
  /// This callback is typically used to open a file picker or another
  /// interface for choosing an audio source.
  final VoidCallback onSelectAudioTrack;

  /// Called when the user confirms their audio editing changes.
  ///
  /// This callback can be used to save modifications or update
  /// the project state.
  final VoidCallback onConfirmChanges;

  @override
  State<AudioMainBottomBar> createState() => AudioMainBottomBarState();
}

/// State for [AudioMainBottomBar].
class AudioMainBottomBarState extends State<AudioMainBottomBar> {
  final double _balanced = 0.05;

  late final _audioTrack = widget.controller.audioTrack!;

  late final _configs = widget.configs.audioEditor;
  late final _i18n = widget.configs.i18n.audioEditor;
  late final _style = _configs.style;
  late final _customWidgets = _configs.widgets;

  String get _balanceLabel {
    if (_audioTrack.volumeBalance < -_balanced) {
      return _i18n.balanceLabelOriginal;
    } else if (_audioTrack.volumeBalance > _balanced) {
      return _i18n.balanceLabelOverlay;
    } else {
      return _i18n.balanceLabelBalanced;
    }
  }

  /// Updates the audio track start time.
  void updateStartTime(Duration startTime) {
    _audioTrack.startTime = startTime;
    setState(() {});
    widget.audioEditorCallbacks?.onStartTimeChange?.call(startTime);
  }

  /// Updates the balance between original and overlay audio.
  void updateBalance(double value) {
    assert(
      value >= -1 && value <= 1,
      'Balance value must be between -1.0 and 1.0, but got $value',
    );
    // Snap to center (balanced) when close to 0.0
    if ((value - 0.0).abs() < _balanced) {
      _audioTrack.volumeBalance = 0.0;
    } else {
      _audioTrack.volumeBalance = value;
    }
    widget.audioEditorCallbacks?.onBalanceChange?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final balanceSliderBackground = _style.balanceSliderBackground;

    return _customWidgets.editBottomBar?.call(
          this,
          widget.controller,
          updateStartTime,
          updateBalance,
          widget.onSelectAudioTrack,
          widget.onConfirmChanges,
        ) ??
        Container(
          decoration: BoxDecoration(
            color: _style.editSheetBackgroundColor,
            boxShadow: _style.editSheetShadow ??
                [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Audio balance slider with floating label
              if (_customWidgets.balanceChooser != null)
                _customWidgets.balanceChooser!(
                  this,
                  widget.controller,
                  updateBalance,
                )
              else if (_configs.enableEditBalance) ...[
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    padding: EdgeInsets.zero,
                    activeTrackColor: balanceSliderBackground,
                    inactiveTrackColor:
                        balanceSliderBackground.withValues(alpha: 0.3),
                    thumbColor: balanceSliderBackground,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 12),
                    trackHeight: 4,
                    valueIndicatorShape:
                        const PaddleSliderValueIndicatorShape(),
                    valueIndicatorColor: balanceSliderBackground,
                    valueIndicatorTextStyle: TextStyle(
                      color: _style.balanceSliderColor,
                      fontWeight: FontWeight.w500,
                    ),
                    showValueIndicator: ShowValueIndicator.onlyForContinuous,
                  ),
                  child: StatefulBuilder(builder: (_, setState) {
                    return Slider(
                      value: _audioTrack.volumeBalance,
                      min: -1.0,
                      max: 1.0,
                      label: _balanceLabel,
                      onChanged: (value) {
                        updateBalance(value);
                        setState(() {});
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
              ],
              // Audio waveform selector

              if (_customWidgets.startTimeSelector != null)
                _customWidgets.startTimeSelector!(
                  this,
                  widget.controller,
                  updateStartTime,
                )
              else if (_configs.enableEditStartTime &&
                  widget.audioEditorCallbacks?.onBuildWaveformSelector !=
                      null) ...[
                widget.audioEditorCallbacks!.onBuildWaveformSelector!(
                  widget.controller.audioTrack!,
                  widget.controller.videoDuration,
                  updateStartTime,
                ),
                const SizedBox(height: 32),
              ],

              // Action buttons
              Row(
                spacing: 12,
                children: [
                  _customWidgets.buttonEditTrack?.call(
                        this,
                        widget.onSelectAudioTrack,
                      ) ??
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onSelectAudioTrack,
                          label: Text(_i18n.editTrack),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _style.buttonEditTrackColor,
                            side:
                                BorderSide(color: _style.buttonEditTrackColor),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                _style.buttonEditTrackBorderRadius,
                              ),
                            ),
                          ),
                        ),
                      ),
                  _customWidgets.buttonConfirm?.call(
                        this,
                        widget.onConfirmChanges,
                      ) ??
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.onConfirmChanges,
                          label: Text(_i18n.confirmChanges),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _style.buttonConfirmBackground,
                            foregroundColor: _style.buttonConfirmColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                _style.buttonConfirmBorderRadius,
                              ),
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ],
          ),
        );
  }
}
