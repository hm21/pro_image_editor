import 'package:example/shared/widgets/paragraph_info_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/core/platform/io/io_helper.dart';

import '/core/mixin/example_helper.dart';
import 'pages/chewie_player_example.dart';
import 'pages/flick_video_player_example.dart';
import 'pages/video_media_kit_example.dart';
import 'pages/video_player_example.dart';

/// The video example widget
class VideoExample extends StatefulWidget {
  /// Creates a new [VideoExample] widget.
  const VideoExample({super.key});

  @override
  State<VideoExample> createState() => _VideoExampleState();
}

class _VideoExampleState extends State<VideoExample>
    with ExampleHelperState<VideoExample> {
  static const _isWebEditingSupported = false;

  bool get _isPlatformSupported =>
      kIsWeb && _isWebEditingSupported ||
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

  bool get _showUnsupportedWarning =>
      kIsWeb || Platform.isWindows || Platform.isLinux;

  late final _favoritePackage = _Package(
    title: 'Package "media_kit"',
    enabled: !kIsWeb || _isWebEditingSupported,
    example: const VideoMediaKitExample(),
  );

  late final _videoPackages = [
    _Package(
      title: 'Package "video_player"',
      subTitle: 'Recommended for Android and iOS',
      enabled: _isPlatformSupported,
      example: const VideoPlayerExample(),
    ),
    _Package(
      title: 'Package "flick_video_player"',
      enabled: _isPlatformSupported,
      example: const FlickVideoPlayerExample(),
    ),
    _Package(
      title: 'Package "chewie"',
      enabled: _isPlatformSupported,
      example: const ChewiePlayerExample(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: <Widget>[
          const ParagraphInfoWidget(
            margin: EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Text(
              'For a reduced bundle size and fewer dependencies, no video '
              'player package is included. However, the image editor supports '
              'easy integration with an external video player, allowing video '
              'editing to be set up in just a few lines of code. Additional '
              'required native code implementations are provided by my new '
              'package, pro_video_editor.',
            ),
          ),
          if (_showUnsupportedWarning)
            ParagraphInfoWidget(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              color: colorScheme.errorContainer,
              child: Text(
                'Video editing is currently only supported on Android, iOS and '
                'macOS. Support for other platforms will follow soon.',
                style: TextStyle(
                  color: colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          _buildSectionHeader(
            context,
            'Recommended',
            'Supports all subeditors (Clips-Editor and Audio-Editor)',
          ),
          _buildPackageTile(_favoritePackage),
          const SizedBox(height: 16),
          _buildSectionHeader(
            context,
            'Alternative Packages',
            'Limited support - doesn\'t support Clips-Editor and Audio-Editor',
          ),
          if (kDebugMode || (!kIsWeb && Platform.isAndroid))
            ..._videoPackages.map(_buildPackageTile),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageTile(_Package package) {
    return ListTile(
      enabled: package.enabled,
      leading: Icon(
        Icons.movie,
        color: package.enabled ? null : Colors.grey,
      ),
      title: Text(package.title),
      subtitle: package.enabled
          ? (package.subTitle.isNotEmpty ? Text(package.subTitle) : null)
          : _buildNotSupportedMsg(package.subTitle),
      trailing: Icon(
        Icons.chevron_right,
        color: package.enabled ? null : Colors.grey,
      ),
      onTap: package.enabled ? () => _openExample(package.example) : null,
    );
  }

  void _openExample(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Widget _buildNotSupportedMsg(String subTitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (subTitle.isNotEmpty) ...[
          Text(subTitle),
          const SizedBox(height: 4),
        ],
        const Text(
          'This package is not supported on this platform.',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _Package {
  _Package({
    required this.title,
    this.subTitle = '',
    required this.enabled,
    required this.example,
  });
  final String title;
  final String subTitle;
  final bool enabled;
  final Widget example;
}
