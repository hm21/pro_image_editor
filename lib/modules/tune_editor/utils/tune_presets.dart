import 'package:pro_image_editor/models/i18n/i18n_tune_editor.dart';
import 'package:pro_image_editor/models/icons/icons_tune_editor.dart';

import '../../../models/tune_editor/tune_adjustment_item.dart';
import '../../filter_editor/utils/filter_generator/filter_addons.dart';

/// Preset list from tune adjustment
List<TuneAdjustmentItem> tunePresets({
  required IconsTuneEditor icons,
  required I18nTuneEditor i18n,
}) =>
    [
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
        toMatrix: (value) {
          double r = value > 0 ? 1 : 1 + value;
          double b = value < 0 ? 1 : 1 - value;
          return ColorFilterAddons.rgbScale(r, 1, b);
        },
      ),
      TuneAdjustmentItem(
        id: 'sharpness',
        icon: icons.sharpness,
        label: i18n.sharpness,
        min: 0,
        max: 1,
        divisions: 100,
        toMatrix: ColorFilterAddons.sharpness,
      ),
      TuneAdjustmentItem(
        id: 'luminance',
        icon: icons.luminance,
        label: i18n.luminance,
        min: -1,
        max: 1,
        divisions: 200,
        toMatrix: ColorFilterAddons.luminance,
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
