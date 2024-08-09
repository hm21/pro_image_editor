// Project imports:
import 'filter_addons.dart';
import 'filter_model.dart';

/// Preset filters that can be used directly
class PresetFilters {
  /// NoFilter: No filter
  static FilterModel none = const FilterModel(
    name: 'No Filter',
    filters: [],
  );

  /// Clarendon: adds light to lighter areas and dark to darker areas
  static FilterModel clarendon = FilterModel(
    name: 'Clarendon',
    filters: [
      ColorFilterAddons.brightness(.1),
      ColorFilterAddons.contrast(.1),
      ColorFilterAddons.saturation(.15),
    ],
  );

  /// Increase red color gradient
  static FilterModel addictiveRed = FilterModel(
    name: 'AddictiveRed',
    filters: [
      ColorFilterAddons.addictiveColor(50, 0, 0),
    ],
  );

  /// Increase blue color gradient
  static FilterModel addictiveBlue = FilterModel(
    name: 'AddictiveBlue',
    filters: [
      ColorFilterAddons.addictiveColor(0, 0, 50),
    ],
  );

  /// Gingham: Vintage-inspired, taking some color out
  static FilterModel gingham = FilterModel(
    name: 'Gingham',
    filters: [
      ColorFilterAddons.sepia(.04),
      ColorFilterAddons.contrast(-.15),
    ],
  );

  /// Moon: B/W, increase brightness and decrease contrast
  static FilterModel moon = FilterModel(
    name: 'Moon',
    filters: [
      ColorFilterAddons.grayscale(),
      ColorFilterAddons.contrast(-.04),
      ColorFilterAddons.brightness(0.1),
    ],
  );

  /// Lark: Brightens and intensifies colours but not red hues
  static FilterModel lark = FilterModel(
    name: 'Lark',
    filters: [
      ColorFilterAddons.brightness(0.08),
      ColorFilterAddons.grayscale(),
      ColorFilterAddons.contrast(-.04),
    ],
  );

  /// Reyes: a vintage filter, gives your photos a “dusty” look
  static FilterModel reyes = FilterModel(
    name: 'Reyes',
    filters: [
      ColorFilterAddons.sepia(0.4),
      ColorFilterAddons.brightness(0.13),
      ColorFilterAddons.contrast(-.05),
    ],
  );

  /// Juno: Brightens colors, and intensifies red and yellow hues
  static FilterModel juno = FilterModel(
    name: 'Juno',
    filters: [
      ColorFilterAddons.rgbScale(1.01, 1.04, 1),
      ColorFilterAddons.saturation(0.3),
    ],
  );

  /// Slumber: Desaturates the image as well as adds haze for a retro, dreamy
  /// look – with an emphasis on blacks and blues
  static FilterModel slumber = FilterModel(
    name: 'Slumber',
    filters: [
      ColorFilterAddons.brightness(.1),
      ColorFilterAddons.saturation(-0.5),
    ],
  );

  /// Crema: Adds a creamy look that both warms and cools the image
  static FilterModel crema = FilterModel(
    name: 'Crema',
    filters: [
      ColorFilterAddons.rgbScale(1.04, 1, 1.02),
      ColorFilterAddons.saturation(-0.05),
    ],
  );

  /// Ludwig: A slight hint of desaturation that also enhances light
  static FilterModel ludwig = FilterModel(
    name: 'Ludwig',
    filters: [
      ColorFilterAddons.brightness(.05),
      ColorFilterAddons.saturation(-0.03),
    ],
  );

  /// Aden: This filter gives a blue/pink natural look
  static FilterModel aden = FilterModel(
    name: 'Aden',
    filters: [
      ColorFilterAddons.colorOverlay(228, 130, 225, 0.13),
      ColorFilterAddons.saturation(-0.2),
    ],
  );

  /// Perpetua: Adding a pastel look, this filter is ideal for portraits
  static FilterModel perpetua = FilterModel(
    name: 'Perpetua',
    filters: [
      ColorFilterAddons.rgbScale(1.05, 1.1, 1),
    ],
  );

  /// Amaro: Adds light to an image, with the focus on the centre
  static FilterModel amaro = FilterModel(
    name: 'Amaro',
    filters: [
      ColorFilterAddons.saturation(0.3),
      ColorFilterAddons.brightness(0.15),
    ],
  );

