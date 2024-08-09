// ignore_for_file: public_member_api_docs

/// Internationalization (i18n) settings for the Filter Editor component.
class I18nFilterEditor {
  /// Creates an instance of [I18nFilterEditor] with customizable
  /// internationalization settings.
  ///
  /// You can provide translations and messages specifically for the Filter
  /// Editor component of your application. Customize the text for the bottom
  /// navigation bar, messages such as "Filter is being applied," and
  /// filter-specific internationalization settings using the [filters]
  /// parameter.
  ///
  /// Example:
  ///
  /// ```dart
  /// I18nFilterEditor(
  ///   bottomNavigationBarText: 'Filter Effects',
  ///   done: 'Apply',
  ///   back: 'Cancel',
  ///   filters: I18nFilters(
  ///     brightness: 'Brightness',
  ///     contrast: 'Contrast',
  ///     saturation: 'Saturation',
  ///   ),
  /// )
  /// ```
  const I18nFilterEditor({
    this.bottomNavigationBarText = 'Filter',
    this.back = 'Back',
    this.done = 'Done',
    this.filters = const I18nFilters(),
  });

  /// Text for the bottom navigation bar item that opens the Filter Editor.
  final String bottomNavigationBarText;

  /// Text for the "Back" button in the Filter Editor.
  final String back;

  /// Text for the "Done" button in the Filter Editor.
  final String done;

  /// Internationalization settings for individual filters within the Filter
  /// Editor.
  final I18nFilters filters;
}

/// A class representing internationalized strings for filter-related UI text.
///
/// This class provides a collection of localized strings used for displaying
/// filter-related text in the user interface, enabling easy
/// internationalization of filter names and descriptions.
class I18nFilters {
  /// Creates an instance of [I18nFilters] with customizable
  /// internationalization settings.
  ///
  /// You can provide translations and messages for each filter available in
  /// your Filter Editor component. Customize the text for filter names and
  /// messages such as "Filter is being applied."
  ///
  /// Example:
  ///
  /// ```dart
  /// I18nFilters(
  ///   none: 'No Filter',
  ///   addictiveBlue: 'Addictive Blue',
  ///   addictiveRed: 'Addictive Red',
  ///   // Add translations for other filters...
  ///   xProII: 'X-Pro II',
  /// )
  /// ```
  const I18nFilters({
    this.none = 'No Filter',
    this.addictiveBlue = 'AddictiveBlue',
    this.addictiveRed = 'AddictiveRed',
    this.aden = 'Aden',
    this.amaro = 'Amaro',
    this.ashby = 'Ashby',
    this.brannan = 'Brannan',
    this.brooklyn = 'Brooklyn',
    this.charmes = 'Charmes',
    this.clarendon = 'Clarendon',
    this.crema = 'Crema',
    this.dogpatch = 'Dogpatch',
    this.earlybird = 'Earlybird',
    this.f1977 = '1977',
    this.gingham = 'Gingham',
    this.ginza = 'Ginza',
    this.hefe = 'Hefe',
    this.helena = 'Helena',
    this.hudson = 'Hudson',
    this.inkwell = 'Inkwell',
    this.juno = 'Juno',
    this.kelvin = 'Kelvin',
    this.lark = 'Lark',
    this.loFi = 'Lo-Fi',
    this.ludwig = 'Ludwig',
    this.maven = 'Maven',
    this.mayfair = 'Mayfair',
    this.moon = 'Moon',
    this.nashville = 'Nashville',
    this.perpetua = 'Perpetua',
    this.reyes = 'Reyes',
    this.rise = 'Rise',
    this.sierra = 'Sierra',
    this.skyline = 'Skyline',
    this.slumber = 'Slumber',
    this.stinson = 'Stinson',
    this.sutro = 'Sutro',
    this.toaster = 'Toaster',
    this.valencia = 'Valencia',
    this.vesper = 'Vesper',
    this.walden = 'Walden',
    this.willow = 'Willow',
    this.xProII = 'X-Pro II',
  });
  final String none;
  final String addictiveBlue;
  final String addictiveRed;
  final String aden;
  final String amaro;
  final String ashby;
  final String brannan;
  final String brooklyn;
  final String charmes;
  final String clarendon;
  final String crema;
  final String dogpatch;
  final String earlybird;
  final String f1977;
  final String gingham;
  final String ginza;
  final String hefe;
  final String helena;
  final String hudson;
  final String inkwell;
  final String juno;
  final String kelvin;
  final String lark;
  final String loFi;
  final String ludwig;
  final String maven;
  final String mayfair;
  final String moon;
  final String nashville;
  final String perpetua;
  final String reyes;
  final String rise;
  final String sierra;
  final String skyline;
  final String slumber;
  final String stinson;
  final String sutro;
  final String toaster;
  final String valencia;
  final String vesper;
  final String walden;
  final String willow;
  final String xProII;

  /// Retrieves the localized translation for a given filter name.
  ///
  /// This method allows you to obtain the localized translation for a specific
  /// filter name, returning the corresponding text for that filter in the
  /// chosen language or locale.
  ///
  /// Example:
  ///
  /// ```dart
  /// final i18nFilters = I18nFilters();
  /// final localizedText = i18nFilters.getFilterI18n('Amaro');
  /// // localizedText will contain the translation for the 'Amaro' filter.
  /// ```
  String getFilterI18n(String filterName) {
    switch (filterName) {
      case 'No Filter':
        return none;
      case 'AddictiveBlue':
        return addictiveBlue;
      case 'AddictiveRed':
        return addictiveRed;
      case 'Aden':
        return aden;
      case 'Amaro':
        return amaro;
      case 'Ashby':
        return ashby;
      case 'Brannan':
        return brannan;
      case 'Brooklyn':
        return brooklyn;
      case 'Charmes':
        return charmes;
      case 'Clarendon':
        return clarendon;
      case 'Crema':
        return crema;
      case 'Dogpatch':
        return dogpatch;
      case 'Earlybird':
        return earlybird;
      case '1977':
        return f1977;
      case 'Gingham':
        return gingham;
      case 'Ginza':
        return ginza;
      case 'Hefe':
        return hefe;
      case 'Helena':
        return helena;
      case 'Hudson':
        return hudson;
      case 'Inkwell':
        return inkwell;
      case 'Juno':
        return juno;
      case 'Kelvin':
        return kelvin;
      case 'Lark':
        return lark;
      case 'Lo-Fi':
        return loFi;
      case 'Ludwig':
        return ludwig;
      case 'Maven':
        return maven;
      case 'Mayfair':
        return mayfair;
      case 'Moon':
        return moon;
      case 'Nashville':
        return nashville;
      case 'Perpetua':
        return perpetua;
      case 'Reyes':
        return reyes;
      case 'Rise':
        return rise;
      case 'Sierra':
        return sierra;
      case 'Skyline':
        return skyline;
      case 'Slumber':
        return slumber;
      case 'Stinson':
        return stinson;
      case 'Sutro':
        return sutro;
      case 'Toaster':
        return toaster;
      case 'Valencia':
        return valencia;
      case 'Vesper':
        return vesper;
      case 'Walden':
        return walden;
      case 'Willow':
        return willow;
      case 'X-Pro II':
        return xProII;
      default:
        return filterName;
    }
  }
}
