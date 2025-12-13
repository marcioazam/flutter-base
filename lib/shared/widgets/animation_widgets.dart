import 'package:flutter/material.dart';

/// Lottie animation widget wrapper.
/// 
/// **Feature: flutter-state-of-art-2025**
/// **Validates: Requirements 31.1**
/// 
/// Note: Requires lottie package. This is a wrapper that provides
/// a consistent API for Lottie animations.
class LottieWidget extends StatefulWidget {

  const LottieWidget({
    required this.asset, super.key,
    this.url,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.repeat = true,
    this.reverse = false,
    this.autoPlay = true,
    this.onControllerReady,
    this.onComplete,
  });
  /// Asset path for the Lottie animation.
  final String asset;

  /// Network URL for the Lottie animation.
  final String? url;

  /// Width of the animation.
  final double? width;

  /// Height of the animation.
  final double? height;

  /// Fit mode for the animation.
  final BoxFit fit;

  /// Whether to loop the animation.
  final bool repeat;

  /// Whether to play in reverse.
  final bool reverse;

  /// Whether to auto-play.
  final bool autoPlay;

  /// Animation controller callback.
  final void Function(AnimationController)? onControllerReady;

  /// Callback when animation completes.
  final VoidCallback? onComplete;

  @override
  State<LottieWidget> createState() => _LottieWidgetState();
}

class _LottieWidgetState extends State<LottieWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    if (widget.autoPlay) {
      _controller.forward();
    }

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
        if (widget.repeat) {
          if (widget.reverse) {
            _controller.reverse();
          } else {
            _controller.reset();
            _controller.forward();
          }
        }
      } else if (status == AnimationStatus.dismissed && widget.reverse) {
        _controller.forward();
      }
    });

    widget.onControllerReady?.call(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
      width: widget.width,
      height: widget.height,
      child: const Placeholder(
        child: Center(
          child: Text('Lottie Animation\n(requires lottie package)'),
        ),
      ),
    );
}

/// Custom page route with configurable transitions.
/// 
/// **Feature: flutter-state-of-art-2025**
/// **Validates: Requirements 31.2**
class CustomPageRoute<T> extends PageRouteBuilder<T> {

  CustomPageRoute({
    required this.page,
    this.transitionType = PageTransitionType.fade,
    super.transitionDuration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          reverseTransitionDuration: transitionDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) => _buildTransition(
              transitionType,
              animation,
              curve,
              child,
            ),
        );
  final Widget page;
  final PageTransitionType transitionType;
  final Curve curve;

  static Widget _buildTransition(
    PageTransitionType type,
    Animation<double> animation,
    Curve curve,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    switch (type) {
      case PageTransitionType.fade:
        return FadeTransition(opacity: curvedAnimation, child: child);

      case PageTransitionType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.slideLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.slideDown:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.scale:
        return ScaleTransition(scale: curvedAnimation, child: child);

      case PageTransitionType.rotation:
        return RotationTransition(turns: curvedAnimation, child: child);

      case PageTransitionType.fadeScale:
        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1).animate(curvedAnimation),
            child: child,
          ),
        );
    }
  }
}

enum PageTransitionType {
  fade,
  slideRight,
  slideLeft,
  slideUp,
  slideDown,
  scale,
  rotation,
  fadeScale,
}

/// Staggered list animation widget.
/// 
/// **Feature: flutter-state-of-art-2025**
/// **Validates: Requirements 31.3**
class StaggeredListView extends StatefulWidget {

  const StaggeredListView({
    required this.itemCount, required this.itemBuilder, super.key,
    this.staggerDelay = const Duration(milliseconds: 50),
    this.itemDuration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    this.controller,
    this.padding,
    this.physics,
  });
  final int itemCount;
  final Widget Function(BuildContext, int, Animation<double>) itemBuilder;
  final Duration staggerDelay;
  final Duration itemDuration;
  final Curve curve;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  @override
  State<StaggeredListView> createState() => _StaggeredListViewState();
}

class _StaggeredListViewState extends State<StaggeredListView>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    for (var i = 0; i < widget.itemCount; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: widget.itemDuration,
      );

      final animation = CurvedAnimation(
        parent: controller,
        curve: widget.curve,
      );

      _controllers.add(controller);
      _animations.add(animation);

      Future.delayed(widget.staggerDelay * i, () {
        if (mounted) {
          controller.forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(StaggeredListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount) {
      _disposeControllers();
      _initAnimations();
    }
  }

  void _disposeControllers() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
    _animations.clear();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView.builder(
      controller: widget.controller,
      padding: widget.padding,
      physics: widget.physics,
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        if (index >= _animations.length) {
          return widget.itemBuilder(
            context,
            index,
            const AlwaysStoppedAnimation(1),
          );
        }
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) => widget.itemBuilder(context, index, _animations[index]),
        );
      },
    );
}

/// Staggered item wrapper with common animations.
class StaggeredItem extends StatelessWidget {

  const StaggeredItem({
    required this.animation, required this.child, super.key,
    this.type = StaggeredItemType.fadeSlide,
  });
  final Animation<double> animation;
  final Widget child;
  final StaggeredItemType type;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case StaggeredItemType.fade:
        return FadeTransition(opacity: animation, child: child);

      case StaggeredItemType.scale:
        return ScaleTransition(scale: animation, child: child);

      case StaggeredItemType.fadeSlide:
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );

      case StaggeredItemType.fadeScale:
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1).animate(animation),
            child: child,
          ),
        );
    }
  }
}

enum StaggeredItemType {
  fade,
  scale,
  fadeSlide,
  fadeScale,
}
