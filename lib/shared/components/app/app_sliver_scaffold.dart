import 'package:arpicoiam/iam.dart';
import 'package:flutter/material.dart';

import 'app_scaffold.dart';

class AppSliverScaffold extends StatelessWidget {
  final String? title;
  final List<Widget> slivers;
  final ScrollController? scrollController;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final List<Widget>? actions;
  final PreferredSizeWidget? appBar;
  final bool isLoading;
  final Function()? onTapBackground;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Widget? floatingActionButton;
  final Stack? stack;

  const AppSliverScaffold({
    super.key,
    this.title,
    required this.slivers,
    this.scrollController,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.actions,
    this.appBar,
    this.isLoading = false,
    this.onTapBackground,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.floatingActionButton,
    this.stack,
  });

  Widget _body() {
    return Stack(
      key: stack?.key,
      alignment: stack?.alignment ?? AlignmentDirectional.topStart,
      textDirection: stack?.textDirection,
      fit: stack?.fit ?? StackFit.loose,
      clipBehavior: stack?.clipBehavior ?? Clip.hardEdge,
      children: [
        CustomScrollView(
          controller: scrollController,
          slivers: slivers,
        ),
        ...(stack?.children ?? []),
      ],
    );
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
                  onTap: onTapBackground,
                  child: Scaffold(
                    backgroundColor: backgroundColor,
                    appBar: appBar ??
                        AppBar(
                          title: title != null ? Text(title!) : null,
                          forceMaterialTransparency: true,
                          actions: actions,
                        ),
                    body: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _body(),
                    resizeToAvoidBottomInset: resizeToAvoidBottomInset,
                    bottomNavigationBar: bottomNavigationBar,
                    bottomSheet: bottomSheet,
                    floatingActionButton: floatingActionButton,
                  ),
                ),
                if (loading) const BlurLoader(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AppSliverBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AppSliverBox({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverToBoxAdapter(
        child: child,
      ),
    );
  }
}

class AppPinnedHeader extends StatelessWidget {
  final Widget child;
  final double height;
  final Color? backgroundColor;
  final double elevation;

  const AppPinnedHeader({
    super.key,
    required this.child,
    required this.height,
    this.backgroundColor,
    this.elevation = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _PinnedHeaderDelegate(
        child: child,
        height: height,
        backgroundColor:
        backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
        elevation: elevation,
      ),
    );
  }
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  final Color backgroundColor;
  final double elevation;

  const _PinnedHeaderDelegate({
    required this.child,
    required this.height,
    required this.backgroundColor,
    required this.elevation,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return Material(
      color: backgroundColor,
      elevation: overlapsContent ? elevation : 0,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.height != height ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.elevation != elevation;
  }
}