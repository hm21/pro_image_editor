// Project imports:
import '../import_export/import_state_history.dart';

/// A class representing configuration settings for managing state history.
///
/// This class provides options for configuring the history of states within an
/// image editor, including the maximum number of history entries and the
/// initial state history.
class StateHistoryConfigs {
  /// Creates an instance of [StateHistoryConfigs].
  /// - The `stateHistoryLimit` is the limit how many entries the history can
  ///   contain.
  /// - The `initStateHistory` holds the initial state history of the Image
  ///   Editor.
  const StateHistoryConfigs({
    this.stateHistoryLimit = 1000,
    this.initStateHistory,
  }) : assert(stateHistoryLimit > 0, 'stateHistoryLimit must be positive');

  /// The maximum number of states that can be stored in the history.
  ///
  /// **Note:** Setting a very high value for [stateHistoryLimit] can
  /// potentially overload the system's RAM. This is because each state stored
  /// in the history consumes memory, and if the number of states is
  /// excessively high, it can lead to memory exhaustion and eventually cause
  /// the application to crash.
  ///
  /// For example, the list that stores the history from screenshots as
  /// `Uint8List`.
  /// Each `Uint8List` object can represent a substantial amount of
  /// binary data. If the history limit is set too high, the cumulative memory
  /// usage of all these screenshots can quickly add up, leading to an
  /// out-of-memory error.
  ///
  /// The exact amount of RAM consumed depends on the size of each `Uint8List`
  /// and the value of [stateHistoryLimit]. For instance, if each screenshot is
  /// 1 MB in size, and [stateHistoryLimit] is set to 10,000, the total memory
  /// usage for the history alone would be approximately 10 GB (10,000 * 1 MB).
  /// Such high memory usage can easily exhaust the available RAM on some
  /// systems.
  ///
  /// It is advisable to set [stateHistoryLimit] to a reasonable value that
  /// balances the need for historical data with the available system resources.
  ///
  /// Example:
  /// ```dart
  /// // Setting a reasonable history limit to prevent RAM overload.
  /// final int stateHistoryLimit = 100;
  /// ```
  final int stateHistoryLimit;

  /// Holds the initial state history of the Image Editor.
  final ImportStateHistory? initStateHistory;

  /// Creates a copy of this `StateHistoryConfigs` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [StateHistoryConfigs] with some properties updated while keeping the
  /// others unchanged.
  StateHistoryConfigs copyWith({
    int? stateHistoryLimit,
    ImportStateHistory? initStateHistory,
  }) {
    return StateHistoryConfigs(
      stateHistoryLimit: stateHistoryLimit ?? this.stateHistoryLimit,
      initStateHistory: initStateHistory ?? this.initStateHistory,
    );
  }
}
