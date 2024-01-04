import 'dart:io';

import 'package:flutter/foundation.dart';

/// Checks if the app is running on a desktop platform.
final isDesktop = !isWebMobile &&
    (kIsWeb || Platform.isMacOS || Platform.isWindows || Platform.isLinux);

final isWebMobile = kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);
