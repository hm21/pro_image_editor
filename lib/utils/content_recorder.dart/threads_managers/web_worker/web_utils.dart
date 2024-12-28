import 'dart:js_interop';
import 'dart:typed_data';

/// Returns Dart representation from JS Object.
dynamic dartify(dynamic object) {
  // Convert JSObject to Dart equivalents directly
  // Cannot be done with Dart 3.2 constraints
  // ignore: invalid_runtime_check_with_js_interop_types
  if (object is! JSObject) {
    return object;
  }

  final jsObject = object;

  // Convert nested structures
  final dartObject = jsObject.dartify();
  return convertNested(dartObject);
}

/// Convert nested objects
dynamic convertNested(dynamic object) {
  if (object is ByteBuffer) {
    return object;
  } else if (object is List) {
    return object.map(convertNested).toList();
  } else if (object is Map) {
    var map = <dynamic, dynamic>{};
    object.forEach((key, value) {
      map[key] = convertNested(value);
    });
    return map;
  } else {
    // For non-nested types, attempt to convert directly
    return dartify(object);
  }
}

/// Returns the JS implementation from Dart Object.
JSAny? jsify(Object? dartObject) {
  if (dartObject == null) {
    return dartObject?.jsify();
  }

  if (dartObject is List) {
    return dartObject.map(jsify).toList().toJS;
  }

  if (dartObject is Map) {
    return dartObject
        .map((key, value) => MapEntry(jsify(key), jsify(value)))
        .jsify();
  }

  if (dartObject is JSAny Function()) {
    return dartObject.toJS;
  }

  return dartObject.jsify();
}
