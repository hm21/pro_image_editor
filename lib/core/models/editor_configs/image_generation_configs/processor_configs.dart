/// Configuration class for managing processor settings.
class ProcessorConfigs {
  /// Creates a new instance of [ProcessorConfigs] with the given settings.
  ///
  /// The [numberOfBackgroundProcessors] must be a positive integer.
  /// The [maxBackgroundProcessors] must be greater than or equal to
  /// [numberOfBackgroundProcessors].
  /// The [maxConcurrency] must be a positive integer.
  /// The [processorMode] defaults to [ProcessorMode.auto].
  const ProcessorConfigs({
    this.numberOfBackgroundProcessors = 2,
    this.maxConcurrency = 1,
    this.processorMode = ProcessorMode.auto,
  })  : assert(numberOfBackgroundProcessors > 0,
            'minBackgroundProcessors must be positive'),
        assert(maxConcurrency > 0, 'maxConcurrency must be positive');

  /// The number of background processors to use.
  ///
  /// Must be a positive integer. Defaults to 2.
  ///
  /// Ignored if [processorMode] is [ProcessorMode.auto],
  /// [ProcessorMode.maximum], or [ProcessorMode.minimum].
  final int numberOfBackgroundProcessors;

  /// The maximum concurrency level.
  ///
  /// Must be a positive integer. Defaults to 1.
  ///
  /// Ignored if [processorMode] is [ProcessorMode.minimum].
  final int maxConcurrency;

  /// The mode in which processors will operate.
  ///
  /// Defaults to [ProcessorMode.auto].
  final ProcessorMode processorMode;

  /// Creates a copy of this object with the given fields replaced with the
  /// new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [ProcessorConfigs] with some properties updated while keeping the others
  /// unchanged.
  ProcessorConfigs copyWith({
    int? numberOfBackgroundProcessors,
    int? maxConcurrency,
    ProcessorMode? processorMode,
  }) {
    return ProcessorConfigs(
      numberOfBackgroundProcessors:
          numberOfBackgroundProcessors ?? this.numberOfBackgroundProcessors,
      maxConcurrency: maxConcurrency ?? this.maxConcurrency,
      processorMode: processorMode ?? this.processorMode,
    );
  }
}

/// An enumeration representing the mode of processor utilization.
///
/// This enum defines the different modes for utilizing processors during
/// task execution, allowing for control over the number of background
/// processors used.
enum ProcessorMode {
  /// Automatically utilizes an optimal number of background processors.
  ///
  /// The [numberOfBackgroundProcessors] setting will be ignored.
  ///
  /// If the limit specified by [maxConcurrency] is reached, it will terminate
  /// all active tasks and create new one.
  auto,

  /// Uses the specified [numberOfBackgroundProcessors].
  ///
  /// If the limit specified by [maxConcurrency] is reached, it will terminate
  /// all active tasks and create new one.
  limit,

  /// Utilizes all available processors.
  ///
  /// Be cautious, as this can negatively affect performance.
  ///
  /// It ignores [maxConcurrency] and may overload the processor if too many
  /// tasks are incoming.
  maximum,

  /// Uses only one processor.
  ///
  /// It ignores [maxConcurrency] and may overload the processor if too many
  /// tasks are incoming.
  minimum,
}
