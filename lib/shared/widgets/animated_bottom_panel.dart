import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AnimatedBottomPanel<T> extends StatelessWidget {
  const AnimatedBottomPanel({
    super.key,
    required this.valueListenable,
    required this.visible,
    required this.child,
    this.initialChildSize = 0.25,
    this.minChildSize = 0.25,
    this.maxChildSize = 0.75,
    this.snapSizes = const [0.25, 0.75],
    this.showDragHandle = true,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
    this.padding = const EdgeInsets.all(16),
  });

  final ValueListenable<T> valueListenable;
  final bool Function(T value) visible;
  final Widget child;

  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final List<double> snapSizes;

  final bool showDragHandle;

  final Duration duration;
  final Curve curve;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T>(
      valueListenable: valueListenable,
      builder: (context, value, child) {
        final isVisible = visible(value);

        return Positioned.fill(
          child: IgnorePointer(
            ignoring: !isVisible,
            child: AnimatedSlide(
              offset: isVisible
                  ? Offset.zero
                  : const Offset(0, 1),
              duration: duration,
              curve: curve,
              child: DraggableScrollableSheet(
                initialChildSize: initialChildSize,
                minChildSize: minChildSize,
                maxChildSize: maxChildSize,
                snap: true,
                snapSizes: snapSizes,
                expand: false,
                builder: (context, scrollController) {
                  return Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 1,
                          spreadRadius: 0,
                          offset: Offset(0, -1),
                          color: Colors.grey,
                        ),

                      ],
                    ),
                    child: Material(
                      elevation: 0,
                      child: ListView(
                        controller: scrollController,
                        padding: EdgeInsets.fromLTRB(
                          padding.horizontal/2,
                          0,
                          padding.horizontal/2,
                          padding.vertical/2,
                        ),
                        children: [
                          if (showDragHandle) ...[
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                margin: .only(top: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          child!,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }
}