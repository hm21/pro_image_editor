// Flutter imports:
import 'package:flutter/widgets.dart';

class ReactiveCustomWidget<T extends Widget> extends StatelessWidget {
  final T Function(BuildContext context) builder;
  final Stream stream;

  const ReactiveCustomWidget({
    super.key,
    required this.builder,
    required this.stream,
  });

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
