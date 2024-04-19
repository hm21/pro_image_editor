import 'dart:typed_data';

import 'package:flutter/material.dart';

class PreviewImgPage extends StatefulWidget {
  final Uint8List imgBytes;

  const PreviewImgPage({super.key, required this.imgBytes});

  @override
  State<PreviewImgPage> createState() => _PreviewImgPageState();
}

class _PreviewImgPageState extends State<PreviewImgPage> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Result'),
        ),
        body: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            Image.memory(
              widget.imgBytes,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
