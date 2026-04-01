import 'package:flutter/material.dart';

import '/features/layer/layer_export_example.dart';
import '/features/layer/layer_grouping_example.dart';
import '/features/layer/layer_select_design_example.dart';
import '/features/layer/selectable_layer_example.dart';

/// A [StatefulWidget] that represents the AI group page in the application.
class LayerGroupPage extends StatefulWidget {
  /// Creates an instance of [LayerGroupPage].
  const LayerGroupPage({super.key});

  @override
  State<LayerGroupPage> createState() => _LayerGroupPageState();
}

class _LayerGroupPageState extends State<LayerGroupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Layers'),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.design_services_outlined),
            title: const Text('Selection Design'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openExample(const LayerSelectDesignExample()),
          ),
          ListTile(
            leading: const Icon(Icons.group_work_outlined),
            title: const Text('Group-Selection'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openExample(const LayerGroupingExample()),
          ),
          ListTile(
            leading: const Icon(Icons.select_all_rounded),
            title: const Text('Always-Selectable'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openExample(const SelectableLayerExample()),
          ),
          ListTile(
            leading: const Icon(Icons.image_outlined),
            title: const Text('Export Layers as PNG'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openExample(const LayerExportExample()),
          ),
        ],
      ),
    );
  }

  void _openExample(Widget example) async {
    if (mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => example,
        ),
      );
    }
  }
}