  /// Mayfair: Applies a warm pink tone, subtle vignetting to brighten the
  /// photograph center and a thin black border
  static FilterModel mayfair = FilterModel(
    name: 'Mayfair',
    filters: [
      ColorFilterAddons.colorOverlay(230, 115, 108, 0.05),
      ColorFilterAddons.saturation(0.15),
    ],
  );

  /// Rise: Adds a "glow" to the image, with softer lighting of the subject
  static FilterModel rise = FilterModel(
    name: 'Rise',
    filters: [
      ColorFilterAddons.colorOverlay(255, 170, 0, 0.1),
      ColorFilterAddons.brightness(0.09),
      ColorFilterAddons.saturation(0.1),
    ],
  );

  /// Hudson: Creates an "icy" illusion with heightened shadows, cool tint and
  /// dodged center
  static FilterModel hudson = FilterModel(
    name: 'Hudson',
    filters: [
      ColorFilterAddons.rgbScale(1, 1, 1.25),
      ColorFilterAddons.contrast(0.1),
      ColorFilterAddons.brightness(0.15),
    ],
  );

  /// Valencia: Fades the image by increasing exposure and warming the colors,
  /// to give it an antique feel
  static FilterModel valencia = FilterModel(
    name: 'Valencia',
    filters: [
      ColorFilterAddons.colorOverlay(255, 225, 80, 0.08),
      ColorFilterAddons.saturation(0.1),
      ColorFilterAddons.contrast(0.05),
    ],
  );

  /// X-Pro II: Increases color vibrance with a golden tint, high contrast and
  /// slight vignette added to the edges
  static FilterModel xProII = FilterModel(
    name: 'X-Pro II',
    filters: [
      ColorFilterAddons.colorOverlay(255, 255, 0, 0.07),
      ColorFilterAddons.saturation(0.2),
      ColorFilterAddons.contrast(0.15),
    ],
  );

  /// Sierra: Gives a faded, softer look
  static FilterModel sierra = FilterModel(
    name: 'Sierra',
    filters: [
      ColorFilterAddons.contrast(-0.15),
      ColorFilterAddons.saturation(0.1),
    ],
  );

  /// Willow: A monochromatic filter with subtle purple tones and a translucent
  /// white border
  static FilterModel willow = FilterModel(
    name: 'Willow',
    filters: [
      ColorFilterAddons.grayscale(),
      ColorFilterAddons.colorOverlay(100, 28, 210, 0.03),
      ColorFilterAddons.brightness(0.1),
    ],
  );

  /// Lo-Fi: Enriches color and adds strong shadows through the use of
  /// saturation and "warming" the temperature
  static FilterModel loFi = FilterModel(
    name: 'Lo-Fi',
    filters: [
      ColorFilterAddons.contrast(0.15),
      ColorFilterAddons.saturation(0.2),
    ],
  );

  /// Inkwell: Direct shift to black and white
  static FilterModel inkwell = FilterModel(
    name: 'Inkwell',
    filters: [
      ColorFilterAddons.grayscale(),
    ],
  );

  /// Hefe: Hight contrast and saturation, with a similar effect to Lo-Fi but
  /// not quite as dramatic
  static FilterModel hefe = FilterModel(
    name: 'Hefe',
    filters: [
      ColorFilterAddons.contrast(0.1),
      ColorFilterAddons.saturation(0.15),
    ],
  );

  /// Nashville: Warms the temperature, lowers contrast and increases exposure
  /// to give a light "pink" tint – making it feel "nostalgic"
  static FilterModel nashville = FilterModel(
    name: 'Nashville',
    filters: [
      ColorFilterAddons.colorOverlay(220, 115, 188, 0.12),
      ColorFilterAddons.contrast(-0.05),
    ],
  );

  /// Stinson: washing out the colors ever so slightly
  static FilterModel stinson = FilterModel(
    name: 'Stinson',
    filters: [
      ColorFilterAddons.brightness(0.1),
      ColorFilterAddons.sepia(0.3),
    ],
  );

  /// Vesper: adds a yellow tint that
  static FilterModel vesper = FilterModel(
    name: 'Vesper',
    filters: [
      ColorFilterAddons.colorOverlay(255, 225, 0, 0.05),
      ColorFilterAddons.brightness(0.06),
      ColorFilterAddons.contrast(0.06),
    ],
  );

  /// Earlybird: Gives an older look with a sepia tint and warm temperature
  static FilterModel earlybird = FilterModel(
    name: 'Earlybird',
    filters: [
      ColorFilterAddons.colorOverlay(255, 165, 40, 0.2),
      ColorFilterAddons.saturation(0.15),
    ],
  );

