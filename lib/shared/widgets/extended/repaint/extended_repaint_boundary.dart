import 'package:flutter/widgets.dart';

import 'extended_render_repaint_boundary.dart';

/// A widget that creates a separate display list for its child.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=cVAGLDuc2xE}
///
/// This widget creates a separate display list for its child, which
/// can improve performance if the subtree repaints at different times than
/// the surrounding parts of the tree.
///
/// This is useful since [RenderObject.paint] may be triggered even if its
/// associated [Widget] instances did not change or rebuild. A [RenderObject]
/// will repaint whenever any [RenderObject] that shares the same [Layer] is
/// marked as being dirty and needing paint (see [RenderObject.markNeedsPaint]),
/// such as when an ancestor scrolls or when an ancestor or descendant animates.
///
/// Containing [RenderObject.paint] to parts of the render subtree that are
/// actually visually changing using [ExtendedRepaintBoundary] explicitly or
/// implicitly
/// is therefore critical to minimizing redundant work and improving the app's
/// performance.
///
/// When a [RenderObject] is flagged as needing to paint via
/// [RenderObject.markNeedsPaint], the nearest ancestor [RenderObject] with
/// [RenderObject.isRepaintBoundary], up to possibly the root of the
///  application,
/// is requested to repaint. That nearest ancestor's [RenderObject.paint] method
/// will cause _all_ of its descendant [RenderObject]s to repaint in the same
/// layer.
///
/// [ExtendedRepaintBoundary] is therefore used, both while propagating the
/// `markNeedsPaint` flag up the render tree and while traversing down the
/// render tree via [PaintingContext.paintChild], to strategically contain
/// repaints to the render subtree that visually changed for performance. This
/// is done because the [ExtendedRepaintBoundary] widget creates a
/// [RenderObject] that
/// always has a [Layer], decoupling ancestor render objects from the descendant
/// render objects.
///
/// [ExtendedRepaintBoundary] has the further side-effect of possibly hinting
/// to the
/// engine that it should further optimize animation performance if the render
/// subtree behind the [ExtendedRepaintBoundary] is sufficiently complex and
/// is static
/// while the surrounding tree changes frequently. In those cases, the engine
/// may choose to pay a one time cost of rasterized and caching the pixel
/// values of the subtree for faster future GPU re-rendering speed.
///
/// Several framework widgets insert [ExtendedRepaintBoundary] widgets to mark
/// natural
/// separation points in applications. For instance, contents in Material Design
/// drawers typically don't change while the drawer opens and closes, so
/// repaints are automatically contained to regions inside or outside the drawer
/// when using the [Drawer] widget during transitions.
///
/// See also:
///
///  * [debugRepaintRainbowEnabled], a debugging flag to help visually monitor
///    render tree repaints in a running app.
///  * [debugProfilePaintsEnabled], a debugging flag to show render tree
///    repaints in the observatory's timeline view.
class ExtendedRepaintBoundary extends SingleChildRenderObjectWidget {
  /// Creates a widget that isolates repaints.
  const ExtendedRepaintBoundary({super.key, super.child});

  /// Wraps the given child in a [ExtendedRepaintBoundary].
  ///
  /// The key for the [ExtendedRepaintBoundary] is derived either from the
  /// child's key
  /// (if the child has a non-null key) or from the given `childIndex`.
  ExtendedRepaintBoundary.wrap(Widget child, int childIndex)
      : super(key: ValueKey<Object>(child.key ?? childIndex), child: child);

  /// Wraps each of the given children in [ExtendedRepaintBoundary]s.
  ///
  /// The key for each [ExtendedRepaintBoundary] is derived either from the
  /// wrapped
  /// child's key (if the wrapped child has a non-null key) or from the wrapped
  /// child's index in the list.
  static List<ExtendedRepaintBoundary> wrapAll(List<Widget> widgets) =>
      <ExtendedRepaintBoundary>[
        for (int i = 0; i < widgets.length; ++i)
          ExtendedRepaintBoundary.wrap(widgets[i], i),
      ];

  @override
  ExtendedRenderRepaintBoundary createRenderObject(BuildContext context) =>
      ExtendedRenderRepaintBoundary();
}
