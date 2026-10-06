import 'dart:io';

import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  const AppImage(
      this.source, {
        super.key,
        this.fit = BoxFit.cover,
        this.placeholder,
        this.placeholderAsset,
        this.fadeDuration = const Duration(milliseconds: 300),
      });

  final String? source;
  final BoxFit fit;
  final Widget? placeholder;
  final String? placeholderAsset;
  final Duration fadeDuration;

  @override
  Widget build(BuildContext context) {
    if (source == null || source!.trim().isEmpty) {
      return _placeholder;
    }

    if (_isNetwork(source!)) {
      return Image.network(
        source!,
        fit: fit,
        loadingBuilder: _loadingBuilder,
        errorBuilder: (_, _, _) => _placeholder,
        frameBuilder: _frameBuilder,
      );
    }

    if (_isFile(source!)) {
      return Image.file(
        _toFile(source!),
        fit: fit,
        errorBuilder: (_, _, _) => _placeholder,
        frameBuilder: _frameBuilder,
      );
    }

    return Image.asset(
      source!,
      fit: fit,
      errorBuilder: (_, _, _) => _placeholder,
      frameBuilder: _frameBuilder,
    );
  }

  Widget get _placeholder {
    if (placeholder != null) {
      return placeholder!;
    }

    if (placeholderAsset != null) {
      return Image.asset(
        placeholderAsset!,
        fit: fit,
      );
    }

    return const Center(
      child: Icon(Icons.image_not_supported_outlined),
    );
  }

  Widget _loadingBuilder(
      BuildContext context,
      Widget child,
      ImageChunkEvent? loadingProgress,
      ) {
    return loadingProgress == null ? child : _placeholder;
  }

  Widget _frameBuilder(
      BuildContext context,
      Widget child,
      int? frame,
      bool wasSynchronouslyLoaded,
      ) {
    if (wasSynchronouslyLoaded) {
      return child;
    }

    return AnimatedOpacity(
      opacity: frame == null ? 0 : 1,
      duration: fadeDuration,
      curve: Curves.easeOut,
      child: child,
    );
  }

  bool _isNetwork(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  bool _isFile(String value) {
    return value.startsWith('/') ||
        value.startsWith('file://');
  }

  File _toFile(String path) {
    if (path.startsWith('file://')) {
      return File(Uri.parse(path).toFilePath());
    }

    return File(path);
  }
}