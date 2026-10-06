import 'package:flutter/material.dart';
import '../engine/flow_stage.dart';

/// Animation types for different stages
enum _AnimationType {
  ripple, // Expanding ripples (for RUNNING, WAITING)
  rotate, // Spinning icon (for REQUESTING)
  bounce, // Vertical bounce (for UPLOADING, DOWNLOADING)
  slide, // Horizontal slide (for NETWORK_ERROR)
  pulse, // Gentle pulse (for IDLE, TIMEOUT)
  rippleRotate,
  none, // No animation (for terminal states)
}

class FlowStageIcon extends StatefulWidget {
  final FlowStage stage;
  final double size;

  const FlowStageIcon({super.key, required this.stage, this.size = 48});

  @override
  State<FlowStageIcon> createState() => _FlowStageIconState();
}

class _FlowStageIconState extends State<FlowStageIcon>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late AnimationController _rotateController;
  late AnimationController _bounceController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();

    // Pulse for slight scaling
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Ripple animation for expanding circles
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Rotate animation for spinning icons
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Bounce animation for upload/download
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Slide animation for network error
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    _rotateController.dispose();
    _bounceController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = _iconConfig(widget.stage);
    final animationType = _getAnimationType(widget.stage);

    return SizedBox(
      width: widget.size * 2,
      height: widget.size * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background effects based on animation type
          if (animationType == _AnimationType.ripple ||
              animationType == _AnimationType.rippleRotate)
            _buildRippleEffect(config),
          if (animationType == _AnimationType.pulse) _buildPulseEffect(config),
          // Center icon with appropriate animation
          _buildCenterIcon(config, animationType),
        ],
      ),
    );
  }

  Widget _buildRippleEffect(_IconConfig config) {
    return AnimatedBuilder(
      animation: _rippleController,
      builder: (_, _) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(3, (index) {
            final progress = ((_rippleController.value + index * 0.3) % 1.0);
            final size = widget.size + progress * widget.size * 1.5;
            final opacity = (1 - progress).clamp(0.0, 1.0);

            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: config.bgColor.withValues(alpha: opacity * 0.3),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildPulseEffect(_IconConfig config) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, _) {
        final scale = 1 + (_pulseController.value * 0.3);
        final opacity = (1 - _pulseController.value * 0.5);
        return Container(
          width: widget.size * scale,
          height: widget.size * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: config.bgColor.withValues(alpha: opacity * 0.4),
          ),
        );
      },
    );
  }

  Widget _buildCenterIcon(_IconConfig config, _AnimationType animationType) {
    Widget iconWidget = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: config.bgColor,
        boxShadow: [
          BoxShadow(
            color: config.bgColor.withValues(alpha: 0.4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        config.icon,
        size: widget.size * 0.55,
        color: config.iconColor,
      ),
    );

    switch (animationType) {
      case _AnimationType.rotate:
        return AnimatedBuilder(
          animation: _rotateController,
          builder: (_, child) {
            return Transform.rotate(
              angle: _rotateController.value * 2 * 3.14159,
              child: child,
            );
          },
          child: iconWidget,
        );

      case _AnimationType.bounce:
        return AnimatedBuilder(
          animation: _bounceController,
          builder: (_, child) {
            final bounce = _bounceController.value;
            final offset = Offset(0, -bounce * 15);
            return Transform.translate(offset: offset, child: child);
          },
          child: iconWidget,
        );

      case _AnimationType.slide:
        return AnimatedBuilder(
          animation: _slideController,
          builder: (_, child) {
            final slide = (_slideController.value - 0.5) * 2;
            final offset = Offset(slide * 8, 0);
            return Transform.translate(offset: offset, child: child);
          },
          child: iconWidget,
        );

      case _AnimationType.pulse:
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (_, child) {
            final scale = 1 + (_pulseController.value * 0.08);
            return Transform.scale(scale: scale, child: child);
          },
          child: iconWidget,
        );

      case _AnimationType.ripple:
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (_, child) {
            final scale = 1 + (_pulseController.value * 0.08);
            return Transform.scale(scale: scale, child: child);
          },
          child: iconWidget,
        );

      case _AnimationType.rippleRotate:
        return AnimatedBuilder(
          animation: Listenable.merge([_rotateController, _pulseController]),
          builder: (_, child) {
            final scale = 1 + (_pulseController.value * 0.06);
            return Transform.rotate(
              angle: _rotateController.value * 2 * 3.14159,
              child: Transform.scale(scale: scale, child: child),
            );
          },
          child: iconWidget,
        );

      case _AnimationType.none:
        return iconWidget;
    }
  }
}

class _IconConfig {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _IconConfig({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}

_IconConfig _iconConfig(FlowStage stage) {
  switch (stage) {
    case FlowStage.WAITING:
      return _IconConfig(
        icon: Icons.autorenew_rounded,
        iconColor: Colors.blue.shade700,
        bgColor: Colors.blue.shade200,
      );
    case FlowStage.REQUESTING:
      return _IconConfig(
        icon: Icons.cloud_upload_outlined,
        iconColor: Colors.indigo.shade700,
        bgColor: Colors.indigo.shade200,
      );
    case FlowStage.UPLOADING:
      return _IconConfig(
        icon: Icons.upload_rounded,
        iconColor: Colors.purple.shade700,
        bgColor: Colors.purple.shade200,
      );
    case FlowStage.DOWNLOADING:
      return _IconConfig(
        icon: Icons.download_rounded,
        iconColor: Colors.cyan.shade700,
        bgColor: Colors.cyan.shade200,
      );
    case FlowStage.NETWORK_ERROR:
      return _IconConfig(
        icon: Icons.wifi_off_rounded,
        iconColor: Colors.orange.shade700,
        bgColor: Colors.orange.shade200,
      );
    case FlowStage.SUCCESS:
      return _IconConfig(
        icon: Icons.check_rounded,
        iconColor: Colors.green.shade700,
        bgColor: Colors.green.shade200,
      );
    case FlowStage.FAILED:
      return _IconConfig(
        icon: Icons.close_rounded,
        iconColor: Colors.red.shade700,
        bgColor: Colors.red.shade200,
      );
    case FlowStage.IDLE:
      return _IconConfig(
        icon: Icons.pending_outlined,
        iconColor: Colors.grey.shade700,
        bgColor: Colors.grey.shade200,
      );
    case FlowStage.TIMEOUT:
      return _IconConfig(
        icon: Icons.timer_off_outlined,
        iconColor: Colors.amber.shade700,
        bgColor: Colors.amber.shade200,
      );
  }
}

/// Determines the appropriate animation type for each stage
_AnimationType _getAnimationType(FlowStage stage) {
  switch (stage) {
    case FlowStage.WAITING:
      return _AnimationType.rippleRotate;
      return _AnimationType.ripple;

    case FlowStage.REQUESTING:
      return _AnimationType.rotate;

    case FlowStage.UPLOADING:
    case FlowStage.DOWNLOADING:
      return _AnimationType.bounce;

    case FlowStage.NETWORK_ERROR:
      return _AnimationType.slide;

    case FlowStage.IDLE:
    case FlowStage.TIMEOUT:
      return _AnimationType.pulse;

    case FlowStage.SUCCESS:
    case FlowStage.FAILED:
      return _AnimationType.none;
  }
}
