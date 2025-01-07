// Package imports:
import 'dart:js_interop' as js;

import 'package:image/image.dart' as img;

import '../../../shared/services/content_recorder/managers/web_worker/web_utils.dart';
import '../editor_configs/image_generation_configs/output_formats.dart';
import 'thread_request_model.dart';

/// A class representing a web-based thread request for image processing.
///
/// This class extends [ThreadRequest] and includes additional options specific
/// to web-related operations, such as how the image bounds are generated and
/// the processing mode.
class ThreadWebRequest extends ThreadRequest {
  /// A factory constructor to create a [ThreadWebRequest] instance from a
  /// JavaScript object.
  ///
  /// This constructor converts a JavaScript [JSAny] object into a Dart
  /// [ThreadWebRequest] instance by extracting and parsing its properties.
  factory ThreadWebRequest.fromJs(js.JSAny? value) {
    var jsObj = value as js.JSObject;

    String? convertString(js.JSAny? value) {
      if (value == null) return null;
      return (value as js.JSString).toDart;
    }

    int? convertInteger(js.JSAny? value) {
      if (value == null) return null;
      return (value as js.JSNumber).toDartInt;
    }

    bool? convertBool(js.JSAny? value) {
      if (value == null) return null;
      return (value as js.JSBoolean).toDart;
    }

    img.Image parseImage(js.JSObject data) {
      final jsWidth = jsGetProperty(data, 'width');
      final jsHeight = jsGetProperty(data, 'height');
      final jsFrameDuration = jsGetProperty(data, 'frameDuration');
      final jsFrameIndex = jsGetProperty(data, 'frameIndex');
      final jsLoopCount = jsGetProperty(data, 'loopCount');
      final jsNumChannels = jsGetProperty(data, 'numChannels');
      final jsRowStride = jsGetProperty(data, 'rowStride');
      final jsFrameType = jsGetProperty(data, 'frameType');
      final jsFormat = jsGetProperty(data, 'format');
      final jsTextData = jsGetProperty(data, 'textData');

      String? frameType = convertString(jsFrameType);
      String? format = convertString(jsFormat);

      final jsBytes = jsGetProperty(data, 'buffer');
      final dartBytes = (jsBytes as js.JSArrayBuffer).toDart;

      final textData = jsTextData.dartify() as Map<String, String>?;

      return img.Image.fromBytes(
        bytes: dartBytes,
        width: convertInteger(jsWidth)!,
        height: convertInteger(jsHeight)!,
        textData: textData,
        frameDuration: convertInteger(jsFrameDuration) ?? 0,
        frameIndex: convertInteger(jsFrameIndex) ?? 0,
        loopCount: convertInteger(jsLoopCount) ?? 0,
        numChannels: convertInteger(jsNumChannels),
        rowStride: convertInteger(jsRowStride),
        frameType: frameType == null
            ? img.FrameType.sequence
            : img.FrameType.values.firstWhere((el) => el.name == frameType),
        format: format == null
            ? img.Format.uint8
            : img.Format.values.firstWhere((el) => el.name == format),
      );
    }

    img.JpegChroma getJpegChroma(String? value) {
      return value == null
          ? img.JpegChroma.yuv444
          : img.JpegChroma.values.firstWhere((el) => el.name == value);
    }

    img.PngFilter getPngFilter(String? value) {
      return value == null
          ? img.PngFilter.none
          : img.PngFilter.values.firstWhere((el) => el.name == value);
    }

    OutputFormat getOutputFormat(String? value) {
      return value == null
          ? OutputFormat.jpg
          : OutputFormat.values.firstWhere((el) => el.name == value);
    }

    int getJpgQuality(int? value) => value ?? 100;
    int getPngLevel(int? value) => value ?? 6;
    bool getSingleFrame(bool? value) => value ?? false;

    final jsId = jsGetProperty(jsObj, 'id');
    final jsMode = jsGetProperty(jsObj, 'mode');
    final jsGenerateOnlyImageBounds =
        jsGetProperty(jsObj, 'generateOnlyImageBounds');
    final jsJpegChroma = jsGetProperty(jsObj, 'jpegChroma');
    final jsJpegQuality = jsGetProperty(jsObj, 'jpegQuality');
    final jsPngFilter = jsGetProperty(jsObj, 'pngFilter');
    final jsPngLevel = jsGetProperty(jsObj, 'pngLevel');
    final jsSingleFrame = jsGetProperty(jsObj, 'singleFrame');
    final jsOutputFormat = jsGetProperty(jsObj, 'outputFormat');
    final jsImage = jsGetProperty(jsObj, 'image');

    return ThreadWebRequest(
      id: convertString(jsId)!,
      mode: convertString(jsMode) ?? 'encode',
      generateOnlyImageBounds: convertBool(jsGenerateOnlyImageBounds),
      jpegChroma: getJpegChroma(convertString(jsJpegChroma)),
      jpegQuality: getJpgQuality(convertInteger(jsJpegQuality)),
      pngFilter: getPngFilter(convertString(jsPngFilter)),
      pngLevel: getPngLevel(convertInteger(jsPngLevel)),
      singleFrame: getSingleFrame(convertBool(jsSingleFrame)),
      outputFormat: getOutputFormat(convertString(jsOutputFormat)),
      image: parseImage(jsImage as js.JSObject),
    );
  }

  /// Creates a new [ThreadWebRequest] instance.
  ///
  /// - [generateOnlyImageBounds]: If `true`, only the image bounds are
  ///   generated without performing full processing. This can be useful for
  ///   previews.
  /// - [mode]: Specifies the mode of the request, defining the type of
  ///   operation (e.g., rendering, exporting).
  /// - [id]: A unique identifier for the request.
  /// - [image]: The input image to be processed.
  /// - [outputFormat]: Specifies the desired output format of the image.
  ///   Common values include "png", "jpeg", etc.
  /// - [singleFrame]: If `true`, only a single frame of the image is processed,
  ///   commonly used for animated images or videos.
  /// - [pngLevel]: The compression level for PNG output. Valid values range
  ///   from 0 (no compression) to 9 (maximum compression).
  /// - [pngFilter]: Specifies the PNG filter type applied during compression.
  /// - [jpegQuality]: The quality level for JPEG output, ranging from 0 to 100,
  ///   where higher values represent better quality.
  /// - [jpegChroma]: Controls chroma subsampling for JPEG compression,
  ///   affecting color accuracy and file size.
  const ThreadWebRequest({
    required this.mode,
    required super.generateOnlyImageBounds,
    required super.id,
    required super.image,
    required super.outputFormat,
    required super.singleFrame,
    required super.pngLevel,
    required super.pngFilter,
    required super.jpegQuality,
    required super.jpegChroma,
  });

  /// The mode for the web thread request.
  @override
  final String mode;
}
