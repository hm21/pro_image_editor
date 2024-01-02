import 'dart:io';

import 'package:flutter/foundation.dart';

/// Checks if the app is running on a desktop platform.
bool get isDesktop => kIsWeb || Platform.isMacOS || Platform.isWindows || Platform.isLinux;
