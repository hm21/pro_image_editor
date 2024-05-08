import 'dart:math';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/models/theme/theme.dart';
import 'package:pro_image_editor/modules/emoji_editor/utils/emoji_editor_category_view.dart';

import '../../mixins/converted_configs.dart';
import '../../mixins/editor_configs_mixin.dart';
import '../../models/layer.dart';
import '../../models/theme/theme_shared_values.dart';
import '../../utils/design_mode.dart';
import 'utils/emoji_editor_full_screen_search.dart';
import 'utils/emoji_editor_header_search.dart';

/// The `EmojiEditor` class is responsible for creating a widget that allows users to select emojis.
///
/// This widget provides an EmojiPicker that allows users to choose emojis, which are then returned
/// as `EmojiLayerData` containing the selected emoji text.
class EmojiEditor extends StatefulWidget with SimpleConfigsAccess {
  @override
  final ProImageEditorConfigs configs;

  /// Creates an `EmojiEditor` widget.
  const EmojiEditor({
    super.key,
    this.configs = const ProImageEditorConfigs(),
  });

  @override
  createState() => EmojiEditorState();
}

/// The state class for the `EmojiEditor` widget.
class EmojiEditorState extends State<EmojiEditor>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  final _emojiPickerKey = GlobalKey<EmojiPickerState>();
  final _emojiSearchPageKey = GlobalKey<EmojiEditorFullScreenSearchViewState>();

  late final EmojiTextEditingController _controller;

  late final TextStyle _textStyle;
  final bool isApple = [TargetPlatform.iOS, TargetPlatform.macOS]
      .contains(defaultTargetPlatform);
  bool _showExternalSearchPage = false;

  @override
  void initState() {
    final fontSize = 24 * (isApple ? 1.2 : 1.0);
    _textStyle =
        imageEditorTheme.emojiEditor.textStyle.copyWith(fontSize: fontSize);

    _controller = EmojiTextEditingController(emojiTextStyle: _textStyle);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Closes the editor without applying changes.
  void close() {
    Navigator.pop(context);
  }

  /// Search emojis
  void externSearch(String text) {
    setState(() {
      _showExternalSearchPage = text.isNotEmpty;
    });
    Future.delayed(Duration(
            milliseconds: _emojiSearchPageKey.currentState == null ? 30 : 0))
        .whenComplete(() {
      _emojiSearchPageKey.currentState?.search(text);
    });
  }

  /// Is `true` if the editor use the `WhatsApp` design.
  bool get _isWhatsApp =>
      imageEditorTheme.editorMode == ThemeEditorMode.whatsapp;

  @override
  Widget build(BuildContext context) {
    var content = LayoutBuilder(
      builder: (context, constraints) {
        return _buildEmojiPickerSizedBox(constraints, context);
      },
    );

    if (_isWhatsApp) {
      return content;
    }
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: content,
      ),
    );
  }

  /// Builds a SizedBox containing the EmojiPicker with dynamic sizing.
  Widget _buildEmojiPickerSizedBox(
      BoxConstraints constraints, BuildContext context) {
    if (_showExternalSearchPage) {
      return EmojiEditorFullScreenSearchView(
        key: _emojiSearchPageKey,
        config: _getEditorConfig(constraints),
        state: EmojiViewState(
          emojiEditorConfigs.emojiSet,
          (category, emoji) {
            Navigator.pop(
              context,
              EmojiLayerData(emoji: emoji.emoji),
            );
          },
          () {},
          () {},
        ),
      );
    }
    return ClipRRect(
      borderRadius: _isWhatsApp
          ? BorderRadius.zero
          : const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: EmojiPicker(
          key: _emojiPickerKey,
          onEmojiSelected: (category, emoji) => {
            Navigator.pop(
              context,
              EmojiLayerData(emoji: emoji.emoji),
            ),
          },
          textEditingController: _controller,
          config: _getEditorConfig(constraints),
        ),
      ),
    );
  }

  Config _getEditorConfig(BoxConstraints constraints) {
    return Config(
      height: _isWhatsApp
          ? double.infinity
          : max(
              50,
              min(320, constraints.maxHeight) -
                  MediaQuery.of(context).padding.bottom,
            ),
      emojiSet: emojiEditorConfigs.emojiSet,
      checkPlatformCompatibility: emojiEditorConfigs.checkPlatformCompatibility,
      emojiTextStyle: _textStyle.copyWith(
          fontSize:
              _isWhatsApp && designMode != ImageEditorDesignModeE.cupertino
                  ? 48
                  : null),
      emojiViewConfig: imageEditorTheme.emojiEditor.emojiViewConfig ??
          EmojiViewConfig(
            gridPadding: EdgeInsets.zero,
            horizontalSpacing: 0,
            verticalSpacing: 0,
            recentsLimit: _isWhatsApp ? 100 : 28,
            backgroundColor:
                _isWhatsApp ? Colors.transparent : imageEditorBackgroundColor,
            noRecents: Text(
              i18n.emojiEditor.noRecents,
              style: const TextStyle(fontSize: 20, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            buttonMode: designMode == ImageEditorDesignModeE.cupertino
                ? ButtonMode.CUPERTINO
                : ButtonMode.MATERIAL,
            loadingIndicator: const Center(child: CircularProgressIndicator()),
            columns: _calculateColumns(constraints),
            emojiSizeMax:
                !_isWhatsApp || designMode == ImageEditorDesignModeE.cupertino
                    ? 32
                    : 64,
            replaceEmojiOnLimitExceed: false,
          ),
      swapCategoryAndBottomBar:
          imageEditorTheme.emojiEditor.swapCategoryAndBottomBar,
      skinToneConfig: imageEditorTheme.emojiEditor.skinToneConfig,
      categoryViewConfig: imageEditorTheme.emojiEditor.categoryViewConfig ??
          CategoryViewConfig(
            initCategory: Category.RECENT,
            backgroundColor: imageEditorBackgroundColor,
            indicatorColor: imageEditorPrimaryColor,
            iconColorSelected: imageEditorPrimaryColor,
            iconColor: const Color(0xFF9E9E9E),
            tabIndicatorAnimDuration: kTabScrollDuration,
            dividerColor: Colors.black,
            customCategoryView: (
              config,
              state,
              tabController,
              pageController,
            ) {
              return EmojiEditorCategoryView(
                config,
                state,
                tabController,
                pageController,
              );
            },
            categoryIcons: const CategoryIcons(
              recentIcon: Icons.access_time_outlined,
              smileyIcon: Icons.emoji_emotions_outlined,
              animalIcon: Icons.cruelty_free_outlined,
              foodIcon: Icons.coffee_outlined,
              activityIcon: Icons.sports_soccer_outlined,
              travelIcon: Icons.directions_car_filled_outlined,
              objectIcon: Icons.lightbulb_outline,
              symbolIcon: Icons.emoji_symbols_outlined,
              flagIcon: Icons.flag_outlined,
            ),
          ),
      bottomActionBarConfig: _isWhatsApp
          ? const BottomActionBarConfig(enabled: false)
          : imageEditorTheme.emojiEditor.bottomActionBarConfig,
      searchViewConfig: imageEditorTheme.emojiEditor.searchViewConfig ??
          SearchViewConfig(
            backgroundColor: imageEditorBackgroundColor,
            buttonIconColor: imageEditorTextColor,
            customSearchView: (
              config,
              state,
              showEmojiView,
            ) {
              return EmojiEditorHeaderSearchView(
                config,
                state,
                showEmojiView,
                i18n: i18n,
              );
            },
          ),
    );
  }

  /// Calculates the number of columns for the EmojiPicker.
  int _calculateColumns(BoxConstraints constraints) => max(
          1,
          (_isWhatsApp && designMode != ImageEditorDesignModeE.cupertino
                      ? 6
                      : 10) /
                  400 *
                  constraints.maxWidth -
              1)
      .floor();
}
