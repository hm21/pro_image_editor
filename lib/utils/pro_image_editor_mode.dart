// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'design_mode.dart';

/// Checks if the app is running on a desktop platform.
final isDesktop = !isWebMobile &&
    (kIsWeb || Platform.isMacOS || Platform.isWindows || Platform.isLinux);

/// Checks if the current platform is a web mobile device.
final isWebMobile = kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);

/// Determines if the platform uses Material Design.
final platformIsMaterialDesign = kIsWeb ||
    (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.macOS);

/// Sets the design mode for the image editor based on the platform.
/// Uses Material Design for non-iOS/macOS platforms and Cupertino for iOS/macOS.
final ImageEditorDesignModeE platformDesignMode = platformIsMaterialDesign
    ? ImageEditorDesignModeE.material
    : ImageEditorDesignModeE.cupertino;
