import 'package:flutter/material.dart';

/// Skeleton shimmer animation widget.
class SkeletonWidget extends StatefulWidget {

  const SkeletonWidget({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
    this.isCircle = false,
  });

  /// Creates a circular skeleton.
  const SkeletonWidget.circle({
    required double size, super.key,
    this.margin,
  })  : width = size,
        height = size,
        borderRadius = null,
        isCircle = true;

  /// Creates a text line skeleton.
  factory SkeletonWidget.text({
    Key? key,
    double? width,
    double height = 16,
    EdgeInsets? margin,
  }) => SkeletonWidget(
      key: key,
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(4),
      margin: margin,
    );
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;
  final bool isCircle;

  @override
  State<SkeletonWidget> createState() => _SkeletonWidgetState();
}

class _SkeletonWidgetState extends State<SkeletonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.isCircle ? null : widget.borderRadius,
            gradient: LinearGradient(
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                0.0,
                (_animation.value + 2) / 4,
                1.0,
              ],
            ),
          ),
        ),
    );
  }
}

/// Skeleton list item.
class SkeletonListItem extends StatelessWidget {

  const SkeletonListItem({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.titleLines = 1,
    this.subtitleLines = 1,
  });
  final bool hasLeading;
  final bool hasTrailing;
  final int titleLines;
  final int subtitleLines;

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (hasLeading) ...[
            const SkeletonWidget.circle(size: 48),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                for (var i = 0; i < titleLines; i++)
                  SkeletonWidget.text(
                    width: i == 0 ? double.infinity : 150,
                    height: 18,
                    margin: EdgeInsets.only(bottom: i < titleLines - 1 ? 4 : 0),
                  ),
                if (subtitleLines > 0) const SizedBox(height: 8),
                for (var i = 0; i < subtitleLines; i++)
                  SkeletonWidget.text(
                    width: i == subtitleLines - 1 ? 100 : double.infinity,
                    height: 14,
                    margin: EdgeInsets.only(
                      bottom: i < subtitleLines - 1 ? 4 : 0,
                    ),
                  ),
              ],
            ),
          ),
          if (hasTrailing) ...[
            const SizedBox(width: 16),
            const SkeletonWidget(width: 24, height: 24),
          ],
        ],
      ),
    );
}

/// Skeleton card.
class SkeletonCard extends StatelessWidget {

  const SkeletonCard({
    super.key,
    this.width,
    this.height,
    this.hasImage = true,
    this.contentLines = 3,
  });
  final double? width;
  final double? height;
  final bool hasImage;
  final int contentLines;

  @override
  Widget build(BuildContext context) => Card(
      child: SizedBox(
        width: width,
        height: height,
        child: Column(
          crossAxisAlignment: .start,
          children: [
            if (hasImage)
              SkeletonWidget(
                width: double.infinity,
                height: 150,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  SkeletonWidget.text(width: 200, height: 20),
                  const SizedBox(height: 12),
                  for (var i = 0; i < contentLines; i++)
                    SkeletonWidget.text(
                      width: i == contentLines - 1 ? 150 : double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
}

/// Skeleton builder for custom layouts.
class SkeletonBuilder<T> extends StatelessWidget {

  const SkeletonBuilder({
    required this.isLoading, required this.data, required this.builder, required this.skeletonBuilder, super.key,
  });
  final bool isLoading;
  final T? data;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context) skeletonBuilder;

  @override
  Widget build(BuildContext context) {
    if (isLoading || data == null) {
      return skeletonBuilder(context);
    }
    return builder(context, data as T);
  }
}
