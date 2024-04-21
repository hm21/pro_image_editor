import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import 'converted_configs.dart';

/// A mixin providing access to simple editor configurations.
mixin SimpleConfigsAccess on StatefulWidget {
  /// Returns the configuration options for the editor.
  ProImageEditorConfigs get configs;
}

/// A mixin providing access to simple editor configurations within a state.
mixin SimpleConfigsAccessState<T extends StatefulWidget>
    on State<T>, ImageEditorConvertedConfigs {
  SimpleConfigsAccess get _widget => (widget as SimpleConfigsAccess);

  @override
  ProImageEditorConfigs get configs => _widget.configs;
}
