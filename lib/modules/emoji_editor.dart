import 'dart:math';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';

import '../models/editor_configs/emoji_editor_configs.dart';
import '../models/layer.dart';
import '../models/theme/theme.dart';
import '../models/i18n/i18n.dart';
import '../models/theme/theme_shared_values.dart';
import '../utils/design_mode.dart';

/// The `EmojiEditor` class is responsible for creating a widget that allows users to select emojis.
///
/// This widget provides an EmojiPicker that allows users to choose emojis, which are then returned
/// as `EmojiLayerData` containing the selected emoji text.
class EmojiEditor extends StatefulWidget {
  /// The internationalization (i18n) configuration for the editor.
  final I18n i18n;

  /// The design mode of the editor.
  final ImageEditorDesignModeE designMode;

  /// The theme configuration specific to the image editor.
  final ImageEditorTheme imageEditorTheme;

  /// The configuration for the EmojiPicker.
  ///
  /// This parameter allows you to customize the behavior and appearance of the EmojiPicker.
  final EmojiEditorConfigs configs;

  /// Creates an `EmojiEditor` widget.
  ///
  /// The [i18n] parameter is used for internationalization.
  ///
  /// The [designMode] parameter specifies the design mode of the editor.
  ///
  /// The [imageEditorTheme] parameter is the theme configuration specific to the image editor.
  const EmojiEditor({
    super.key,
    this.i18n = const I18n(),
    this.configs = const EmojiEditorConfigs(),
    this.imageEditorTheme = const ImageEditorTheme(),
    this.designMode = ImageEditorDesignModeE.material,
  });

  @override
  createState() => EmojiEditorState();
}

/// The state class for the `EmojiEditor` widget.
class EmojiEditorState extends State<EmojiEditor> {
  late final EmojiTextEditingController _controller;

  late final TextStyle _textStyle;
  final bool isApple = [TargetPlatform.iOS, TargetPlatform.macOS]
      .contains(defaultTargetPlatform);

  @override
  void initState() {
    final fontSize = 24 * (isApple ? 1.2 : 1.0);
    _textStyle = widget.configs.textStyle.copyWith(fontSize: fontSize);

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _buildEmojiPickerSizedBox(constraints, context);
          },
        ),
      ),
    );
  }

  /// Builds a SizedBox containing the EmojiPicker with dynamic sizing.
  Widget _buildEmojiPickerSizedBox(
      BoxConstraints constraints, BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: EmojiPicker(
          onEmojiSelected: (category, emoji) =>
              {Navigator.pop(context, EmojiLayerData(emoji: emoji.emoji))},
          textEditingController: _controller,
          config: Config(
            height: max(
              50,
              min(320, constraints.maxHeight) -
                  MediaQuery.of(context).padding.bottom,
            ),
            emojiSet: widget.configs.emojiSet,
            checkPlatformCompatibility:
                widget.configs.checkPlatformCompatibility,
            emojiTextStyle: _textStyle,
            emojiViewConfig: widget.configs.emojiViewConfig ??
                EmojiViewConfig(
                  gridPadding: EdgeInsets.zero,
                  horizontalSpacing: 0,
                  verticalSpacing: 0,
                  recentsLimit: 28,
                  backgroundColor: imageEditorBackgroundColor,
                  noRecents: Text(
                    widget.i18n.emojiEditor.noRecents,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  buttonMode:
                      widget.designMode == ImageEditorDesignModeE.cupertino
                          ? ButtonMode.CUPERTINO
                          : ButtonMode.MATERIAL,
                  loadingIndicator:
                      const Center(child: CircularProgressIndicator()),
                  columns: _calculateColumns(constraints),
                  emojiSizeMax: 32,
                  replaceEmojiOnLimitExceed: false,
                ),
            swapCategoryAndBottomBar: widget.configs.swapCategoryAndBottomBar,
            skinToneConfig: widget.configs.skinToneConfig,
            categoryViewConfig: widget.configs.categoryViewConfig ??
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
                    return WhatsAppCategoryView(
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
            bottomActionBarConfig: widget.configs.bottomActionBarConfig,
            searchViewConfig: widget.configs.searchViewConfig ??
                SearchViewConfig(
                  backgroundColor: imageEditorBackgroundColor,
                  buttonIconColor: imageEditorTextColor,
                  customSearchView: (
                    config,
                    state,
                    showEmojiView,
                  ) {
                    return WhatsAppSearchView(
                      config,
                      state,
                      showEmojiView,
                      i18n: widget.i18n,
                    );
                  },
                ),
          ),
        ),
      ),
    );
  }

  /// Calculates the number of columns for the EmojiPicker.
  int _calculateColumns(BoxConstraints constraints) =>
      max(1, 10 / 400 * constraints.maxWidth - 1).floor();
}

