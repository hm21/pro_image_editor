import 'package:flutter/material.dart';

import 'fade_in_base.dart';

/// A widget that applies a fade-in animation combined with a slide-from-left
/// effect to its child.
class FadeInLeft extends FadeInBase {
  /// Creates a [FadeInLeft] animation widget.
  ///
  /// The [child] parameter is required, while [duration], [delay], and [offset]
  /// are optional with default values.
  const FadeInLeft({
    super.key,
    required super.child,
    super.duration,
    super.delay,
    super.offset,
  });

  @override
  State<FadeInLeft> createState() => _FadeInLeftState();
}

class _FadeInLeftState extends FadeInBaseState<FadeInLeft> {
  @override
  Offset buildInitialOffsetPosition() {
    return Offset(widget.offset / 100, 0);
  }
}
