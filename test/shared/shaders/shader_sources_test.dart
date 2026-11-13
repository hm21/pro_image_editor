import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Flutter warns when a fragment shader samples a texture and has a `return`
/// in `main()`, since such shaders can fail to compile on Windows; see
/// https://github.com/flutter/flutter/issues/190809. This repeats the check
/// of Flutter's shader compiler for SDKs that do not run it yet.
void main() {
  final shaders = Directory('lib/shared/shaders')
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.frag'))
      .toList();

  test('finds the shaders', () {
    expect(shaders, isNotEmpty);
  });

  for (final shader in shaders) {
    test('${shader.uri.pathSegments.last} has no return in main()', () {
      final source = shader
          .readAsStringSync()
          .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
          .replaceAll(RegExp('//.*'), '');
      final start = RegExp(r'\bmain\s*\([^)]*\)\s*\{').firstMatch(source);
      expect(start, isNotNull);

      var end = start!.end;
      for (var depth = 1; depth > 0 && end < source.length; end++) {
        if (source[end] == '{') depth++;
        if (source[end] == '}') depth--;
      }
      final body = source.substring(start.end, end);

      expect(body, isNot(matches(RegExp(r'\breturn\b'))));
    });
  }
}
