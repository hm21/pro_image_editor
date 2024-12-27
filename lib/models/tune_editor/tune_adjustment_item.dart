import 'package:flutter/material.dart';

/// A class representing an adjustable tune item in the editor.
///
/// Each [TuneAdjustmentItem] contains properties like a label, icon, range
/// (min, max), and a function to convert the adjustment value to a matrix
/// transformation.
class TuneAdjustmentItem {
  /// Creates a [TuneAdjustmentItem] with required parameters for adjustment.
  ///
  /// - [label] is the display text for the adjustment item.
  /// - [icon] is the icon representing the adjustment item.
  /// - [id] is the unique identifier for the adjustment item.
  /// - [min] defines the minimum value of the adjustment range.
  /// - [max] defines the maximum value of the adjustment range.
  /// - [toMatrix] is a function that takes the adjustment value and converts
  ///   it to a matrix transformation.
  /// - [divisions] defines how many discrete divisions are available for
  ///   adjustments within the range, defaulting to 200.
  /// - [labelMultiplier] is a multiplier applied to the label when
  ///   displaying the adjustment value, defaulting to 100.
  const TuneAdjustmentItem({
    required this.label,
    required this.icon,
    required this.id,
    required this.min,
    required this.max,
    required this.toMatrix,
    this.divisions = 200,
    this.labelMultiplier = 100,
  });

  /// The display label for the adjustment item.
  final String label;

  /// The icon representing the adjustment item.
  final IconData icon;

  /// The unique identifier for the adjustment item.
  final String id;

  /// The minimum value of the adjustment range.
  final double min;

  /// The maximum value of the adjustment range.
  final double max;

  /// A multiplier applied to the label when displaying the adjustment value.
  final double labelMultiplier;

  /// The number of discrete divisions available for adjustment within the
  /// range.
  final int divisions;

  /// A function that converts the adjustment value to a matrix transformation.
  final List<double> Function(double value) toMatrix;

  /// Creates a copy of this [TuneAdjustmentItem] object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [TuneAdjustmentItem] with some properties updated while keeping the
  /// others unchanged.
  ///
  /// - [label] updates the display label.
  /// - [icon] updates the icon for the adjustment.
  /// - [id] updates the unique identifier for the adjustment.
  /// - [min] and [max] update the range for the adjustment.
  /// - [labelMultiplier] updates the multiplier applied to the label when
  ///   displaying the value.
  /// - [divisions] updates the number of divisions within the adjustment range.
  /// - [toMatrix] updates the function used to convert the value to a matrix.
  TuneAdjustmentItem copyWith({
    String? label,
    IconData? icon,
    String? id,
    double? min,
    double? max,
    double? labelMultiplier,
    double? value,
    int? divisions,
    List<double> Function(double value)? toMatrix,
  }) {
    return TuneAdjustmentItem(
      label: label ?? this.label,
      icon: icon ?? this.icon,
      id: id ?? this.id,
      min: min ?? this.min,
      max: max ?? this.max,
      labelMultiplier: labelMultiplier ?? this.labelMultiplier,
      divisions: divisions ?? this.divisions,
      toMatrix: toMatrix ?? this.toMatrix,
    );
  }
}
