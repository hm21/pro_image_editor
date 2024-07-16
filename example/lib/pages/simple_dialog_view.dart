import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class SimpleDialogView extends StatelessWidget {
  SimpleDialogView({
    super.key,
    required this.bytes,
  });

  Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 658,
                      child: _getAttachmentPreview(
                        context,
                        bytes,
                      ),
                    ),
                    Expanded(
                      child: AttachmentEditPanel(
                        height: MediaQuery.sizeOf(context).height,
                        context: context,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      width: 1.0,
                    ),
                  ),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            // popNavigator(
                            //   context: context,
                            //   type: AttachmentPopupCloseType.canceled,
                            // );
                          },
                          child: Text(
                            'i18n_cancel',
                            style:
                                Theme.of(context).textTheme.labelLarge!.merge(
                                      TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(
                          width: 40,
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.onSecondary,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            disabledBackgroundColor: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.12),
                            alignment: Alignment.center,
                            textStyle: Theme.of(context).textTheme.labelLarge,
                          ),
                          onPressed: null,
                          child: const Text('i18n_ok'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget AttachmentEditPanel(
      {required double height, required BuildContext context}) {
    return Container(
      height: height,
      padding: const EdgeInsets.only(left: 30, right: 30, top: 40, bottom: 28),
      child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          'Anything',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ])),
    );
  }

  Widget _getAttachmentPreview(BuildContext context, Uint8List bytes) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ProImageEditor.memory(
          bytes,
          callbacks: ProImageEditorCallbacks(
            onImageEditingStarted: () {
              //do nothing
            },
            onImageEditingComplete: (bytes) async {
              //do nothing
            },
            onCloseEditor: null,
          ),
          configs: ProImageEditorConfigs(
            imageGenerationConfigs: const ImageGeneratioConfigs(
              allowEmptyEditCompletion: true,
            ),
            imageEditorTheme: ImageEditorTheme(
              subEditorPage: SubEditorPageTheme(
                  enforceSizeFromMainEditor: true,
                  positionTop: 0,
                  positionLeft: 0,
                  barrierDismissible: true,
                  barrierColor: const Color(0x90272727),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return child;
                  }),
            ),
          ),
        );
      },
    );
  }
}
