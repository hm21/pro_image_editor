// Dart imports:
import 'dart:math';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:emoji_picker_flutter/locales/default_emoji_set_locale.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';

import '/core/mixins/converted_configs.dart';
import '/core/mixins/editor_configs_mixin.dart';
import '/pro_image_editor.dart';
import './widgets/emoji_editor_category_view.dart';
import 'widgets/emoji_editor_full_screen_search.dart';
import 'widgets/emoji_editor_header_search.dart';
import 'widgets/emoji_picker_view.dart';

/// The `EmojiEditor` class is responsible for creating a widget that allows
/// users to select emojis.
///
/// This widget provides an EmojiPicker that allows users to choose emojis,
/// which are then returned
/// as `EmojiLayerData` containing the selected emoji text.
class EmojiEditor extends StatefulWidget with SimpleConfigsAccess {
  /// Creates an `EmojiEditor` widget.
  const EmojiEditor({
    super.key,
    this.scrollController,
    this.configs = const ProImageEditorConfigs(),
    this.callbacks = const ProImageEditorCallbacks(),
  });
  @override
  final ProImageEditorConfigs configs;

  @override
  final ProImageEditorCallbacks callbacks;

  /// Controller for the scrollable content
  final ScrollController? scrollController;

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

  /// Check device is from Apple
  final bool isApple = [TargetPlatform.iOS, TargetPlatform.macOS]
      .contains(defaultTargetPlatform);
  bool _showExternalSearchPage = false;

  @override
  void initState() {
    _textStyle = emojiEditorConfigs.style.textStyle;

    _controller = EmojiTextEditingController(emojiTextStyle: _textStyle);

    callbacks.emojiEditorCallbacks?.onInit?.call();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      callbacks.emojiEditorCallbacks?.onAfterViewInit?.call();
    });
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

  Config _getEditorConfig(BoxConstraints constraints) {
    return Config(
      height: double.infinity,
      locale: emojiEditorConfigs.locale,
      emojiSet: emojiEditorConfigs.emojiSet,
      checkPlatformCompatibility: emojiEditorConfigs.checkPlatformCompatibility,
      emojiTextStyle: _textStyle,
      emojiViewConfig: emojiEditorConfigs.style.emojiViewConfig ??
          EmojiViewConfig(
            gridPadding: EdgeInsets.zero,
            horizontalSpacing: 0,
            verticalSpacing: 0,
            recentsLimit: 28,
            backgroundColor: kImageEditorBackground,
            buttonMode: designMode == ImageEditorDesignMode.cupertino
                ? ButtonMode.CUPERTINO
                : ButtonMode.MATERIAL,
            loadingIndicator: const Center(child: CircularProgressIndicator()),
            columns: _calculateColumns(constraints),
            emojiSizeMax: 32,
            replaceEmojiOnLimitExceed: false,
          ),
      viewOrderConfig: emojiEditorConfigs.style.viewOrderConfig,
      skinToneConfig: emojiEditorConfigs.style.skinToneConfig,
      categoryViewConfig: emojiEditorConfigs.style.categoryViewConfig ??
          CategoryViewConfig(
            initCategory: Category.RECENT,
            backgroundColor: emojiEditorConfigs.style.backgroundColor,
            indicatorColor: kImageEditorPrimaryColor,
            iconColorSelected: Colors.white,
            iconColor: const Color(0xFF9E9E9E),
            tabIndicatorAnimDuration: kTabScrollDuration,
            dividerColor: Colors.transparent,
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
      bottomActionBarConfig: emojiEditorConfigs.style.bottomActionBarConfig,
      searchViewConfig: emojiEditorConfigs.style.searchViewConfig ??
          SearchViewConfig(
            backgroundColor: emojiEditorConfigs.style.backgroundColor,
            buttonIconColor: kImageEditorTextColor,
            customSearchView: (
              config,
              state,
              showEmojiView,
            ) {
              return EmojiEditorHeaderSearchView(
                config,
                state,
                showEmojiView,
                i18n: i18n.emojiEditor,
              );
            },
          ),
    );
  }

  /// Calculates the number of columns for the EmojiPicker.
  int _calculateColumns(BoxConstraints constraints) =>
      max(1, 10 / 400 * constraints.maxWidth - 1).floor();

  @override
  Widget build(BuildContext context) {
    return ExtendedPopScope(
      child: SafeArea(
        child: _buildEmojiPicker(),
      ),
    );
  }

  /// Builds a SizedBox containing the EmojiPicker with dynamic sizing.
  Widget _buildEmojiPicker() {
    return LayoutBuilder(builder: (context, constraints) {
      if (_showExternalSearchPage) {
        return EmojiEditorFullScreenSearchView(
          key: _emojiSearchPageKey,
          config: _getEditorConfig(constraints),
          state: EmojiViewState(
            (emojiEditorConfigs.emojiSet ??
                getDefaultEmojiLocale)(emojiEditorConfigs.locale),
            (category, emoji) {
              Navigator.pop(
                context,
                EmojiLayerData(emoji: emoji.emoji),
              );
            },
            () {},
            () {},
            () {},
          ),
        );
      }
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: EmojiPicker(
          key: _emojiPickerKey,
          onEmojiSelected: (category, emoji) => {
            Navigator.pop(context, EmojiLayerData(emoji: emoji.emoji)),
          },
          textEditingController: _controller,
          config: _getEditorConfig(constraints),
          customWidget: (config, state, showSearchBar) {
            return ProEmojiPickerView(
              config: config,
              state: state,
              showSearchBar: showSearchBar,
              scrollController: widget.scrollController,
              i18nEmojiEditor: widget.configs.i18n.emojiEditor,
              emojiEditorStyle: widget.configs.emojiEditor.style,
            );
          },
        ),
      );
    });
  }
}
