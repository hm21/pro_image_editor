import 'package:flutter/foundation.dart';

import '/shared/services/import_export/constants/minified_keys.dart';

/// A service class responsible for minifying or preserving keys in data
/// structures, such as for history, layers, references, and other maps.
///
/// When [enableMinify] is true, the class converts verbose keys to minified
/// keys using pre-defined key maps. Otherwise, it keeps the original keys.
class EditorKeyMinifier {
  /// Creates an instance of [EditorKeyMinifier].
  ///
  /// If [enableMinify] is set to `true`, the minification process will be
  /// enabled.
  EditorKeyMinifier({required this.enableMinify});

  /// Indicates whether minification is enabled.
  final bool enableMinify;

  /// Converts a main key to its minified equivalent if [enableMinify] is
  ///  `true`.
  ///
  /// If the key does not have a corresponding minified key, the original key
  /// is returned.
  /// Throws an assertion error if the key is missing in [kMinifiedMainKeys].
  ///
  /// - [key]: The main key to be converted.
  /// - Returns: The minified key, or the original key if minification is
  /// disabled.
  String convertMainKey(String key) {
    if (!enableMinify) return key;

    String? value = kMinifiedMainKeys[key];
    assert(value != null, 'Minified key "$key" not found!');
    return value!;
  }

  /// Converts a size key to its minified equivalent if [enableMinify] is
  ///  `true`.
  String convertSizeKey(String key) {
    if (!enableMinify) return key;

    String? value = kMinifiedSizeKeys[key];
    assert(value != null, 'Minified key "$key" not found!');
    return value!;
  }

  /// Converts a history key to its minified equivalent if [enableMinify] is
  /// `true`.
  ///
  /// Similar to [convertMainKey], this converts keys used in the history data
  /// structure.
  String convertHistoryKey(String key) {
    if (!enableMinify) return key;

    String? value = kMinifiedHistoryKeys[key];
    assert(value != null, 'Minified key "$key" not found!');
    return value!;
  }

  /// Converts a paint key to its minified equivalent if [enableMinify] is
  /// `true`.
  ///
  /// The paint key maps keys in paint-related data to shorter representations.
  String convertPaintKey(String key) {
    if (!enableMinify) return key;

    String? value = kMinifiedPaintKeys[key];
    assert(value != null, 'Minified key "$key" not found!');
    return value!;
  }

  /// Converts a layer key to its minified equivalent if [enableMinify] is
  /// `true`.
  ///
  /// Layer keys are part of rendering configurations and transformations.
  String convertLayerKey(String key) {
    if (!enableMinify) return key;

    String? value = kMinifiedLayerKeys[key];
    assert(value != null, 'Minified key "$key" not found!');
    return value!;
  }

  /// Converts a layer interaction key to its minified equivalent if
  /// [enableMinify] is `true`.
  String convertLayerInteractionKey(String key) {
    if (!enableMinify) return key;

    String? value = kMinifiedLayerInteractionKeys[key];
    assert(value != null, 'Minified key "$key" not found!');
    return value!;
  }

  /// Converts the keys in a list of layer maps.
  ///
  /// This method transforms the keys in each map of the provided [layers] list.
  /// The conversion is based on [kMinifiedLayerKeys].
  ///
  /// - [layers]: A list of maps, each representing a layer.
  /// - Returns: A new list of maps with keys converted if minification is
  ///  enabled.
  List<Map<String, dynamic>> convertListOfLayerKeys(
    List<Map<String, dynamic>> layers,
  ) {
    if (!enableMinify) return layers;

    return layers.map((layer) {
      // For each layer, transform the key based on the kMinifiedLayerKeys map
      return Map<String, dynamic>.fromEntries(
        layer.entries.map((entry) {
          // Get the new key or keep the same key if not found
          final newKey = kMinifiedLayerKeys[entry.key] ?? entry.key;
          var value = entry.value;

          if (entry.key == 'interaction') {
            value = Map.from(entry.value).map(
              (itemKey, itemValue) =>
                  MapEntry(convertLayerInteractionKey(itemKey), itemValue),
            );
          }

          if (entry.key == 'item') {
            value = Map.from(entry.value).map(
              (itemKey, itemValue) =>
                  MapEntry(convertPaintKey(itemKey), itemValue),
            );
          }

          if (entry.key == 'items') {
            value = (entry.value as List)
                .map(
                  (el) => Map.from(el as Map).map(
                    (itemKey, itemValue) =>
                        MapEntry(convertPaintKey(itemKey), itemValue),
                  ),
                )
                .toList();
          }

          return MapEntry(newKey, value);
        }),
      );
    }).toList();
  }

