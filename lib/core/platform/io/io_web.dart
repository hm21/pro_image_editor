// ------------------------------------------------------------------
// THIS FILE WAS DERIVED FROM SOURCE CODE UNDER THE FOLLOWING LICENSE
// ------------------------------------------------------------------
//
// Copyright 2012, the Dart project authors. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above
//       copyright notice, this list of conditions and the following
//       disclaimer in the documentation and/or other materials provided
//       with the distribution.
//     * Neither the name of Google Inc. nor the names of its
//       contributors may be used to endorse or promote products derived
//       from this software without specific prior written permission.
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// ---------------------------------------------------------
// THIS, DERIVED FILE IS LICENSE UNDER THE FOLLOWING LICENSE
// ---------------------------------------------------------
// Copyright 2020 terrier989@gmail.com.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// A class representing a file with a given path.
class File {
  /// Creates a [File] instance with the given [path].
  File(this.path);

  /// The file path represented as a string.
  final String path;

  /// Write to the file path
  Future<void> writeAsString(String value) async {
    throw ArgumentError('This function is not supported on the web.');
  }

  /// Write bytes to the file
  Future<File> writeAsBytes(List<int> bytes) async {
    throw ArgumentError('This function is not supported on the web.');
  }

  /// Read bytes async
  Future<Uint8List> readAsBytes() async {
    throw ArgumentError('This function is not supported on the web.');
  }

  /// Read bytes sync
  String readAsStringSync() {
    throw ArgumentError('This function is not supported on the web.');
  }

  /// Delete the file
  Future<void> delete() async {
    throw ArgumentError('This function is not supported on the web.');
  }

  /// Delete the file sync
  Future<void> deleteSync() async {
    throw ArgumentError('This function is not supported on the web.');
  }
}

/// Information about the environment in which the current program is running.
///
/// Platform provides information such as the operating system,
/// the hostname of the computer, the value of environment variables,
/// the path to the running program,
/// and other global properties of the program being run.
class Platform {
  /// Whether the operating system is a version of
  /// [Linux](https://en.wikipedia.org/wiki/Linux).
  ///
  /// This value is `false` if the operating system is a specialized
  /// version of Linux that identifies itself by a different name,
  /// for example Android (see [isAndroid]).
  static final bool isLinux = (operatingSystem == 'linux');

  /// Whether the operating system is a version of
  /// [macOS](https://en.wikipedia.org/wiki/MacOS).
  static final bool isMacOS = (operatingSystem == 'macos');

  /// Whether the operating system is a version of
  /// [Microsoft Windows](https://en.wikipedia.org/wiki/Microsoft_Windows).
  static final bool isWindows = (operatingSystem == 'windows');

  /// Whether the operating system is a version of
  /// [Android](https://en.wikipedia.org/wiki/Android_%28operating_system%29).
  static final bool isAndroid = (operatingSystem == 'android');

  /// Whether the operating system is a version of
  /// [iOS](https://en.wikipedia.org/wiki/IOS).
  static final bool isIOS = (operatingSystem == 'ios');

  /// Whether the operating system is a version of
  /// [Fuchsia](https://en.wikipedia.org/wiki/Google_Fuchsia).
  static final bool isFuchsia = (operatingSystem == 'fuchsia');

  /// A string representing the operating system or platform.
  static String get operatingSystem {
    final s = web.window.navigator.userAgent.toLowerCase();
    if (s.contains('iphone') ||
        s.contains('ipad') ||
        s.contains('ipod') ||
        s.contains('watch os')) {
      return 'ios';
    }
    if (s.contains('mac os')) {
      return 'macos';
    }
    if (s.contains('fuchsia')) {
      return 'fuchsia';
    }
    if (s.contains('android')) {
      return 'android';
    }
    if (s.contains('linux') || s.contains('cros') || s.contains('chromebook')) {
      return 'linux';
    }
    if (s.contains('windows')) {
      return 'windows';
    }
    return '';
  }

  /// Retrieves the number of processors available on the device.
  static int get numberOfProcessors => web.window.navigator.hardwareConcurrency;
}

/// A reference to a directory (or _folder_) on the file system.
class Directory {
  /// Gets the path of this directory.
  String get path => '';

  /// System temporary directory
  static Directory get systemTemp {
    return Directory();
  }
}
