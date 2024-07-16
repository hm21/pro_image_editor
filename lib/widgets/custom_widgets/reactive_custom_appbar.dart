// Flutter imports:
import 'package:flutter/material.dart';

class ReactiveCustomAppbar extends StatelessWidget
    implements PreferredSizeWidget {
  final PreferredSizeWidget Function(BuildContext context) builder;
  final Stream stream;

  const ReactiveCustomAppbar({
    super.key,
    required this.builder,
    required this.stream,
    Size? appbarSize,
  }) : preferredSize = appbarSize ?? const Size.fromHeight(kToolbarHeight);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        return builder(context);
      },
    );
  }
}
