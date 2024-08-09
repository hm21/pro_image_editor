// ignore_for_file: public_member_api_docs

part of 'defer_pointer.dart';

/// Holds a list of [DeferPointerRenderObject]s which the
/// [DeferredPointerHandler] widget uses to perform hit tests.
class DeferredPointerHandlerLink extends ChangeNotifier {
  DeferredPointerHandlerLink();
  final List<DeferPointerRenderObject> _painters = [];

  void descendantNeedsPaint() => notifyListeners();

  /// All painters currently attached to this link
  List<DeferPointerRenderObject> get painters =>
      UnmodifiableListView(_painters);

  /// Add a render object to the link. Does nothing if item already exists.
  void add(DeferPointerRenderObject value) {
    if (!_painters.contains(value)) {
      _painters.add(value);
      notifyListeners();
    }
  }

  /// Remove a render object from the link. Does nothing if item is not in list.
  void remove(DeferPointerRenderObject value) {
    if (_painters.contains(value)) {
      _painters.remove(value);
      notifyListeners();
    }
  }

  /// Clears all currently attached links
  void removeAll() {
    _painters.clear();
    notifyListeners();
  }
}
