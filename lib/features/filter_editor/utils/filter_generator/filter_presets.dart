// Project imports:
import 'color_filter_step.dart';
import 'filter_model.dart';

/// Preset filters that can be used directly
class PresetFilters {
  /// NoFilter: No filter
  static FilterModel none = const FilterModel(name: 'No Filter', filters: []);

  /// Clarendon: adds light to lighter areas and dark to darker areas
  static FilterModel clarendon = FilterModel.fromSteps(
    name: 'Clarendon',
    steps: [
      ColorFilterStep.brightness(.1),
      ColorFilterStep.contrast(.1),
      ColorFilterStep.saturation(.15),
    ],
  );

  /// Increase red color gradient
  static FilterModel addictiveRed = FilterModel.fromSteps(
    name: 'AddictiveRed',
    steps: [ColorFilterStep.addictiveColor(50, 0, 0)],
  );

  /// Increase blue color gradient
  static FilterModel addictiveBlue = FilterModel.fromSteps(
    name: 'AddictiveBlue',
    steps: [ColorFilterStep.addictiveColor(0, 0, 50)],
  );

  /// Gingham: Vintage-inspired, taking some color out
  static FilterModel gingham = FilterModel.fromSteps(
    name: 'Gingham',
    steps: [ColorFilterStep.sepia(.04), ColorFilterStep.contrast(-.15)],
  );

  /// Moon: B/W, increase brightness and decrease contrast
  static FilterModel moon = FilterModel.fromSteps(
    name: 'Moon',
    steps: [
      ColorFilterStep.grayscale(),
      ColorFilterStep.contrast(-.04),
      ColorFilterStep.brightness(0.1),
    ],
  );

  /// Lark: Brightens and intensifies colours but not red hues
  static FilterModel lark = FilterModel.fromSteps(
    name: 'Lark',
    steps: [
      ColorFilterStep.brightness(0.08),
      ColorFilterStep.grayscale(),
      ColorFilterStep.contrast(-.04),
    ],
  );

  /// Reyes: a vintage filter, gives your photos a “dusty” look
  static FilterModel reyes = FilterModel.fromSteps(
    name: 'Reyes',
    steps: [
      ColorFilterStep.sepia(0.4),
      ColorFilterStep.brightness(0.13),
      ColorFilterStep.contrast(-.05),
    ],
  );

  /// Juno: Brightens colors, and intensifies red and yellow hues
  static FilterModel juno = FilterModel.fromSteps(
    name: 'Juno',
    steps: [
      ColorFilterStep.rgbScale(1.01, 1.04, 1),
      ColorFilterStep.saturation(0.3),
    ],
  );

  /// Slumber: Desaturates the image as well as adds haze for a retro, dreamy
  /// look – with an emphasis on blacks and blues
  static FilterModel slumber = FilterModel.fromSteps(
    name: 'Slumber',
    steps: [ColorFilterStep.brightness(.1), ColorFilterStep.saturation(-0.5)],
  );

  /// Crema: Adds a creamy look that both warms and cools the image
  static FilterModel crema = FilterModel.fromSteps(
    name: 'Crema',
    steps: [
      ColorFilterStep.rgbScale(1.04, 1, 1.02),
      ColorFilterStep.saturation(-0.05),
    ],
  );

  /// Ludwig: A slight hint of desaturation that also enhances light
  static FilterModel ludwig = FilterModel.fromSteps(
    name: 'Ludwig',
    steps: [ColorFilterStep.brightness(.05), ColorFilterStep.saturation(-0.03)],
  );

  /// Aden: This filter gives a blue/pink natural look
  static FilterModel aden = FilterModel.fromSteps(
    name: 'Aden',
    steps: [
      ColorFilterStep.colorOverlay(228, 130, 225, 0.13),
      ColorFilterStep.saturation(-0.2),
    ],
  );

  /// Perpetua: Adding a pastel look, this filter is ideal for portraits
  static FilterModel perpetua = FilterModel.fromSteps(
    name: 'Perpetua',
    steps: [ColorFilterStep.rgbScale(1.05, 1.1, 1)],
  );

  /// Amaro: Adds light to an image, with the focus on the centre
  static FilterModel amaro = FilterModel.fromSteps(
    name: 'Amaro',
    steps: [ColorFilterStep.saturation(0.3), ColorFilterStep.brightness(0.15)],
  );

  /// Mayfair: Applies a warm pink tone, subtle vignetting to brighten the
  /// photograph center and a thin black border
  static FilterModel mayfair = FilterModel.fromSteps(
    name: 'Mayfair',
    steps: [
      ColorFilterStep.colorOverlay(230, 115, 108, 0.05),
      ColorFilterStep.saturation(0.15),
    ],
  );

  /// Rise: Adds a "glow" to the image, with softer lighting of the subject
  static FilterModel rise = FilterModel.fromSteps(
    name: 'Rise',
    steps: [
      ColorFilterStep.colorOverlay(255, 170, 0, 0.1),
      ColorFilterStep.brightness(0.09),
      ColorFilterStep.saturation(0.1),
    ],
  );

