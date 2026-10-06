import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class OverflowMarqueeText extends StatelessWidget {
  const OverflowMarqueeText({
    super.key,
    required this.text,
    this.style,
    this.blankSpace = 24,
    this.velocity = 30,
  });

  final String text;
  final TextStyle? style;
  final double blankSpace;
  final double velocity;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: style,
          ),
          maxLines: 1,
          textDirection: Directionality.of(context),
        )..layout();

        final isOverflowing = textPainter.width > constraints.maxWidth;

        if (!isOverflowing) {
          return Text(
            text,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }

        return SizedBox(
          height: textPainter.height,
          child: Marquee(
            text: text,
            style: style,
            scrollAxis: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            blankSpace: blankSpace,
            velocity: velocity,
            pauseAfterRound: const Duration(seconds: 2),
            startPadding: 0,
            accelerationDuration: const Duration(milliseconds: 500),
            decelerationDuration: const Duration(milliseconds: 500),
          ),
        );
      },
    );
  }
}