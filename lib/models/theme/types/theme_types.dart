// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';

/// Creates custom [BoxConstraints] to use when displaying
/// editors in modal bottom sheets.
typedef EditorBoxConstraintsBuilder = BoxConstraints? Function(
  BuildContext context,
  ProImageEditorConfigs configs,
);
