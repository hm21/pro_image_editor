// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'design_mode.dart';

/// Checks if the app is running on a desktop platform.
final isDesktop = !isWebMobile &&
    (kIsWeb || Platform.isMacOS || Platform.isWindows || Platform.isLinux);

final isWebMobile = kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);

final platformIsMaterialDesign = kIsWeb ||
    (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.macOS);

final ImageEditorDesignModeE platformDesignMode = platformIsMaterialDesign
    ? ImageEditorDesignModeE.material
    : ImageEditorDesignModeE.cupertino;
