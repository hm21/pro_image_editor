/// Configuration class for managing processor settings.
class ProcessorConfigs {
  /// The number of background processors to use.
  ///
  /// Must be a positive integer. Defaults to 2.
  ///
  /// Ignored if [processorMode] is [ProcessorMode.auto], [ProcessorMode.maximum], or [ProcessorMode.minimum].
  final int numberOfBackgroundProcessors;

  /// The maximum concurrency level.
  ///
  /// Must be a positive integer. Defaults to 1.
  ///
  /// Ignored if [processorMode] is [ProcessorMode.minimum] or if the platform is `Web`.
  final int maxConcurrency;

  /// The mode in which processors will operate.
  ///
  /// Defaults to [ProcessorMode.auto].
  final ProcessorMode processorMode;

  /// Creates a new instance of [ProcessorConfigs] with the given settings.
  ///
  /// The [numberOfBackgroundProcessors] must be a positive integer.
  /// The [maxBackgroundProcessors] must be greater than or equal to [numberOfBackgroundProcessors].
  /// The [maxConcurrency] must be a positive integer.
  /// The [processorMode] defaults to [ProcessorMode.auto].
  const ProcessorConfigs({
    this.numberOfBackgroundProcessors = 2,
    this.maxConcurrency = 1,
    this.processorMode = ProcessorMode.auto,
  })  : assert(numberOfBackgroundProcessors > 0,
            'minBackgroundProcessors must be positive'),
        assert(maxConcurrency > 0, 'maxConcurrency must be positive');
}

enum ProcessorMode {
  /// Automatically utilizes an optimal number of background processors.
  ///
  /// The [numberOfBackgroundProcessors] setting will be ignored.
  ///
  /// In Dart native, if there are too many tasks, it will destroy active tasks.
  ///
  /// In Dart web, it ignores [maxConcurrency] and may overload the processor if too many tasks are incoming.
  auto,

  /// Uses the specified [numberOfBackgroundProcessors].
  ///
  /// In Dart native, if the limit specified by [maxConcurrency] is reached, it will terminate all active processors
  /// and respawn them.
  ///
  /// In Dart web, it ignores [maxConcurrency] and may overload the processor if too many tasks are incoming.
  limit,

  /// Utilizes all available processors.
  ///
  /// Be cautious, as this can negatively affect performance.
  ///
  /// It ignores [maxConcurrency] and may overload the processor if too many tasks are incoming.
  maximum,

  /// Uses only one processor.
  ///
  /// It ignores [maxConcurrency] and may overload the processor if too many tasks are incoming.
  minimum,
}
