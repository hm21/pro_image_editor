import 'package:material_ui/material_ui.dart';

import '../utils/platform_info.dart';

/// A custom scrollbar wrapper that conditionally displays a [Scrollbar]
/// on desktop platforms only.
///
/// On mobile platforms, the [child] is returned directly without wrapping.
/// On desktop platforms, the [child] is wrapped in a [Scrollbar] that is
/// aligned at the top of the scrollable area.
///
/// This widget is useful when you want to provide a consistent scrollbar
/// experience for desktop users, while keeping the mobile UI clean.
///
/// Example:
/// ```dart
/// EditorScrollbar(
///   controller: scrollController,
///   child: ListView.builder(
///     controller: scrollController,
///     itemCount: 50,
///     itemBuilder: (_, index) => ListTile(title: Text('Item $index')),
///   ),
/// )
/// ```
class EditorScrollbar extends StatelessWidget {
  /// Creates an [EditorScrollbar].
  ///
  /// The [child] must not be null and should be a scrollable widget that
  /// uses the provided [controller].
  const EditorScrollbar({
    super.key,
    required this.child,
    required this.controller,
  });

  /// The widget that will be wrapped by the [Scrollbar] on desktop platforms.
  final Widget child;

  /// The scroll controller associated with the scrollable [child].
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    if (!isDesktop) return child;

    return Scrollbar(
      controller: controller,
      scrollbarOrientation: ScrollbarOrientation.top,
      child: child,
    );
  }
}
