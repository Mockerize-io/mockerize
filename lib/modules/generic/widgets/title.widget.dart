import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mockerize/theme/breakpoint.widget.dart';

class MockerizeTitleWidget extends StatelessWidget {
  final String title;

  const MockerizeTitleWidget({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final size = mockerizeBreakSizes(context).breakPoints;

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        size.contains(BreakPoint.md)
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.only(
                  right: 10,
                  bottom: 6,
                ),
                child: SvgPicture.asset(
                  'assets/mockerize.svg',
                  width: 30,
                  height: 30,
                ),
              ),
        Flexible(
          // width: double.infinity,
          // clipBehavior: Clip.hardEdge,
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            textWidthBasis: TextWidthBasis.parent,
          ),
        ),
      ],
    );
  }
}
