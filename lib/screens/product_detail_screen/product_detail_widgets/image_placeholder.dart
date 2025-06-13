// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ImagePlaceholder extends StatefulWidget {
  final double? width;
  final double? height;
  final String? message;
  final IconData? icon;
  final bool showAnimation;

  const ImagePlaceholder({
    super.key,
    this.width,
    this.height,
    this.message,
    this.icon,
    this.showAnimation = true,
  });

  @override
  State<ImagePlaceholder> createState() => _ImagePlaceholderState();
}

class _ImagePlaceholderState extends State<ImagePlaceholder>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    if (widget.showAnimation) {
      _pulseController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      );

      _fadeController = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );

      _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
      );

      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

      _pulseController.repeat(reverse: true);
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    if (widget.showAnimation) {
      _pulseController.dispose();
      _fadeController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget child = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E293B),
                  const Color(0xFF334155),
                  const Color(0xFF475569),
                ]
              : [
                  const Color(0xFFF8FAFC),
                  const Color(0xFFE2E8F0),
                  const Color(0xFFCBD5E1),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Animated background pattern
          if (widget.showAnimation)
            Positioned.fill(
              child: CustomPaint(
                painter: _PatternPainter(
                  color: isDark
                      ? Colors.white.withOpacity(0.03)
                      : Colors.grey.withOpacity(0.05),
                ),
              ),
            ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with subtle shadow
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon ?? Icons.image_outlined,
                    size: 48,
                    color: isDark
                        ? Colors.white.withOpacity(0.6)
                        : Colors.grey[500],
                  ),
                ),

                const SizedBox(height: 16),

                // Message text
                Text(
                  widget.message ?? 'No image available',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Colors.white.withOpacity(0.7)
                        : Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Image could not be loaded',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white.withOpacity(0.5)
                        : Colors.grey[500],
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!widget.showAnimation) {
      return child;
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _fadeAnimation]),
      builder: (context, _) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.scale(scale: _pulseAnimation.value, child: child),
        );
      },
    );
  }
}

// Custom painter for background pattern
class _PatternPainter extends CustomPainter {
  final Color color;

  _PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 20.0;

    // Draw diagonal lines
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Specialized placeholder variants for common use cases
class ProductImagePlaceholder extends ImagePlaceholder {
  const ProductImagePlaceholder({super.key})
    : super(
        message: 'Product image unavailable',
        icon: Icons.shopping_bag_outlined,
      );
}

class ProfileImagePlaceholder extends ImagePlaceholder {
  const ProfileImagePlaceholder({super.key})
    : super(message: 'No profile picture', icon: Icons.person_outline);
}

class GalleryImagePlaceholder extends ImagePlaceholder {
  const GalleryImagePlaceholder({super.key})
    : super(message: 'Image not found', icon: Icons.photo_outlined);
}
