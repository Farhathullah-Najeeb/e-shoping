// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InfoRow extends StatefulWidget {
  final String label;
  final String value;
  final IconData? icon;
  final bool copyable;
  final bool showDivider;
  final VoidCallback? onTap;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final bool isImportant;
  final Widget? trailing;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.copyable = false,
    this.showDivider = false,
    this.onTap,
    this.labelStyle,
    this.valueStyle,
    this.backgroundColor,
    this.padding,
    this.isImportant = false,
    this.trailing,
  });

  @override
  State<InfoRow> createState() => _InfoRowState();
}

class _InfoRowState extends State<InfoRow> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null || widget.copyable) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null || widget.copyable) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null || widget.copyable) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else if (widget.copyable) {
      _copyToClipboard();
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('${widget.label} copied to clipboard'),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultLabelStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: widget.isImportant
          ? (isDark ? Colors.white : Colors.black87)
          : (isDark ? Colors.grey[300] : Colors.grey[700]),
      letterSpacing: 0.25,
    );

    final defaultValueStyle = TextStyle(
      fontSize: 14,
      fontWeight: widget.isImportant ? FontWeight.w600 : FontWeight.w500,
      color: widget.isImportant
          ? theme.primaryColor
          : (isDark ? Colors.grey[400] : Colors.grey[600]),
      letterSpacing: 0.1,
    );

    Widget content = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding:
                widget.padding ??
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color:
                  widget.backgroundColor ??
                  (widget.onTap != null || widget.copyable
                      ? (_isPressed
                            ? (isDark ? Colors.grey[800] : Colors.grey[100])
                            : (isDark ? Colors.grey[900] : Colors.grey[50]))
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(12),
              border: widget.isImportant
                  ? Border.all(
                      color: theme.primaryColor.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
              boxShadow: widget.isImportant
                  ? [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    if (widget.icon != null) ...[
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.icon,
                          size: 16,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],

                    // Label
                    Expanded(
                      flex: 2,
                      child: Text(
                        widget.label,
                        style: widget.labelStyle ?? defaultLabelStyle,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Value
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              widget.value,
                              style: widget.valueStyle ?? defaultValueStyle,
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),

                          // Copy icon
                          if (widget.copyable) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.copy,
                              size: 16,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[500],
                            ),
                          ],

                          // Custom trailing widget
                          if (widget.trailing != null) ...[
                            const SizedBox(width: 8),
                            widget.trailing!,
                          ],

                          // Tap indicator
                          if (widget.onTap != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[400],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                // Divider
                if (widget.showDivider) ...[
                  const SizedBox(height: 12),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );

    if (widget.onTap != null || widget.copyable) {
      return GestureDetector(
        onTap: _handleTap,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: content,
      );
    }

    return content;
  }
}

// Specialized InfoRow variants for common use cases
class PriceInfoRow extends InfoRow {
  const PriceInfoRow({super.key, required String price, String? originalPrice})
    : super(
        label: 'Price',
        value: originalPrice != null ? '$price (was $originalPrice)' : price,
        icon: Icons.attach_money,
        isImportant: true,
      );
}

class StatusInfoRow extends InfoRow {
  StatusInfoRow({super.key, required String status, required Color statusColor})
    : super(
        label: 'Status',
        value: status,
        icon: Icons.circle,
        trailing: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
}

class CopyableInfoRow extends InfoRow {
  const CopyableInfoRow({
    super.key,
    required super.label,
    required super.value,
    super.icon,
  }) : super(copyable: true);
}

class ClickableInfoRow extends InfoRow {
  const ClickableInfoRow({
    super.key,
    required super.label,
    required super.value,
    required super.onTap,
    super.icon,
  });
}
