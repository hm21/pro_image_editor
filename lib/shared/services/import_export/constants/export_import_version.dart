/// Class containing version constants for export and import functionality.
class ExportImportVersion {
  /// The version string representing version `1.0.0` which is used in the
  /// editor version < `3.0.0`.
  static const version_1_0_0 = '1.0.0';

  /// The version string representing version `2.0.0` which is used in the
  /// editor version >= `3.0.0` && < `6.0.0`.
  static const version_2_0_0 = '2.0.0';

  /// The version string representing version `3.0.0` which is used in the
  /// editor version >= `6.0.0` && < `6.1.5`.
  static const version_3_0_0 = '3.0.0';

  /// The version string representing version `3.0.1` which is used in the
  /// editor version >= `6.1.5` && < `7.5.0`.
  static const version_3_0_1 = '3.0.1';

  /// The version string representing version `4.0.0` which is used in the
  /// editor version >= `7.5.0` && < `7.6.0`.
  static const version_4_0_0 = '4.0.0';

  /// The version string representing version `5.0.0` which is used in the
  /// editor version >= `7.6.0` && < `8.0.0`.
  static const version_5_0_0 = '5.0.0';

  /// The version string representing version `6.0.0` which is used in the
  /// editor version >= `8.0.0` && < `10.0.0`.
  static const version_6_0_0 = '6.0.0';

  /// The version string representing version `6.1.0` which is used in the
  /// editor version >= `10.0.0` && < `10.4.1`.
  static const version_6_1_0 = '6.1.0';

  /// The version string representing version `6.2.0` which is used in the
  /// editor version >= `10.4.1` && < `11.0.0`.
  static const version_6_2_0 = '6.2.0';

  /// The version string representing version `6.3.0` which is used in the
  /// editor version >= `11.0.0` && < `11.1.0`.
  static const version_6_3_0 = '6.3.0';

  /// The version string representing version `6.4.0` which is used in the
  /// editor version >= `11.1.0`.
  static const version_6_4_0 = '6.4.0';

  /// The version string representing version `6.5.0` which adds timeline
  /// fields (startTime, endTime, enter/exit duration & curve) to filters,
  /// tune adjustments and layers.
  static const version_6_5_0 = '6.5.0';

  /// Represents the latest version of the export/import functionality.
  static const latest = ExportImportVersion.version_6_5_0;
}

/// An extension on the `String` class that provides functionality
/// related to export and import version numbers.
extension ExportImportVersionNumber on String {
  /// Converts a version string in the format "major.minor.patch" into a single
  /// integer representation.
  int toVersionNumber() {
    try {
      final parts = split('.');
      assert(parts.length == 3, 'Version string must have 3 parts');

      final major = int.tryParse(parts[0]) ?? 0;
      final minor = int.tryParse(parts[1]) ?? 0;
      final patch = int.tryParse(parts[2]) ?? 0;

      return major * 1000000 + minor * 1000 + patch;
    } catch (_) {
      return 0;
    }
  }
}
