import 'package:material_ui/material_ui.dart';

/// Skin tone config Config
class SkinToneConfig {
  /// Constructor
  const SkinToneConfig({
    this.enabled = true,
    this.dialogBackgroundColor = Colors.white,
    this.indicatorColor = Colors.grey,
  });

  /// Enable feature to select a skin tone of certain emoji's
  final bool enabled;

  /// The background color of the skin tone dialog
  final Color dialogBackgroundColor;

  /// Color of the small triangle next to multiple skin tone emoji
  final Color indicatorColor;

  @override
  bool operator ==(other) {
    return (other is SkinToneConfig) &&
        other.enabled == enabled &&
        other.dialogBackgroundColor == dialogBackgroundColor &&
        other.indicatorColor == indicatorColor;
  }

  @override
  int get hashCode =>
      enabled.hashCode ^
      dialogBackgroundColor.hashCode ^
      indicatorColor.hashCode;
}
