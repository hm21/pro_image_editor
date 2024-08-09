import 'package:flutter/widgets.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// A widget that provides a custom pop behavior when a pop action is invoked
/// and optionally returns a result.
class ExtendedPopScope<T> extends StatelessWidget {
  /// Creates an instance of [ExtendedPopScope].
  ///
  /// The [child] parameter is required and specifies the widget to be displayed
  /// within the pop scope. The other parameters are optional:
  const ExtendedPopScope({
    super.key,
    required this.child,
    this.canPop = true,
    this.onPopInvokedWithResult,
  });

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// {@template flutter.widgets.PopScope.onPopInvokedWithResult}
  /// Called after a route pop was handled.
  /// {@endtemplate}
  ///
  /// It's not possible to prevent the pop from happening at the time that this
  /// method is called; the pop has already happened. Use [canPop] to
  /// disable pops in advance.
  ///
  /// This will still be called even when the pop is canceled. A pop is canceled
  /// when the relevant [Route.popDisposition] returns false, such as when
  /// [canPop] is set to false on a [PopScope]. The `didPop` parameter
  /// indicates whether or not the back navigation actually happened
  /// successfully.
  ///
  /// The `result` contains the pop result.
  ///
  /// See also:
  ///
  ///  * [Route.onPopInvokedWithResult], which is similar.
  final PopInvokedWithResultCallback<T>? onPopInvokedWithResult;

  /// {@template flutter.widgets.PopScope.canPop}
  /// When false, blocks the current route from being popped.
  ///
  /// This includes the root route, where upon popping, the Flutter app would
  /// exit.
  ///
  /// If multiple [PopScope] widgets appear in a route's widget subtree, then
  /// each and every `canPop` must be `true` in order for the route to be
  /// able to pop.
  ///
  /// [Android's predictive back](https://developer.android.com/guide/navigation/predictive-back-gesture)
  /// feature will not animate when this boolean is false.
  /// {@endtemplate}
  final bool canPop;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: LoadingDialog.instance,
        builder: (_, __) {
          return PopScope<T>(
            canPop: canPop && !LoadingDialog.instance.hasActiveOverlay,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop &&
                  LoadingDialog.instance.hasActiveOverlay &&
                  LoadingDialog.instance.isDismissible) {
                LoadingDialog.instance.hide();
              }
              onPopInvokedWithResult?.call(didPop, result);
            },
            child: child,
          );
        });
  }
}
