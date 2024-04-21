/// A helper class for managing WhatsApp filter animations and values.
class WhatsAppHelper {
  /// Represents the helper value for showing WhatsApp filters.
  double filterShowHelper = 0;

  /// Animates the WhatsApp filter sheet.
  ///
  /// If [up] is `true`, it animates the sheet upwards.
  /// Otherwise, it animates the sheet downwards.
  void filterSheetAutoAnimation(bool up, Function setState) async {
    if (up) {
      while (filterShowHelper < 120) {
        filterShowHelper += 4;
        setState(() {});
        await Future.delayed(const Duration(milliseconds: 1));
      }
    } else {
      while (filterShowHelper > 0) {
        filterShowHelper -= 4;
        setState(() {});
        await Future.delayed(const Duration(milliseconds: 1));
      }
    }
  }
}
