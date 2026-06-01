import 'package:flutter/material.dart';

/// Wraps a child widget and shows a thin linear progress bar pinned to the
/// top edge using Flutter's [Overlay] system — so it renders at the true root
/// screen level, above all navigation bars and other widgets, without
/// obscuring the content underneath.
///
/// Modeled after YouTube's non-intrusive loading indicator.
class TopProgressBarLoadingWrapper extends StatefulWidget {
  final bool isLoading;
  final Widget child;
  final Color progressColor;

  const TopProgressBarLoadingWrapper({
    super.key,
    required this.isLoading,
    required this.child,
    this.progressColor = Colors.blue,
  });

  @override
  State<TopProgressBarLoadingWrapper> createState() =>
      _TopProgressBarLoadingWrapperState();
}

class _TopProgressBarLoadingWrapperState
    extends State<TopProgressBarLoadingWrapper>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  // Mutable copies so the overlay builder always reads the latest values
  late Color _progressColor;

  @override
  void initState() {
    super.initState();
    _progressColor = widget.progressColor;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (widget.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showOverlay());
    }
  }

  @override
  void didUpdateWidget(TopProgressBarLoadingWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.progressColor != oldWidget.progressColor) {
      _progressColor = widget.progressColor;
      if (_overlayEntry != null) {
        _overlayEntry!.markNeedsBuild();
      }
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
      builder: (_) => _TopBarOverlayContent(
        progressColor: _progressColor,
        fadeAnimation: _fadeAnimation,
        slideAnimation: _slideAnimation,
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

class _TopBarOverlayContent extends StatelessWidget {
  final Color progressColor;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const _TopBarOverlayContent({
    required this.progressColor,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: Material(
            color: Colors.transparent,
            child: LinearProgressIndicator(
              backgroundColor: progressColor.withValues(alpha: 0.2),
              color: progressColor,
              minHeight: 3,
            ),
          ),
        ),
      ),
    );
  }
}
