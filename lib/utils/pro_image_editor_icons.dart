// Flutter imports:
import 'package:flutter/widgets.dart';

/// A collection of custom icons used in the Pro Image Editor.
class ProImageEditorIcons {
  ProImageEditorIcons._();

  static const _kFontFam = 'ProImageEditorIcons';
  static const String _kFontPkg = 'pro_image_editor';

  /// Icon representing a pen with size 3.
  static const IconData penSize3 =
      IconData(0xe800, fontFamily: _kFontFam, fontPackage: _kFontPkg);

  /// Icon representing a pen with size 2.
  static const IconData penSize2 =
      IconData(0xe802, fontFamily: _kFontFam, fontPackage: _kFontPkg);

  /// Icon representing a pen with size 1.
  static const IconData penSize1 =
      IconData(0xe803, fontFamily: _kFontFam, fontPackage: _kFontPkg);

  /// Icon representing stickers.
  static const IconData stickers =
      IconData(0xe804, fontFamily: _kFontFam, fontPackage: _kFontPkg);
}
