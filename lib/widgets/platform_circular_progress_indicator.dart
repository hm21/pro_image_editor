// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';

/// A circular progress indicator that adapts to the platform.
///
/// On web and non-iOS/macOS platforms, it displays a [CircularProgressIndicator].
/// On iOS and macOS, it displays a [CupertinoActivityIndicator].
class PlatformCircularProgressIndicator extends StatefulWidget {
  /// Creates a platform-aware circular progress indicator.
  const PlatformCircularProgressIndicator({
    super.key,
    required this.configs,
  });

  /// A class representing configuration options for the Image Editor.
  final ProImageEditorConfigs configs;

  @override
  State<PlatformCircularProgressIndicator> createState() =>
      _PlatformCircularProgressIndicatorState();
}

class _PlatformCircularProgressIndicatorState
    extends State<PlatformCircularProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    // Conditionally choose the progress indicator based on the platform.
    return widget.configs.customWidgets.circularProgressIndicator ??
        (widget.configs.designMode == ImageEditorDesignModeE.material
            ? const CircularProgressIndicator()
            : const CupertinoActivityIndicator());
  }
}
