import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/editor_configs/paint_editor/censor_configs.dart';
import 'package:pro_image_editor/shared/widgets/censor/censor_scope.dart';
import 'package:pro_image_editor/shared/widgets/censor/layer_space_pixelate_filter.dart';

void main() {
  group(LayerSpacePixelateGrid, () {
    test('scales the blocks with the transform and the pixel ratio', () {
      final grid = LayerSpacePixelateGrid.of(
        transform: Matrix4.identity()
          ..translateByDouble(40, 30, 0, 1)
          ..scaleByDouble(2, 2, 1, 1),
        layerBlockSize: 12,
        devicePixelRatio: 3,
      );

      expect(grid.blockSize, 72);
      expect(grid.origin, const Offset(120, 90));
    });

    test('keeps the block size of a rotated area', () {
      final grid = LayerSpacePixelateGrid.of(
        transform: Matrix4.rotationZ(math.pi / 4)..scaleByDouble(2, 2, 1, 1),
        layerBlockSize: 10,
        devicePixelRatio: 1,
      );

      expect(grid.blockSize, closeTo(20, 1e-9));
    });

    test('never shrinks a block below one device pixel', () {
      final grid = LayerSpacePixelateGrid.of(
        transform: Matrix4.diagonal3Values(0.01, 0.01, 1),
        layerBlockSize: 10,
        devicePixelRatio: 1,
      );

      expect(grid.blockSize, 1);
    });
  });

  group(LayerSpacePixelateArea, () {
    test('maps device pixels onto the unit square of the area', () {
      final toGlobal = Matrix4.identity()
        ..translateByDouble(10, 20, 0, 1)
        ..scaleByDouble(2, 2, 1, 1);
      final toDevice = Matrix4.diagonal3Values(3, 3, 1)..multiply(toGlobal);
      final area = LayerSpacePixelateArea.of(
        fromDevice: Matrix4.inverted(toDevice),
        size: const Size(40, 30),
        grid: LayerSpacePixelateGrid.of(
          transform: toGlobal,
          layerBlockSize: 6,
          devicePixelRatio: 3,
        ),
        isOval: false,
        deviceSize: const Size(1170, 2532),
        fitToWidth: true,
      );

      Offset unit(Offset device) {
        final m = area.toUnit;
        return Offset(
          m[0] * device.dx + m[1] * device.dy + m[2],
          m[3] * device.dx + m[4] * device.dy + m[5],
        );
      }

      expect(unit(const Offset(30, 60)), const Offset(0, 0));
      expect(unit(const Offset(270, 240)), const Offset(1, 1));
      expect(area.grid.origin, const Offset(30, 60));
      expect(area.grid.blockSize, 36);
    });
  });

  group(LayerSpacePixelateGroup, () {
    late List<_FakePass> passes;
    late bool canCreatePass;
    late LayerSpacePixelateGroup pixelateGroup;

    setUp(() {
      passes = [];
      canCreatePass = true;
      pixelateGroup = LayerSpacePixelateGroup(
        createPass: () {
          if (!canCreatePass) return null;
          return _FakePass()..addTo(passes);
        },
      );
    });

    tearDown(() => pixelateGroup.dispose());

    Widget area({
      Key? key,
      Offset offset = Offset.zero,
      Size size = const Size(40, 30),
    }) {
      return Positioned(
        key: key,
        left: offset.dx,
        top: offset.dy,
        width: size.width,
        height: size.height,
        child: LayerSpacePixelateFilter(
          group: pixelateGroup,
          blockSize: 6,
          devicePixelRatio: 1,
          deviceSize: const Size(800, 600),
          blendMode: BlendMode.srcOver,
          child: const SizedBox.expand(),
        ),
      );
    }

    Future<void> pumpAreas(
      WidgetTester tester,
      List<Widget> areas, {
      double scale = 1,
    }) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topLeft,
            child: Stack(children: areas),
          ),
        ),
      );
    }

    List<RenderLayerSpacePixelateFilter> renderAreas(WidgetTester tester) {
      return tester
          .renderObjectList<RenderLayerSpacePixelateFilter>(
            find.byType(LayerSpacePixelateFilter),
          )
          .toList();
    }

    BackdropFilterLayer? backdropOf(RenderLayerSpacePixelateFilter area) {
      return area.debugLayer?.firstChild as BackdropFilterLayer?;
    }

    testWidgets('shows every area of a pass with one filter under one key', (
      tester,
    ) async {
      await pumpAreas(tester, [
        area(offset: const Offset(0, 0)),
        area(offset: const Offset(50, 0)),
        area(offset: const Offset(100, 0)),
      ]);

      final pass = passes.single;
      expect(pass.areas, hasLength(3));
      for (final renderArea in renderAreas(tester)) {
        expect(renderArea.passKey, same(pass.key));
        expect(renderArea.passFilter, same(pass.filter));
        expect(backdropOf(renderArea)!.filter, same(pass.filter));
        expect(backdropOf(renderArea)!.backdropKey, same(pass.key));
      }
    });

    testWidgets('splits more areas than a pass holds into further passes', (
      tester,
    ) async {
      const count = LayerSpacePixelateGroup.maxAreasPerPass + 8;
      await pumpAreas(tester, [
        for (var i = 0; i < count; i++) area(offset: Offset(i * 10.0, 0)),
      ]);

      expect(pixelateGroup.passCount, 2);
      expect(
        passes[0].areas,
        hasLength(LayerSpacePixelateGroup.maxAreasPerPass),
      );
      expect(passes[1].areas, hasLength(8));
      final keys = pixelateGroup.passMembers.map((a) => a.passKey).toList();
      expect(
        keys.take(LayerSpacePixelateGroup.maxAreasPerPass),
        everyElement(same(passes[0].key)),
      );
      expect(
        keys.skip(LayerSpacePixelateGroup.maxAreasPerPass),
        everyElement(same(passes[1].key)),
      );
    });

    testWidgets('passes the areas in the order they paint', (tester) async {
      Widget sized(String key, double width) =>
          area(key: ValueKey(key), size: Size(width, 30));

      await pumpAreas(tester, [sized('a', 10), sized('b', 20), sized('c', 30)]);
      expect(pixelateGroup.passMembers.map((a) => a.size.width), [10, 20, 30]);

      await pumpAreas(tester, [sized('c', 30), sized('a', 10), sized('b', 20)]);
      expect(pixelateGroup.passMembers.map((a) => a.size.width), [30, 10, 20]);
    });

    testWidgets('gives every area the new filter when one of them moves', (
      tester,
    ) async {
      await pumpAreas(tester, [
        area(key: const ValueKey('a')),
        area(key: const ValueKey('b'), offset: const Offset(50, 0)),
      ]);
      final before = passes.single.filter;

      await pumpAreas(tester, [
        area(key: const ValueKey('a'), offset: const Offset(5, 5)),
        area(key: const ValueKey('b'), offset: const Offset(50, 0)),
      ]);

      final after = passes.single.filter;
      expect(after, isNot(same(before)));
      for (final renderArea in renderAreas(tester)) {
        expect(renderArea.passFilter, same(after));
        expect(backdropOf(renderArea)!.filter, same(after));
      }
    });

    testWidgets('follows a parent transform the areas do not repaint for', (
      tester,
    ) async {
      await pumpAreas(tester, [area()]);
      expect(passes.single.areas.single.grid.blockSize, 6);

      await pumpAreas(tester, [area()], scale: 2);

      expect(passes.single.areas.single.grid.blockSize, 12);
      final renderArea = renderAreas(tester).single;
      expect(backdropOf(renderArea)!.filter, same(passes.single.filter));
    });

    testWidgets('leaves an area without size out of the passes', (
      tester,
    ) async {
      await pumpAreas(tester, [
        area(key: const ValueKey('a')),
        area(key: const ValueKey('empty'), size: Size.zero),
        area(key: const ValueKey('b'), offset: const Offset(50, 0)),
      ]);

      expect(passes.single.areas, hasLength(2));
      final empty = tester.renderObject<RenderLayerSpacePixelateFilter>(
        find.descendant(
          of: find.byKey(const ValueKey('empty')),
          matching: find.byType(LayerSpacePixelateFilter),
        ),
      );
      expect(empty.passKey, isNull);
    });

    testWidgets('shows the areas once a pass can be created', (tester) async {
      canCreatePass = false;
      await pumpAreas(tester, [area(), area(offset: const Offset(50, 0))]);
      expect(passes, isEmpty);
      expect(renderAreas(tester).map(backdropOf), everyElement(isNull));

      canCreatePass = true;
      // As the shader finishing its load would.
      tester.binding.scheduleFrame();
      await tester.pump();
      await tester.pump();

      final pass = passes.single;
      for (final renderArea in renderAreas(tester)) {
        expect(backdropOf(renderArea)!.filter, same(pass.filter));
        expect(backdropOf(renderArea)!.backdropKey, same(pass.key));
      }
    });

    testWidgets('releases its passes once the last area leaves', (
      tester,
    ) async {
      await pumpAreas(tester, [area(), area(offset: const Offset(50, 0))]);
      final pass = passes.single;

      await pumpAreas(tester, []);
      await tester.pump();

      expect(pixelateGroup.passCount, 0);
      expect(pass.disposed, isTrue);
    });
  });

  group(CensorScope, () {
    testWidgets('gives each scope backdrop keys of its own', (tester) async {
      late CensorScopeData first;
      late CensorScopeData second;
      late CensorScopeData outside;
      await tester.pumpWidget(
        Column(
          children: [
            CensorScope(
              child: Builder(
                builder: (context) {
                  first = CensorScope.of(context);
                  return const SizedBox();
                },
              ),
            ),
            CensorScope(
              child: Builder(
                builder: (context) {
                  second = CensorScope.of(context);
                  return const SizedBox();
                },
              ),
            ),
            Builder(
              builder: (context) {
                outside = CensorScope.of(context);
                return const SizedBox();
              },
            ),
          ],
        ),
      );

      expect(first.blurKey, isNot(same(second.blurKey)));
      expect(first.pixelateKey, isNot(same(second.pixelateKey)));
      expect(first.pixelateGroup, isNot(same(second.pixelateGroup)));
      expect(first.blurKey, isNot(same(first.pixelateKey)));
      expect(outside, same(CensorScopeData.unscoped));
    });
  });

  group(CensorConfigs, () {
    test('pixelates in screen space unless asked otherwise', () {
      const configs = CensorConfigs();

      expect(configs.pixelateInLayerSpace, isFalse);
      expect(
        configs.copyWith(pixelateInLayerSpace: true).pixelateInLayerSpace,
        isTrue,
      );
    });
  });
}

class _FakePass implements LayerSpacePixelatePass {
  @override
  final BackdropKey key = BackdropKey();

  @override
  late ui.ImageFilter filter;

  List<LayerSpacePixelateArea> areas = const [];
  bool disposed = false;
  static int _writes = 0;

  void addTo(List<_FakePass> passes) => passes.add(this);

  @override
  void write(List<LayerSpacePixelateArea> areas) {
    this.areas = areas;
    // A filter unlike any before, as a shader with new uniforms would be.
    filter = ui.ImageFilter.blur(sigmaX: (++_writes).toDouble());
  }

  @override
  void dispose() => disposed = true;
}
