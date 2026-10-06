import 'package:arpicoiam/iam.dart';
import 'package:flutter/material.dart';

import '../../../helpers/responsive.dart';

class AppLoader {
  AppLoader._();
  static final instance = AppLoader._();

  final ValueNotifier<bool> loading = ValueNotifier(false);

  void show() => loading.value = true;
  void hide() => loading.value = false;
}

class AppScaffold extends StatefulWidget {
  final String? title;
  final bool centerTitle;

  final Widget? body;
  final Widget? scrollableBody;
  final ScrollController? scrollController;

  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final List<Widget>? actions;
  final AppBar? appBar;

  final bool isLoading;
  final Function()? onTapBackground;

  final EdgeInsets? contentPadding;
  final bool isEmpty;
  final Widget? emptyWidget;

  final bool defaultAppBar;
  final bool defaultHeight;
  final bool defaultPadding;
  final bool defaultResponsive;

  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Widget? floatingActionButton;

  final Stack? stack;

  /// Shows a scroll-down FAB when the scrollable body
  /// has content below the current scroll position.
  final bool enableScrollDownButton;

  const AppScaffold({
    super.key,
    this.title,
    this.centerTitle = false,
    this.body,
    this.scrollableBody,
    this.scrollController,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.actions,
    this.appBar,
    this.isLoading = false,
    this.onTapBackground,
    this.contentPadding,
    this.isEmpty = false,
    this.emptyWidget,
    this.defaultAppBar = true,
    this.defaultHeight = false,
    this.defaultPadding = false,
    this.defaultResponsive = false,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.floatingActionButton,
    this.stack,
    this.enableScrollDownButton = false,
  }) : assert(
  body != null || scrollableBody != null,
  'Either body or scrollableBody must be provided',
  ),
        assert(
        !isEmpty || emptyWidget != null,
        'emptyWidget must be provided when isEmpty is true',
        );

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  late final ScrollController _internalScrollController;

  ScrollController? _activeScrollController;

  bool _showScrollDownButton = false;

  ScrollController? get _scrollController {
    return widget.scrollController ?? _internalScrollController;
  }

  @override
  void initState() {
    super.initState();

    _internalScrollController = ScrollController();

    _attachScrollListener();
  }

  @override
  void didUpdateWidget(covariant AppScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.scrollController != widget.scrollController) {
      _detachScrollListener();
      _attachScrollListener();
    }

