import 'package:flutter/material.dart';

import 'fade_in_base.dart';

/// A widget that applies a fade-in animation combined with a slide-from-bottom
/// effect to its child.
class FadeInUp extends FadeInBase {
  /// Creates a [FadeInUp] animation widget.
  ///
  /// The [child] parameter is required, while [duration], [delay], and [offset]
  /// are optional with default values.
  const FadeInUp({
    super.key,
    required super.child,
    super.duration,
    super.delay,
    super.offset,
  });

  @override
  State<FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends FadeInBaseState<FadeInUp> {
  @override
  Offset buildInitialOffsetPosition() {
    return Offset(0, widget.offset / 100);
  }
}
