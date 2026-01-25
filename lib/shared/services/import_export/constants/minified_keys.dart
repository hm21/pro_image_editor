/// A constant map containing minified main keys for import/export services.
const Map<String, String> kMinifiedMainKeys = {
  'lastRenderedImgSize': 'l',
  'imgSize': 'i',
  'history': 'h',
  'widgetRecords': 'w',
  'references': 'r',
  'position': 'p',
  'minify': 'm',
  'version': 'v',
};

/// A constant map containing minified size keys for import/export services.
const Map<String, String> kMinifiedSizeKeys = {
  'width': 'w',
  'height': 'h',
};

/// A constant map containing minified history keys for import/export services.
const Map<String, String> kMinifiedHistoryKeys = {
  'layers': 'l',
  'filters': 'f',
  'tune': 'a',
  'blur': 'b',
  'transform': 't',
};

/// A constant map containing minified layer keys for import/export services.
const Map<String, String> kMinifiedLayerKeys = {
  'x': 'x',
  'y': 'y',
  'rotation': 'r',
  'width': 'w',
  'scale': 's',
  'flipX': 'fx',
  'flipY': 'fy',
  'groupId': 'g',
  'type': 't',
  'emoji': 'e',
  'text': 'te',
  'item': 'i',
  'rawSize': 'rs',
  'opacity': 'o',
  'exportConfigs': 'ec',
  'recordPosition': 'rp',
  'colorMode': 'cm',
  'color': 'c',
  'background': 'b',
  'align': 'a',
  'fontScale': 'f',
  'customSecondaryColor': 'cs',
  'fontFamily': 'ff',
  'fontStyle': 'fs',
  'fontWeight': 'fw',
  'letterSpacing': 'ls',
  'height': 'h',
  'wordSpacing': 'ws',
  'decoration': 'd',
  'interaction': 'in',
  'meta': 'm',
  'boxConstraints': 'bx',
  'maxTextWidth': 'mt',
  'shadows': 'sh',

  /// Only in version < 8.0.0
  'enableInteraction': 'ei',
};

/// A constant map containing minified layer interaction keys for import/export
/// services.
const Map<String, String> kMinifiedLayerInteractionKeys = {
  'enableMove': 'm',
  'enableScale': 's',
  'enableRotate': 'r',
  'enableSelection': 't',
  'enableEdit': 'e',
};

/// A constant map containing minified paint-item keys for import/export
/// services.
const Map<String, String> kMinifiedPaintKeys = {
  'mode': 'm',
  'offsets': 'o',
  'erasedOffsets': 'eo',
  'color': 'c',
  'strokeWidth': 's',
  'opacity': 't',
  'fill': 'f',
};
