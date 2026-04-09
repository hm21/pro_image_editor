// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '/shared/utils/timeline_progress.dart';
import '../../tune_editor/models/tune_adjustment_matrix.dart';
import '../constants/identity_matrix_constant.dart';
import '../types/filter_matrix.dart';
import '../types/filter_state.dart';
import '../utils/combine_color_matrix_utils.dart';
import '../utils/lerp_color_matrix_utils.dart';

/// A widget for applying color filters to its child widget.
class ColorFilterGenerator extends StatefulWidget {
  /// Constructor for creating an instance of ColorFilterGenerator.
  const ColorFilterGenerator({
    super.key,
    required this.filters,
    required this.tuneAdjustments,
    required this.child,
    this.filterStates,
    this.playTimeNotifier,
    this.defaultEnterCurve = Curves.easeIn,
    this.defaultExitCurve = Curves.easeOut,
  });

  /// The matrix of filters to apply.
  final FilterMatrix filters;

  /// The matrix of tune adjustments to apply.
  final List<TuneAdjustmentMatrix> tuneAdjustments;

  /// The child widget to which the filters are applied.
  final Widget child;

  /// Optional timeline-aware filter states for the video editor.
  ///
  /// When provided together with [playTimeNotifier], each [FilterState] is
  /// evaluated against the current video position and lerped with the identity
  /// matrix during enter/exit transitions.
  final List<FilterState>? filterStates;

  /// Notifier that provides the current video playback position.
  ///
  /// When `null`, timeline fields on [filterStates] and [tuneAdjustments] are
  /// ignored and all matrices are applied unconditionally.
  final ValueNotifier<Duration>? playTimeNotifier;

  /// Default enter curve used when a [FilterState] or [TuneAdjustmentMatrix]
  /// does not specify its own.
  final Curve defaultEnterCurve;

  /// Default exit curve used when a [FilterState] or [TuneAdjustmentMatrix]
  /// does not specify its own.
  final Curve defaultExitCurve;

  /// Creates the state for the ColorFilterGenerator widget.
  @override
  State<ColorFilterGenerator> createState() => ColorFilterGeneratorState();
}

/// The state class for the `ColorFilterGenerator` widget.
///
/// This class is responsible for managing the state of the
/// `ColorFilterGenerator` widget, which includes handling the generation and
/// application of color filters.
///
/// It extends the `State` class, which means it holds mutable state for the
/// `ColorFilterGenerator` widget.
class ColorFilterGeneratorState extends State<ColorFilterGenerator> {
  late List<double> _combinedMatrix;

  @override
  void initState() {
    super.initState();
    _recomputeMatrix();
    widget.playTimeNotifier?.addListener(_onTimeChanged);
  }

  @override
  void didUpdateWidget(covariant ColorFilterGenerator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.playTimeNotifier != widget.playTimeNotifier) {
      oldWidget.playTimeNotifier?.removeListener(_onTimeChanged);
      widget.playTimeNotifier?.addListener(_onTimeChanged);
    }

    if (oldWidget.filters.hashCode != widget.filters.hashCode ||
        oldWidget.tuneAdjustments.hashCode != widget.tuneAdjustments.hashCode) {
      _recomputeMatrix();
    }
  }

  @override
  void dispose() {
    widget.playTimeNotifier?.removeListener(_onTimeChanged);
    super.dispose();
  }

  void _onTimeChanged() {
    _recomputeMatrix();
    setState(() {});
  }

  /// Refreshes the filter editor by generating the filtered widget and
  /// updating the state.
  void refresh() {
    _recomputeMatrix();
    setState(() {});
  }

  void _recomputeMatrix() {
    final playTime = widget.playTimeNotifier?.value;
    final filterStates = widget.filterStates;
    final hasTimeline = playTime != null && filterStates != null;

    final List<List<double>> effectiveFilters;
    final List<List<double>> effectiveTunes;

    if (hasTimeline) {
      effectiveFilters = _resolveFilterStates(filterStates, playTime);
      effectiveTunes = _resolveTuneAdjustments(
        widget.tuneAdjustments,
        playTime,
      );
    } else {
      effectiveFilters = widget.filters;
      effectiveTunes = widget.tuneAdjustments
          .map((item) => item.matrix)
          .toList();
    }

    _combinedMatrix = mergeColorMatrices(
      filterList: effectiveFilters,
      tuneAdjustmentList: effectiveTunes,
    );
  }

  List<List<double>> _resolveFilterStates(
    List<FilterState> states,
    Duration playTime,
  ) {
    final result = <List<double>>[];
    for (final fs in states) {
      final progress = computeTimelineProgress(
        currentTime: playTime,
        startTime: fs.startTime,
        endTime: fs.endTime,
        enterDuration: fs.enterDuration,
        exitDuration: fs.exitDuration,
        defaultEnterCurve: widget.defaultEnterCurve,
        defaultExitCurve: widget.defaultExitCurve,
        enterCurve: fs.enterCurve,
        exitCurve: fs.exitCurve,
      );
      if (progress <= 0.0) continue;
      for (final matrix in fs.matrices) {
        if (progress >= 1.0) {
          result.add(matrix);
        } else {
          result.add(lerpColorMatrix(identityMatrix, matrix, progress));
        }
      }
    }
    return result;
  }

  List<List<double>> _resolveTuneAdjustments(
    List<TuneAdjustmentMatrix> tunes,
    Duration playTime,
  ) {
    final result = <List<double>>[];
    for (final tune in tunes) {
      final progress = computeTimelineProgress(
        currentTime: playTime,
        startTime: tune.startTime,
        endTime: tune.endTime,
        enterDuration: tune.enterDuration,
        exitDuration: tune.exitDuration,
        defaultEnterCurve: widget.defaultEnterCurve,
        defaultExitCurve: widget.defaultExitCurve,
        enterCurve: tune.enterCurve,
        exitCurve: tune.exitCurve,
      );
      if (progress <= 0.0) continue;
      if (progress >= 1.0) {
        result.add(tune.matrix);
      } else {
        result.add(lerpColorMatrix(identityMatrix, tune.matrix, progress));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.matrix(_combinedMatrix),
      child: widget.child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties
      ..add(DiagnosticsProperty<FilterMatrix>('filters', widget.filters))
      ..add(
        IterableProperty<TuneAdjustmentMatrix>(
          'tuneAdjustments',
          widget.tuneAdjustments,
        ),
      )
      ..add(
        DiagnosticsProperty<List<double>>('combinedMatrix', _combinedMatrix),
      );
  }
}
