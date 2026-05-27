import 'package:flutter/material.dart';

/// Wraps a child widget and shows a bottom sheet loading indicator
/// using Flutter's [Overlay] system — so it renders at the true root
/// screen level, above all navigation bars and other widgets.
class BottomSheetLoadingWrapper extends StatefulWidget {
  final bool isLoading;
  final Widget child;
  final Widget loadingWidget;
  final Color overlayColor;

  const BottomSheetLoadingWrapper({
    super.key,
    required this.isLoading,
    required this.child,
    required this.loadingWidget,
    required this.overlayColor,
  });

  @override
  State<BottomSheetLoadingWrapper> createState() =>
      _BottomSheetLoadingWrapperState();
}

class _BottomSheetLoadingWrapperState extends State<BottomSheetLoadingWrapper>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  // Mutable copies so the overlay builder always reads the latest values
  late Widget _loadingWidget;
  late Color _overlayColor;

  @override
  void initState() {
    super.initState();
    _loadingWidget = widget.loadingWidget;
    _overlayColor = widget.overlayColor;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    if (widget.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showOverlay());
    }
  }

  @override
  void didUpdateWidget(BottomSheetLoadingWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Always sync mutable copies so overlay builder picks up latest widget
    bool overlayNeedsRebuild = false;
    if (widget.loadingWidget != oldWidget.loadingWidget) {
      _loadingWidget = widget.loadingWidget;
      overlayNeedsRebuild = true;
    }
    if (widget.overlayColor != oldWidget.overlayColor) {
      _overlayColor = widget.overlayColor;
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
      builder: (_) => _BottomSheetOverlayContent(
        // Read from state fields so markNeedsBuild() causes a fresh build
        loadingWidget: _loadingWidget,
        overlayColor: _overlayColor,
        slideAnimation: _slideAnimation,
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

class _BottomSheetOverlayContent extends StatelessWidget {
  final Widget loadingWidget;
  final Color overlayColor;
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;

  const _BottomSheetOverlayContent({
    required this.loadingWidget,
    required this.overlayColor,
    required this.slideAnimation,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Tint over the full screen
        Positioned.fill(
          child: IgnorePointer(
            child: FadeTransition(
              opacity: fadeAnimation,
              child: Container(color: overlayColor),
            ),
          ),
        ),
        // Bottom sheet slides up from screen bottom edge
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SlideTransition(
            position: slideAnimation,
            child: loadingWidget,
          ),
        ),
      ],
    );
  }
}