/// Customized Whatsapp category view
class WhatsAppCategoryView extends CategoryView {
  const WhatsAppCategoryView(
    super.config,
    super.state,
    super.tabController,
    super.pageController, {
    super.key,
  });

  @override
  WhatsAppCategoryViewState createState() => WhatsAppCategoryViewState();
}

class WhatsAppCategoryViewState extends State<WhatsAppCategoryView>
    with SkinToneOverlayStateMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.config.categoryViewConfig.backgroundColor,
      child: Row(
        children: [
          Expanded(
            child: WhatsAppTabBar(
              widget.config,
              widget.tabController,
              widget.pageController,
              widget.state.categoryEmoji,
              closeSkinToneOverlay,
            ),
          ),
          _buildBackspaceButton(),
        ],
      ),
    );
  }

  Widget _buildBackspaceButton() {
    if (widget.config.categoryViewConfig.showBackspaceButton) {
      return BackspaceButton(
        widget.config,
        widget.state.onBackspacePressed,
        widget.state.onBackspaceLongPressed,
        widget.config.categoryViewConfig.backspaceColor,
      );
    }
    return const SizedBox.shrink();
  }
}

class WhatsAppTabBar extends StatelessWidget {
  const WhatsAppTabBar(
    this.config,
    this.tabController,
    this.pageController,
    this.categoryEmojis,
    this.closeSkinToneOverlay, {
    super.key,
  });

  final Config config;

  final TabController tabController;

  final PageController pageController;

  final List<CategoryEmoji> categoryEmojis;

  final VoidCallback closeSkinToneOverlay;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: config.categoryViewConfig.tabBarHeight,
      child: TabBar(
        labelColor: config.categoryViewConfig.iconColorSelected,
        indicatorColor: config.categoryViewConfig.indicatorColor,
        unselectedLabelColor: config.categoryViewConfig.iconColor,
        dividerColor: config.categoryViewConfig.dividerColor,
        controller: tabController,
        labelPadding: const EdgeInsets.only(top: 1.0),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black12,
        ),
        onTap: (index) {
          closeSkinToneOverlay();
          pageController.jumpToPage(index);
        },
        tabs: categoryEmojis
            .asMap()
            .entries
            .map<Widget>(
                (item) => _buildCategory(item.key, item.value.category))
            .toList(),
      ),
    );
  }

  Widget _buildCategory(int index, Category category) {
    return Tab(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(
          getIconForCategory(
            config.categoryViewConfig.categoryIcons,
            category,
          ),
          size: 20,
        ),
      ),
    );
  }
}

/// Custom Whatsapp Search view implementation
class WhatsAppSearchView extends SearchView {
  final I18n i18n;

  const WhatsAppSearchView(
    super.config,
    super.state,
    super.showEmojiView, {
    super.key,
    required this.i18n,
  });

  @override
  // ignore: no_logic_in_create_state
  WhatsAppSearchViewState createState() => WhatsAppSearchViewState(i18n);
}

class WhatsAppSearchViewState extends SearchViewState {
  final I18n i18n;

  WhatsAppSearchViewState(this.i18n);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final emojiSize =
          widget.config.emojiViewConfig.getEmojiSize(constraints.maxWidth);
      final emojiBoxSize =
          widget.config.emojiViewConfig.getEmojiBoxSize(constraints.maxWidth);
      return Container(
        color: widget.config.searchViewConfig.backgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: emojiBoxSize + 8.0,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                scrollDirection: Axis.horizontal,
                itemCount: results.length,
                itemBuilder: (context, index) {
                  return buildEmoji(
                    results[index],
                    emojiSize,
                    emojiBoxSize,
                  );
                },
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: widget.showEmojiView,
                  color: widget.config.searchViewConfig.buttonColor,
                  icon: Icon(
                    Icons.arrow_back,
                    color: widget.config.searchViewConfig.buttonIconColor,
                    size: 20.0,
                  ),
                ),
                Expanded(
                  child: TextField(
                    onChanged: onTextInputChanged,
                    focusNode: focusNode,
                    style: const TextStyle(
                      color: imageEditorTextColor,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: i18n.emojiEditor.search,
                      hintStyle: const TextStyle(
                        color: imageEditorTextColor,
                        fontWeight: FontWeight.normal,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