  /// Converts the keys in the references map.
  ///
  /// This method recursively converts the keys within each reference map.
  /// If a key is `item`, it further applies paint key conversions.
  ///
  /// - [references]: A map containing reference data.
  /// - Returns: A new map with the reference keys converted.
  Map<String, dynamic> convertReferenceKeys(Map<String, dynamic> references) {
    if (!enableMinify) return references;

    return references.map((key, value) {
      return MapEntry(
        key,
        Map.from(value).map((entryKey, entryValue) {
          if (entryKey == 'interaction') {
            entryValue = Map.from(entryValue).map(
              (itemKey, itemValue) =>
                  MapEntry(convertLayerInteractionKey(itemKey), itemValue),
            );
          }

          if (entryKey == 'item') {
            entryValue = Map.from(entryValue).map(
              (itemKey, itemValue) =>
                  MapEntry(convertPaintKey(itemKey), itemValue),
            );
          }

          if (entryKey == 'items') {
            entryValue = (entryValue as List)
                .map(
                  (el) => Map.from(el as Map).map(
                    (itemKey, itemValue) =>
                        MapEntry(convertPaintKey(itemKey), itemValue),
                  ),
                )
                .toList();
          }

          return MapEntry(convertLayerKey(entryKey), entryValue);
        }),
      );
    });
  }

  /// Function to generate sequential alphabetical keys
  /// (A, B, ..., Z, AA, AB, ...)
  @visibleForTesting
  String generateAlphabeticalKey(int index) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    String key = '';
    while (index >= 0) {
      key = alphabet[index % 26] + key;
      index = (index ~/ 26) - 1;
    }
    return key;
  }

  /// Converts layer IDs in the provided history and reference maps.
  ///
  /// This method assigns unique alphabetical keys to each reference ID and
  /// updates any corresponding layer IDs in the history.
  ///
  /// - [history]: A list of maps representing the history of layers.
  /// - [references]: A map of references containing layer data.
  /// - Returns: A [ConvertLayerResponse] with updated history and references.
  ConvertLayerResponse convertLayerId(
    List<Map<String, dynamic>> history,
    Map<String, dynamic> references,
  ) {
    if (!enableMinify) {
      return ConvertLayerResponse(history: history, references: references);
    }

    int index = 0;
    Map<String, dynamic> updatedReferences = {};
    Map<String, String> idMapping = {}; // oldKey -> newKey

    /// Generate new keys without updating anything yet
    for (var oldKey in references.keys) {
      String newKey = generateAlphabeticalKey(index++);
      idMapping[oldKey] = newKey;
    }

    /// Create updated references with new keys
    for (var entry in references.entries) {
      String newKey = idMapping[entry.key]!;
      updatedReferences[newKey] = entry.value;
    }

    /// Update history with new ids
    List<Map<String, dynamic>> updatedHistory = history.map((historyEntry) {
      var layers = List<Map<String, dynamic>>.from(historyEntry['l'] ?? []);
      for (var layerMap in layers) {
        String? oldId = layerMap['id'];
        if (oldId != null && idMapping.containsKey(oldId)) {
          layerMap['id'] = idMapping[oldId];
        }
      }
      return {...historyEntry, 'l': layers};
    }).toList();

    references = updatedReferences;
    return ConvertLayerResponse(
      history: updatedHistory,
      references: updatedReferences,
    );
  }
}

/// A response object that contains the updated history and references after
/// key conversion.
class ConvertLayerResponse {
  /// Creates a new [ConvertLayerResponse].
  ///
  /// - [history]: The list of history layers.
  /// - [references]: The updated references map.
  ConvertLayerResponse({required this.history, required this.references});

  /// The updated history of layers.
  List<Map<String, dynamic>> history;

  /// The updated references map with converted keys.
  Map<String, dynamic> references;
}
