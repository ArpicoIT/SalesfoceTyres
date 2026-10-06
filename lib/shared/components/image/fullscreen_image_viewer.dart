import 'package:flutter/material.dart';

import 'app_image.dart';

class FullscreenImageViewer extends StatefulWidget {
  const FullscreenImageViewer({
    super.key,
    required this.images,
    required this.current,
  }) : assert(images.length > 0);

  final List<String> images;
  final String current;

  static Future<void> show(
      BuildContext context, {
        required List<String> images,
        required String current,
      }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => FullscreenImageViewer(
          images: images,
          current: current,
        ),
      ),
    );
  }

  @override
  State<FullscreenImageViewer> createState() =>
      _FullscreenImageViewerState();
}

class _FullscreenImageViewerState
    extends State<FullscreenImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.images.indexOf(widget.current);
    if (_currentIndex < 0) _currentIndex = 0;

    _pageController = PageController(
      initialPage: _currentIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          '${_currentIndex + 1} / ${widget.images.length}',
        ),
      ),

      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (_, index) {
          return InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: Center(
              child: AppImage(
                widget.images[index],
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}