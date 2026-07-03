import '/core/models/i18n/i18n_tune_editor.dart';
import '/core/models/icons/tune_editor_icons.dart';
import '/features/filter_editor/utils/filter_generator/filter_addons.dart';
import '../models/tune_adjustment_item.dart';

/// Preset list from tune adjustment
List<TuneAdjustmentItem> tunePresets({
  required TuneEditorIcons icons,
  required I18nTuneEditor i18n,
}) => [
  TuneAdjustmentItem(
    id: 'brightness',
    icon: icons.brightness,
    label: i18n.brightness,
    min: -0.5,
    max: 0.5,
    divisions: 200,
    labelMultiplier: 200,
    toMatrix: ColorFilterAddons.brightness,
  ),
  TuneAdjustmentItem(
    id: 'contrast',
    icon: icons.contrast,
    label: i18n.contrast,
    min: -0.5,
    max: 0.5,
    divisions: 200,
    labelMultiplier: 200,
    toMatrix: ColorFilterAddons.contrast,
  ),
  TuneAdjustmentItem(
    id: 'saturation',
    icon: icons.saturation,
    label: i18n.saturation,
    min: -0.5,
    max: .5,
    divisions: 200,
    labelMultiplier: 200,
    toMatrix: ColorFilterAddons.saturation,
  ),
  TuneAdjustmentItem(
    id: 'exposure',
    icon: icons.exposure,
    label: i18n.exposure,
    min: -1,
    max: 1,
    divisions: 200,
    toMatrix: ColorFilterAddons.exposure,
  ),
  TuneAdjustmentItem(
    id: 'hue',
    icon: icons.hue,
    label: i18n.hue,
    min: -0.25,
    max: .25,
    divisions: 400,
    labelMultiplier: 400,
    toMatrix: ColorFilterAddons.hue,
  ),
  TuneAdjustmentItem(
    id: 'temperature',
    icon: icons.temperature,
    label: i18n.temperature,
    min: -0.5,
    max: .5,
    divisions: 200,
    labelMultiplier: 200,
    toMatrix: ColorFilterAddons.temperature,
  ),
  TuneAdjustmentItem(
    id: 'tint',
    icon: icons.tint,
    label: i18n.tint,
    min: -0.5,
    max: .5,
    divisions: 200,
    labelMultiplier: 200,
    toMatrix: ColorFilterAddons.tint,
  ),
  TuneAdjustmentItem(
    id: 'fade',
    icon: icons.fade,
    label: i18n.fade,
    min: -1,
    max: 1,
    divisions: 200,
    toMatrix: ColorFilterAddons.fade,
  ),
];
