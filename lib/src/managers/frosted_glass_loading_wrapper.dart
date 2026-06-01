import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Wraps a child widget and shows a frosted glass (blurred backdrop) loading
/// overlay using Flutter's [Overlay] system — so it renders at the true root
/// screen level, above all navigation bars and other widgets.
///
/// The overlay uses [BackdropFilter] with [ImageFilter.blur] to create a
/// glass-like blur effect, combined with a semi-transparent tint overlay and
/// a centered loading indicator.
class FrostedGlassLoadingWrapper extends StatefulWidget {
  final bool isLoading;
  final Widget child;
  final Widget loadingWidget;
  final Color overlayColor;
  final double sigmaX;
  final double sigmaY;

  const FrostedGlassLoadingWrapper({
    super.key,
    required this.isLoading,
    required this.child,
    required this.loadingWidget,
    this.overlayColor = const Color(0x26FFFFFF), // white at ~15% opacity
    this.sigmaX = 12.0,
    this.sigmaY = 12.0,
  });

  @override
  State<FrostedGlassLoadingWrapper> createState() =>
      _FrostedGlassLoadingWrapperState();
}

class _FrostedGlassLoadingWrapperState
    extends State<FrostedGlassLoadingWrapper>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  // Mutable copies so the overlay builder always reads the latest values
  late Widget _loadingWidget;
  late Color _overlayColor;
  late double _sigmaX;
  late double _sigmaY;

  @override
  void initState() {
    super.initState();
    _loadingWidget = widget.loadingWidget;
    _overlayColor = widget.overlayColor;
    _sigmaX = widget.sigmaX;
    _sigmaY = widget.sigmaY;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    if (widget.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showOverlay());
    }
  }

  @override
  void didUpdateWidget(FrostedGlassLoadingWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool overlayNeedsRebuild = false;
    if (widget.loadingWidget != oldWidget.loadingWidget) {
      _loadingWidget = widget.loadingWidget;
      overlayNeedsRebuild = true;
    }
    if (widget.overlayColor != oldWidget.overlayColor) {
      _overlayColor = widget.overlayColor;
      overlayNeedsRebuild = true;
    }
    if (widget.sigmaX != oldWidget.sigmaX ||
        widget.sigmaY != oldWidget.sigmaY) {
      _sigmaX = widget.sigmaX;
      _sigmaY = widget.sigmaY;
      overlayNeedsRebuild = true;
    }
    if (overlayNeedsRebuild && _overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }

    if (widget.isLoading && !oldWidget.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showOverlay();
      });
    } else if (!widget.isLoading && oldWidget.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _hideOverlay();
      });
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    _overlayEntry = OverlayEntry(
      builder: (_) => _FrostedGlassOverlayContent(
        loadingWidget: _loadingWidget,
        overlayColor: _overlayColor,
        sigmaX: _sigmaX,
        sigmaY: _sigmaY,
        fadeAnimation: _fadeAnimation,
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    _controller.forward();
  }

  Future<void> _hideOverlay() async {
    await _controller.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _FrostedGlassOverlayContent extends StatelessWidget {
  final Widget loadingWidget;
  final Color overlayColor;
  final double sigmaX;
  final double sigmaY;
  final Animation<double> fadeAnimation;

  const _FrostedGlassOverlayContent({
    required this.loadingWidget,
    required this.overlayColor,
    required this.sigmaX,
    required this.sigmaY,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: FadeTransition(
        opacity: fadeAnimation,
        child: ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
            child: Container(
              color: overlayColor,
              alignment: Alignment.center,
              child: loadingWidget,
            ),
          ),
        ),
      ),
    );
  }
}
