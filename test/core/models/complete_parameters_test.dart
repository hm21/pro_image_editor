import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/complete_parameters.dart';
import 'package:pro_image_editor/core/models/layers/layer.dart';

void main() {
  CompleteParameters buildParameters({required List<Layer> layers}) {
    return CompleteParameters(
      blur: 0,
      matrixFilterList: const [],
      matrixTuneAdjustmentsList: const [],
      startTime: null,
      endTime: null,
      cropWidth: null,
      cropHeight: null,
      rotateTurns: 0,
      cropX: null,
      cropY: null,
      flipX: false,
      flipY: false,
      image: Uint8List.fromList(const [1, 2, 3]),
      isTransformed: false,
      layers: layers,
      originalImageSize: const Size(100, 100),
      temporaryDecodedImageSize: const Size(100, 100),
      bodySize: const Size(100, 100),
      editorSize: const Size(100, 100),
    );
  }

  group('CompleteParameters id-based widget layer import', () {
    test(
      'fromMap without a widgetLoader fails for an id-based widget layer',
      () {
        final params = buildParameters(
          layers: [
            WidgetLayer(
              widget: const SizedBox(),
              exportConfigs: const WidgetLayerExportConfigs(
                id: 'x',
                meta: {'foo': 'bar'},
              ),
            ),
          ],
        );

        final map =
            json.decode(json.encode(params.toMap())) as Map<String, dynamic>;

        expect(() => CompleteParameters.fromMap(map), throwsAssertionError);
      },
    );

    test('fromMap with a widgetLoader rebuilds the id-based widget layer', () {
      String? loadedId;
      Map<String, dynamic>? loadedMeta;

      final params = buildParameters(
        layers: [
          WidgetLayer(
            widget: const SizedBox(),
            exportConfigs: const WidgetLayerExportConfigs(
              id: 'x',
              meta: {'foo': 'bar'},
            ),
          ),
        ],
      );

      final map =
          json.decode(json.encode(params.toMap())) as Map<String, dynamic>;

      const loaderWidget = SizedBox();
      final restored = CompleteParameters.fromMap(
        map,
        widgetLoader: (String id, {Map<String, dynamic>? meta}) {
          loadedId = id;
          loadedMeta = meta;
          return loaderWidget;
        },
      );

      expect(restored.layers, hasLength(1));
      final layer = restored.layers.first;
      expect(layer, isA<WidgetLayer>());
      expect((layer as WidgetLayer).widget, same(loaderWidget));
      expect(layer.exportConfigs.id, 'x');
      expect(loadedId, 'x');
      expect(loadedMeta, {'foo': 'bar'});
    });

    test(
      'fromMap deserializes identically with and without a loader when there '
      'are no widget layers',
      () {
        final params = buildParameters(
          layers: [
            Layer(offset: const Offset(5, 6), rotation: 0.25, scale: 1.5),
          ],
        );

        final map =
            json.decode(json.encode(params.toMap())) as Map<String, dynamic>;

        final withoutLoader = CompleteParameters.fromMap(map);
        final withLoader = CompleteParameters.fromMap(
          map,
          widgetLoader: (String id, {Map<String, dynamic>? meta}) =>
              const SizedBox(),
        );

        // The base `Layer` regenerates a random `id` on each import, so compare
        // the serialized form (which omits the id) to assert identical results.
        expect(withoutLoader.layers, hasLength(1));
        expect(withLoader.layers, hasLength(1));
        expect(
          withoutLoader.layers.first.toMap(),
          withLoader.layers.first.toMap(),
        );
        expect(withoutLoader.layers.first.offset, const Offset(5, 6));
      },
    );
  });
}
