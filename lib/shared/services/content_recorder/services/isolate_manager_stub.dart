// Project imports:
import 'thread_fallback_manager.dart';

/// Stub implementation of [IsolateManager] for web/WASM platforms where
/// dart:isolate is not available. Falls back to single-threaded processing.
class IsolateManager extends ThreadFallbackManager {
  // ignore: public_member_api_docs
  IsolateManager(super.configs);
}
