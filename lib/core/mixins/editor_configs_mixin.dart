// Flutter imports:
import 'package:flutter/material.dart';

import '../models/editor_callbacks/pro_image_editor_callbacks.dart';
import '../models/editor_configs/pro_image_editor_configs.dart';
import 'converted_configs.dart';

/// A mixin providing access to simple editor configurations.
mixin SimpleConfigsAccess on StatefulWidget {
  /// Returns the configuration options for the editor.
  ProImageEditorConfigs get configs;

  /// Returns the callbacks for the editor.
  ProImageEditorCallbacks get callbacks;
}

/// A mixin providing access to simple editor configurations within a state.
mixin SimpleConfigsAccessState<T extends StatefulWidget>
    on State<T>, ImageEditorConvertedConfigs {
  SimpleConfigsAccess get _widget => (widget as SimpleConfigsAccess);

  @override
  ProImageEditorConfigs get configs => _widget.configs;

  /// Returns the callbacks for the editor.
  ProImageEditorCallbacks get callbacks => _widget.callbacks;
}
