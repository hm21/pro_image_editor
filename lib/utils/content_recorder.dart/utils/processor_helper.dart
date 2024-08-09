// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';

/// Determines the number of processors to use based on the given [configs] and
/// the device's number of processors.
///
/// The number of processors is decided according to the `ProcessorMode`
/// specified in [configs]. This function adjusts the number of processors
/// based on the mode and the device's capabilities to balance performance and
/// resource utilization.
///
/// [configs] - The configuration settings for processors, including mode and
/// limits.
/// [deviceNumberOfProcessors] - The total number of processors available on the
/// device.
///
/// Returns the number of processors to use based on the configuration mode and
/// device capabilities.
int getNumberOfProcessors({
  required ProcessorConfigs configs,
  required int deviceNumberOfProcessors,
}) {
  switch (configs.processorMode) {
    case ProcessorMode.auto:
      // Automatically determine the number of processors to use based on
      //device capabilities.
      if (deviceNumberOfProcessors <= 4) {
        // For devices with 4 or fewer processors, use one less than the total
        // available.
        return deviceNumberOfProcessors - 1;
      } else if (deviceNumberOfProcessors <= 6) {
        // For devices with up to 6 processors, use a fixed number of 4
        // processors.
        return 4;
      } else if (deviceNumberOfProcessors <= 10) {
        // For devices with up to 10 processors, use a fixed number of 6
        // processors.
        return 6;
      } else {
        // For devices with more than 10 processors, use a fixed number of 8
        // processors.
        return 8;
      }
    case ProcessorMode.limit:
      // Use the number of processors specified in the configuration, limited
      //by user settings.
      return configs.numberOfBackgroundProcessors;
    case ProcessorMode.maximum:
      // Use all available processors except one for the main UI thread.
      return deviceNumberOfProcessors - 1;
    case ProcessorMode.minimum:
      // Use only one processor.
      return 1;
  }
}