  /// Brannan: Increases contrast and exposure and adds a metallic tint
  static FilterModel brannan = FilterModel(
    name: 'Brannan',
    filters: [
      ColorFilterAddons.contrast(0.2),
      ColorFilterAddons.colorOverlay(140, 10, 185, 0.1),
    ],
  );

  /// Sutro: Burns photo edges, increases highlights and shadows dramatically
  /// with a focus on purple and brown colors
  static FilterModel sutro = FilterModel(
    name: 'Sutro',
    filters: [
      ColorFilterAddons.brightness(-0.1),
      ColorFilterAddons.saturation(-0.1),
    ],
  );

  /// Toaster: Ages the image by "burning" the centre and adds a dramatic
  /// vignette
  static FilterModel toaster = FilterModel(
    name: 'Toaster',
    filters: [
      ColorFilterAddons.sepia(0.1),
      ColorFilterAddons.colorOverlay(255, 145, 0, 0.2),
    ],
  );

  /// Walden: Increases exposure and adds a yellow tint
  static FilterModel walden = FilterModel(
    name: 'Walden',
    filters: [
      ColorFilterAddons.brightness(0.1),
      ColorFilterAddons.colorOverlay(255, 255, 0, 0.2),
    ],
  );

  /// 1977: The increased exposure with a red tint gives the photograph a rosy,
  /// brighter, faded look.
  static FilterModel f1977 = FilterModel(
    name: '1977',
    filters: [
      ColorFilterAddons.colorOverlay(255, 25, 0, 0.15),
      ColorFilterAddons.brightness(0.1),
    ],
  );

  /// Kelvin: Increases saturation and temperature to give it a radiant "glow"
  static FilterModel kelvin = FilterModel(
    name: 'Kelvin',
    filters: [
      ColorFilterAddons.colorOverlay(255, 140, 0, 0.1),
      ColorFilterAddons.rgbScale(1.15, 1.05, 1),
      ColorFilterAddons.saturation(0.35),
    ],
  );

  /// Maven: darkens images, increases shadows, and adds a slightly yellow tint
  /// overal
  static FilterModel maven = FilterModel(
    name: 'Maven',
    filters: [
      ColorFilterAddons.colorOverlay(225, 240, 0, 0.1),
      ColorFilterAddons.saturation(0.25),
      ColorFilterAddons.contrast(0.05),
    ],
  );

  /// Ginza: brightens and adds a warm glow
  static FilterModel ginza = FilterModel(
    name: 'Ginza',
    filters: [
      ColorFilterAddons.sepia(0.06),
      ColorFilterAddons.brightness(0.1),
    ],
  );

  /// Skyline: brightens to the image pop
  static FilterModel skyline = FilterModel(
    name: 'Skyline',
    filters: [
      ColorFilterAddons.saturation(0.35),
      ColorFilterAddons.brightness(0.1),
    ],
  );

  /// Dogpatch: increases the contrast, while washing out the lighter colors
  static FilterModel dogpatch = FilterModel(
    name: 'Dogpatch',
    filters: [
      ColorFilterAddons.contrast(0.15),
      ColorFilterAddons.brightness(0.1),
    ],
  );

  /// Brooklyn
  static FilterModel brooklyn = FilterModel(
    name: 'Brooklyn',
    filters: [
      ColorFilterAddons.colorOverlay(25, 240, 252, 0.05),
      ColorFilterAddons.sepia(0.3),
    ],
  );

  /// Helena: adds an orange and teal vibe
  static FilterModel helena = FilterModel(
    name: 'Helena',
    filters: [
      ColorFilterAddons.colorOverlay(208, 208, 86, 0.2),
      ColorFilterAddons.contrast(0.15),
    ],
  );

  /// Ashby: gives images a great golden glow and a subtle vintage feel
  static FilterModel ashby = FilterModel(
    name: 'Ashby',
    filters: [
      ColorFilterAddons.colorOverlay(255, 160, 25, 0.1),
      ColorFilterAddons.brightness(0.1),
    ],
  );

  /// Charmes: a high contrast filter, warming up colors in your image with a
  /// red tint
  static FilterModel charmes = FilterModel(
    name: 'Charmes',
    filters: [
      ColorFilterAddons.colorOverlay(255, 50, 80, 0.12),
      ColorFilterAddons.contrast(0.05),
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