  /// Hudson: Creates an "icy" illusion with heightened shadows, cool tint and
  /// dodged center
  static FilterModel hudson = FilterModel.fromSteps(
    name: 'Hudson',
    steps: [
      ColorFilterStep.rgbScale(1, 1, 1.25),
      ColorFilterStep.contrast(0.1),
      ColorFilterStep.brightness(0.15),
    ],
  );

  /// Valencia: Fades the image by increasing exposure and warming the colors,
  /// to give it an antique feel
  static FilterModel valencia = FilterModel.fromSteps(
    name: 'Valencia',
    steps: [
      ColorFilterStep.colorOverlay(255, 225, 80, 0.08),
      ColorFilterStep.saturation(0.1),
      ColorFilterStep.contrast(0.05),
    ],
  );

  /// X-Pro II: Increases color vibrance with a golden tint, high contrast and
  /// slight vignette added to the edges
  static FilterModel xProII = FilterModel.fromSteps(
    name: 'X-Pro II',
    steps: [
      ColorFilterStep.colorOverlay(255, 255, 0, 0.07),
      ColorFilterStep.saturation(0.2),
      ColorFilterStep.contrast(0.15),
    ],
  );

  /// Sierra: Gives a faded, softer look
  static FilterModel sierra = FilterModel.fromSteps(
    name: 'Sierra',
    steps: [ColorFilterStep.contrast(-0.15), ColorFilterStep.saturation(0.1)],
  );

  /// Willow: A monochromatic filter with subtle purple tones and a translucent
  /// white border
  static FilterModel willow = FilterModel.fromSteps(
    name: 'Willow',
    steps: [
      ColorFilterStep.grayscale(),
      ColorFilterStep.colorOverlay(100, 28, 210, 0.03),
      ColorFilterStep.brightness(0.1),
    ],
  );

  /// Lo-Fi: Enriches color and adds strong shadows through the use of
  /// saturation and "warming" the temperature
  static FilterModel loFi = FilterModel.fromSteps(
    name: 'Lo-Fi',
    steps: [ColorFilterStep.contrast(0.15), ColorFilterStep.saturation(0.2)],
  );

  /// Inkwell: Direct shift to black and white
  static FilterModel inkwell = FilterModel.fromSteps(
    name: 'Inkwell',
    steps: [ColorFilterStep.grayscale()],
  );

  /// Hefe: Hight contrast and saturation, with a similar effect to Lo-Fi but
  /// not quite as dramatic
  static FilterModel hefe = FilterModel.fromSteps(
    name: 'Hefe',
    steps: [ColorFilterStep.contrast(0.1), ColorFilterStep.saturation(0.15)],
  );

  /// Nashville: Warms the temperature, lowers contrast and increases exposure
  /// to give a light "pink" tint – making it feel "nostalgic"
  static FilterModel nashville = FilterModel.fromSteps(
    name: 'Nashville',
    steps: [
      ColorFilterStep.colorOverlay(220, 115, 188, 0.12),
      ColorFilterStep.contrast(-0.05),
    ],
  );

  /// Stinson: washing out the colors ever so slightly
  static FilterModel stinson = FilterModel.fromSteps(
    name: 'Stinson',
    steps: [ColorFilterStep.brightness(0.1), ColorFilterStep.sepia(0.3)],
  );

  /// Vesper: adds a yellow tint that
  static FilterModel vesper = FilterModel.fromSteps(
    name: 'Vesper',
    steps: [
      ColorFilterStep.colorOverlay(255, 225, 0, 0.05),
      ColorFilterStep.brightness(0.06),
      ColorFilterStep.contrast(0.06),
    ],
  );

  /// Earlybird: Gives an older look with a sepia tint and warm temperature
  static FilterModel earlybird = FilterModel.fromSteps(
    name: 'Earlybird',
    steps: [
      ColorFilterStep.colorOverlay(255, 165, 40, 0.2),
      ColorFilterStep.saturation(0.15),
    ],
  );

  /// Brannan: Increases contrast and exposure and adds a metallic tint
  static FilterModel brannan = FilterModel.fromSteps(
    name: 'Brannan',
    steps: [
      ColorFilterStep.contrast(0.2),
      ColorFilterStep.colorOverlay(140, 10, 185, 0.1),
    ],
  );

  /// Sutro: Burns photo edges, increases highlights and shadows dramatically
  /// with a focus on purple and brown colors
  static FilterModel sutro = FilterModel.fromSteps(
    name: 'Sutro',
    steps: [ColorFilterStep.brightness(-0.1), ColorFilterStep.saturation(-0.1)],
  );

  /// Toaster: Ages the image by "burning" the centre and adds a dramatic
  /// vignette
  static FilterModel toaster = FilterModel.fromSteps(
    name: 'Toaster',
    steps: [
      ColorFilterStep.sepia(0.1),
      ColorFilterStep.colorOverlay(255, 145, 0, 0.2),
    ],
  );

