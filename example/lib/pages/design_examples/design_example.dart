// Flutter imports:
import 'package:example/pages/design_examples/frosted_glass_example.dart';
import 'package:example/pages/design_examples/highly_configurable_example.dart';
import 'package:example/utils/example_helper.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:pro_image_editor/pro_image_editor.dart';

import '../../utils/example_constants.dart';
import 'whatsapp_example.dart';

class DesignExample extends StatefulWidget {
  const DesignExample({super.key});

  @override
  State<DesignExample> createState() => _DesignExampleState();
}

class _DesignExampleState extends State<DesignExample>
    with ExampleHelperState<DesignExample> {
  final String _urlWhatsApp = 'https://picsum.photos/id/350/1500/3000';
  final String _urlFrostedGlass = 'https://picsum.photos/id/28/1500/3000';

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext _) {
            return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Designs',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.auto_awesome),
                  title: const Text('Frosted-Glass'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _openExample(
                      FrostedGlassExample(url: _urlFrostedGlass),
                      _urlFrostedGlass,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.chat_outlined),
                  title: const Text('WhatsApp'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    _openExample(
                      WhatsAppExample(url: _urlWhatsApp),
                      _urlWhatsApp,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.tune),
                  title: const Text('Custom'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _openExample(
                      HighlyConfigurableExample(
                          url: ExampleConstants.of(context)!.demoNetworkUrl),
                      ExampleConstants.of(context)!.demoNetworkUrl,
                    );
                  },
                ),
              ],
            );
          },
        );
      },
      leading: const Icon(Icons.palette_outlined),
      title: const Text('Multiple designs'),
      subtitle: const Text('WhatsApp, Frosted-Glass or custom design'),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  void _openExample(Widget example, String url) async {
    LoadingDialog.instance.show(
      context,
      configs: const ProImageEditorConfigs(),
      theme: ThemeData.dark(),
    );

    await precacheImage(NetworkImage(_urlFrostedGlass), context);

    LoadingDialog.instance.hide();

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => example,
        ),
      );
    }
  }
}
