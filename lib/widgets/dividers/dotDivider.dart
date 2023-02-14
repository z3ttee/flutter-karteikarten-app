
import 'package:flutter/widgets.dart';
import 'package:flutter_karteikarten_app/constants.dart';

class DotDivider extends StatelessWidget {
  final double? width;

  const DotDivider({
    super.key,
    this.width
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 16,
      child: const Center(
        child: Text(Constants.charDot),
      ),
    );
  }

}