  /// Walden: Increases exposure and adds a yellow tint
  static FilterModel walden = FilterModel.fromSteps(
    name: 'Walden',
    steps: [
      ColorFilterStep.brightness(0.1),
      ColorFilterStep.colorOverlay(255, 255, 0, 0.2),
    ],
  );

  /// 1977: The increased exposure with a red tint gives the photograph a rosy,
  /// brighter, faded look.
  static FilterModel f1977 = FilterModel.fromSteps(
    name: '1977',
    steps: [
      ColorFilterStep.colorOverlay(255, 25, 0, 0.15),
      ColorFilterStep.brightness(0.1),
    ],
  );

  /// Kelvin: Increases saturation and temperature to give it a radiant "glow"
  static FilterModel kelvin = FilterModel.fromSteps(
    name: 'Kelvin',
    steps: [
      ColorFilterStep.colorOverlay(255, 140, 0, 0.1),
      ColorFilterStep.rgbScale(1.15, 1.05, 1),
      ColorFilterStep.saturation(0.35),
    ],
  );

  /// Maven: darkens images, increases shadows, and adds a slightly yellow tint
  /// overal
  static FilterModel maven = FilterModel.fromSteps(
    name: 'Maven',
    steps: [
      ColorFilterStep.colorOverlay(225, 240, 0, 0.1),
      ColorFilterStep.saturation(0.25),
      ColorFilterStep.contrast(0.05),
    ],
  );

  /// Ginza: brightens and adds a warm glow
  static FilterModel ginza = FilterModel.fromSteps(
    name: 'Ginza',
    steps: [ColorFilterStep.sepia(0.06), ColorFilterStep.brightness(0.1)],
  );

  /// Skyline: brightens to the image pop
  static FilterModel skyline = FilterModel.fromSteps(
    name: 'Skyline',
    steps: [ColorFilterStep.saturation(0.35), ColorFilterStep.brightness(0.1)],
  );

  /// Dogpatch: increases the contrast, while washing out the lighter colors
  static FilterModel dogpatch = FilterModel.fromSteps(
    name: 'Dogpatch',
    steps: [ColorFilterStep.contrast(0.15), ColorFilterStep.brightness(0.1)],
  );

  /// Brooklyn
  static FilterModel brooklyn = FilterModel.fromSteps(
    name: 'Brooklyn',
    steps: [
      ColorFilterStep.colorOverlay(25, 240, 252, 0.05),
      ColorFilterStep.sepia(0.3),
    ],
  );

  /// Helena: adds an orange and teal vibe
  static FilterModel helena = FilterModel.fromSteps(
    name: 'Helena',
    steps: [
      ColorFilterStep.colorOverlay(208, 208, 86, 0.2),
      ColorFilterStep.contrast(0.15),
    ],
  );

  /// Ashby: gives images a great golden glow and a subtle vintage feel
  static FilterModel ashby = FilterModel.fromSteps(
    name: 'Ashby',
    steps: [
      ColorFilterStep.colorOverlay(255, 160, 25, 0.1),
      ColorFilterStep.brightness(0.1),
    ],
  );

  /// Charmes: a high contrast filter, warming up colors in your image with a
  /// red tint
  static FilterModel charmes = FilterModel.fromSteps(
    name: 'Charmes',
    steps: [
      ColorFilterStep.colorOverlay(255, 50, 80, 0.12),
      ColorFilterStep.contrast(0.05),
    ],
  );
}

/// List of filter presets
List<FilterModel> presetFiltersList = [
  PresetFilters.none,
  PresetFilters.addictiveBlue,
  PresetFilters.addictiveRed,
  PresetFilters.aden,
  PresetFilters.amaro,
  PresetFilters.ashby,
  PresetFilters.brannan,
  PresetFilters.brooklyn,
  PresetFilters.charmes,
  PresetFilters.clarendon,
  PresetFilters.crema,
  PresetFilters.dogpatch,
  PresetFilters.earlybird,
  PresetFilters.f1977,
  PresetFilters.gingham,
  PresetFilters.ginza,
  PresetFilters.hefe,
  PresetFilters.helena,
  PresetFilters.hudson,
  PresetFilters.inkwell,
  PresetFilters.juno,
  PresetFilters.kelvin,
  PresetFilters.lark,
  PresetFilters.loFi,
  PresetFilters.ludwig,
  PresetFilters.maven,
  PresetFilters.mayfair,
  PresetFilters.moon,
  PresetFilters.nashville,
  PresetFilters.perpetua,
  PresetFilters.reyes,
  PresetFilters.rise,
  PresetFilters.sierra,
  PresetFilters.skyline,
  PresetFilters.slumber,
  PresetFilters.stinson,
  PresetFilters.sutro,
  PresetFilters.toaster,
  PresetFilters.valencia,
  PresetFilters.vesper,
  PresetFilters.walden,
  PresetFilters.willow,
  PresetFilters.xProII,
];