    if (oldWidget.enableScrollDownButton !=
        widget.enableScrollDownButton) {
      if (widget.enableScrollDownButton) {
        _attachScrollListener();
      } else {
        _detachScrollListener();
        _setShowScrollDownButton(false);
      }
    }
  }

  void _attachScrollListener() {
    if (!widget.enableScrollDownButton ||
        widget.scrollableBody == null) {
      return;
    }

    final controller = _scrollController;

    if (controller == null || _activeScrollController == controller) {
      return;
    }

    controller.addListener(_onScroll);
    _activeScrollController = controller;

    _updateScrollDownButton();
  }

  void _detachScrollListener() {
    _activeScrollController?.removeListener(_onScroll);
    _activeScrollController = null;
  }

  void _onScroll() {
    _updateScrollDownButton();
  }

  void _updateScrollDownButton() {
    final controller = _scrollController;

    if (!widget.enableScrollDownButton ||
        widget.scrollableBody == null ||
        controller == null ||
        !controller.hasClients) {
      _setShowScrollDownButton(false);
      return;
    }

    final position = controller.position;

    final canScrollDown =
        position.pixels < position.maxScrollExtent - 20;

    _setShowScrollDownButton(canScrollDown);
  }

  void _setShowScrollDownButton(bool value) {
    if (_showScrollDownButton == value || !mounted) {
      return;
    }

    setState(() {
      _showScrollDownButton = value;
    });
  }

  void _scrollToBottom() {
    final controller = _scrollController;

    if (controller == null || !controller.hasClients) {
      return;
    }

    controller.animateTo(
      controller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  BoxConstraints? _constraints(BuildContext context) {
    if (!widget.defaultHeight) {
      return null;
    }

    return BoxConstraints(
      minHeight:
      MediaQuery.of(context).size.height -
          kToolbarHeight -
          MediaQuery.of(context).viewPadding.vertical,
    );
  }

  EdgeInsets _padding(BuildContext context) {
    if (widget.defaultPadding) {
      return const EdgeInsets.all(16);
    }

    return widget.contentPadding ?? EdgeInsets.zero;
  }

  AlignmentGeometry? _contentAlignment(BuildContext context) {
    if (!widget.defaultResponsive) {
      return null;
    }

    return Responsive.of(context).value<AlignmentGeometry?>(
      phone: Alignment.topCenter,
      tablet: Alignment.center,
      desktop: Alignment.center,
    );
  }

  double? _contentWidth(BuildContext context) {
    if (!widget.defaultResponsive) {
      return null;
    }

    return Responsive.of(context).value<double?>(
      phone: null,
      tablet: 480,
      desktop: 460,
    );
  }

  Widget _buildScrollableBody(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Container(
        padding: _padding(context),
        constraints: _constraints(context),
        alignment: _contentAlignment(context),
        child: SizedBox(
          width: _contentWidth(context),
          child: widget.scrollableBody,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (widget.scrollableBody != null) {
      return _buildScrollableBody(context);
    }

    if (widget.body != null) {
      return Container(
        padding: _padding(context),
        constraints: _constraints(context),
        alignment: _contentAlignment(context),
        child: SizedBox(
          width: _contentWidth(context),
          child: widget.body,
        ),
      );
    }

    return Center(
      child: Text('[ ${widget.title} ] screen'),
    );
  }

  Widget _buildBodyContainer(BuildContext context) {
    return Stack(
      key: widget.stack?.key,
      alignment:
      widget.stack?.alignment ??
          AlignmentDirectional.topStart,
      textDirection: widget.stack?.textDirection,
      fit: widget.stack?.fit ?? StackFit.loose,
      clipBehavior:
      widget.stack?.clipBehavior ?? Clip.hardEdge,
      children: [
        _buildBody(context),
        ...?widget.stack?.children,
      ],
    );
  }

  // Widget? _buildFloatingActionButton() {
  //   if (widget.floatingActionButton != null) {
  //     return widget.floatingActionButton;
  //   }
  //
  //   if (!widget.enableScrollDownButton ||
  //       !_showScrollDownButton) {
  //     return null;
  //   }
  //
  //   return FloatingActionButton.small(
  //     onPressed: _scrollToBottom,
  //     child: const Icon(
  //       Icons.keyboard_arrow_down_rounded,
  //     ),
  //   );
  // }

  Widget? _buildFloatingActionButton() {
    final scrollButton = widget.enableScrollDownButton && _showScrollDownButton
        ? FloatingActionButton.small(
      onPressed: _scrollToBottom,
      child: const Icon(Icons.keyboard_arrow_down_rounded),
    )
        : null;

    if (widget.floatingActionButton == null) {
      return scrollButton;
    }

    if (scrollButton == null) {
      return widget.floatingActionButton;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.floatingActionButton!,
        const SizedBox(height: 12),
        scrollButton,
      ],
    );
  }

  @override
  void dispose() {
    _detachScrollListener();
    _internalScrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (can, result) {
        final loader = AppLoader.instance;

        if (loader.loading.value) {
          loader.hide();
        }
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: AppLoader.instance.loading,
        builder: (_, loading, _) {
          return Material(
            child: Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onTapBackground,
                  child: Scaffold(
                    backgroundColor: widget.backgroundColor,

                    appBar:
                    widget.appBar ??
                        (widget.defaultAppBar
                            ? AppBar(
                          title: widget.title != null
                              ? Text(widget.title!)
                              : null,
                          forceMaterialTransparency: true,
                          actions: widget.actions,
                          centerTitle: widget.centerTitle,
                        )
                            : null),

                    body: SafeArea(
                      child: Builder(
                        builder: (context) {
                          if (widget.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                      
                          if (widget.isEmpty &&
                              widget.emptyWidget != null) {
                            return widget.emptyWidget!;
                          }
                      
                          return _buildBodyContainer(context);
                        },
                      ),
                    ),

                    resizeToAvoidBottomInset:
                    widget.resizeToAvoidBottomInset,

                    bottomNavigationBar:
                    widget.bottomNavigationBar,

                    bottomSheet: widget.bottomSheet,

                    floatingActionButton:
                    _buildFloatingActionButton(),
                  ),
                ),

                if (loading) BlurLoader(),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// v 1.0
// class AppScaffold extends StatelessWidget {
//   final String? title;
//   final bool centerTitle;
//   final Widget? body;
//   final Widget? scrollableBody;
//   final ScrollController? scrollController;
//   final Color? backgroundColor;
//   final bool? resizeToAvoidBottomInset;
//   final List<Widget>? actions;
//   final AppBar? appBar;
//   final bool isLoading;
//   final Function()? onTapBackground;
//   final EdgeInsets? contentPadding;
//   final bool isEmpty;
//   final Widget? emptyWidget;
//   final bool defaultAppBar;
//   final bool defaultHeight;
//   final bool defaultPadding;
//   final bool defaultResponsive;
//   final Widget? bottomNavigationBar;
//   final Widget? bottomSheet;
//   final Stack? stack;
//   final bool enableScrollDownButton;
//
//   const AppScaffold({
//     super.key,
//     this.title,
//     this.centerTitle = false,
//     this.body,
//     this.scrollableBody,
//     this.scrollController,
//     this.backgroundColor,
//     this.resizeToAvoidBottomInset,
//     this.actions,
//     this.appBar,
//     this.isLoading = false,
//     this.onTapBackground,
//     this.contentPadding,
//     this.isEmpty = false,
//     this.emptyWidget,
//     this.defaultAppBar = true,
//     this.defaultHeight = false,
//     this.defaultPadding = false,
//     this.defaultResponsive = false,
//     this.bottomNavigationBar,
//     this.bottomSheet,
//     this.stack,
//     this.enableScrollDownButton = false,
//   }) : assert(
//          body != null || scrollableBody != null,
//          'Either body or scrollableBody must be provided',
//        ),
//        assert(
//          !isEmpty || emptyWidget != null,
//          'emptyWidget must be provided when isEmpty is true',
//        );
//
//   BoxConstraints? _constraints(BuildContext context) {
//     if (!defaultHeight) return null;
//
//     return BoxConstraints(
//       minHeight:
//           MediaQuery.of(context).size.height -
//           kToolbarHeight -
//           MediaQuery.of(context).viewPadding.vertical,
//     );
//   }
//
//   EdgeInsets _padding(BuildContext context) {
//     if (defaultPadding) return const .all(16);
//
//     return contentPadding ?? .zero;
//   }
//
//   AlignmentGeometry? _contentAlignment(BuildContext context) {
//     if (!defaultResponsive) return null;
//
//     return Responsive.of(context).value<AlignmentGeometry?>(
//       phone: Alignment.topCenter,
//       tablet: Alignment.center,
//       desktop: Alignment.center,
//     );
//   }
//
//   double? _contentWidth(BuildContext context) {
//     if (!defaultResponsive) return null;
//
//     return Responsive.of(
//       context,
//     ).value<double?>(phone: null, tablet: 480, desktop: 460);
//   }
//
//   Widget _bodyContainer(BuildContext context) {
//     return Stack(
//       key: stack?.key,
//       alignment: stack?.alignment ?? AlignmentDirectional.topStart,
//       textDirection: stack?.textDirection,
//       fit: stack?.fit ?? StackFit.loose,
//       clipBehavior: stack?.clipBehavior ?? Clip.hardEdge,
//       children: [
//         if (scrollableBody != null)
//           SingleChildScrollView(
//             controller: scrollController,
//             child: Container(
//               padding: _padding(context),
//               constraints: _constraints(context),
//               alignment: _contentAlignment(context),
//               child: SizedBox(
//                 width: _contentWidth(context),
//                 child: scrollableBody,
//               ),
//             ),
//           )
//         else if (body != null)
//           Container(
//             padding: _padding(context),
//             constraints: _constraints(context),
//             alignment: _contentAlignment(context),
//             child: SizedBox(width: _contentWidth(context), child: body!),
//           )
//         else
//           Center(child: Text('[ $title ] screen')),
//         ...(stack?.children ?? []),
//       ],
//     );
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       onPopInvokedWithResult: (can, result) {
//         final loader = AppLoader.instance;
//
//         if (loader.loading.value) {
//           loader.hide();
//         }
//       },
//       child: ValueListenableBuilder<bool>(
//         valueListenable: AppLoader.instance.loading,
//         builder: (_, loading, _) {
//           return Material(
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 GestureDetector(
//                   behavior: .opaque,
//                   onTap: onTapBackground,
//                   child: Scaffold(
//                     backgroundColor: backgroundColor,
//                     appBar:
//                         appBar ??
//                             (defaultAppBar ? AppBar(
//                           title: title != null ? Text(title!) : null,
//                           forceMaterialTransparency: true,
//                           actions: actions,
//                           centerTitle: centerTitle,
//                         ) : null),
//                     body: Builder(
//                       builder: (context) {
//                         if (isLoading) {
//                           return const Center(
//                             child: CircularProgressIndicator(),
//                           );
//                         }
//                         if (emptyWidget != null && isEmpty) {
//                           return emptyWidget!;
//                         }
//                         return _bodyContainer(context);
//                       },
//                     ),
//                     resizeToAvoidBottomInset: resizeToAvoidBottomInset,
//                     bottomNavigationBar: bottomNavigationBar,
//                     bottomSheet: bottomSheet,
//                     // extendBodyBehindAppBar: true,
//                   ),
//                 ),
//                 if (loading) BlurLoader(),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    super.key,
    required this.title,
    this.icon = Icons.inbox_rounded,
    this.message,
    this.buttonText,
    this.onPressed,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final responsive = Responsive.of(context);

    final iconSize = responsive.value(phone: 64.0, tablet: 80.0, desktop: 96.0);

    final titleSize = responsive.value(
      phone: 16.0,
      tablet: 18.0,
      desktop: 20.0,
    );

    final messageSize = responsive.value(
      phone: 14.0,
      tablet: 15.0,
      desktop: 16.0,
    );

    final spacingSmall = responsive.value(
      phone: 8.0,
      tablet: 12.0,
      desktop: 16.0,
    );

    final spacingLarge = responsive.value(
      phone: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );

    final buttonHeight = responsive.value(
      phone: 42.0, // 36.0
      tablet: 42.0,
      desktop: 48.0,
    );

    final horizontalPadding = responsive.value(
      phone: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: iconSize, color: cs.onSurfaceVariant),

              SizedBox(height: spacingSmall),

              Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: titleSize,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),

              if (message != null) ...[
                SizedBox(height: spacingSmall),

                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: messageSize,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],

              if (buttonText != null && onPressed != null) ...[
                SizedBox(height: spacingLarge),

                FilledButton.icon(
                  onPressed: onPressed,
                  icon: const Icon(Icons.refresh),
                  label: Text(buttonText!),
                  style: FilledButton.styleFrom(
                    minimumSize: Size(140, buttonHeight),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
