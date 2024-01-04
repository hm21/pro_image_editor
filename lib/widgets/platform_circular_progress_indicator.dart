import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/design_mode.dart';

/// A circular progress indicator that adapts to the platform.
///
/// On web and non-iOS/macOS platforms, it displays a [CircularProgressIndicator].
/// On iOS and macOS, it displays a [CupertinoActivityIndicator].
class PlatformCircularProgressIndicator extends StatefulWidget {
  /// The design mode of the editor.
  final ImageEditorDesignModeE designMode;

  /// Creates a platform-aware circular progress indicator.
  const PlatformCircularProgressIndicator({
    super.key,
    required this.designMode,
  });

  @override
  State<PlatformCircularProgressIndicator> createState() =>
      _PlatformCircularProgressIndicatorState();
}

class _PlatformCircularProgressIndicatorState
    extends State<PlatformCircularProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    // Conditionally choose the progress indicator based on the platform.
    return widget.designMode == ImageEditorDesignModeE.material
        ? const CircularProgressIndicator()
        : const CupertinoActivityIndicator();
  }
}
