// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:machine_test_farhathullah/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget {
  final int? cartItemCount;
  final VoidCallback? onCartPressed;

  const CustomAppBar({super.key, this.cartItemCount, this.onCartPressed});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          snap: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              final expandRatio =
                  (constraints.maxHeight - kToolbarHeight) /
                  (120 - kToolbarHeight);
              _isExpanded = expandRatio > 0.3;

              return FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: _buildBackground(context, expandRatio),
                title: AnimatedOpacity(
                  opacity: _isExpanded ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: _buildCollapsedTitle(),
                ),
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              );
            },
          ),
          actions: _buildActions(context, authProvider),
        );
      },
    );
  }

  Widget _buildBackground(BuildContext context, double expandRatio) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        // Main gradient background
        ClipPath(
          clipper: ModernCurveClipper(),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withBlue(255),
                  theme.colorScheme.primaryContainer,
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
        ),

        // Overlay pattern
        ClipPath(
          clipper: ModernCurveClipper(),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.transparent,
                  Colors.black.withOpacity(0.05),
                ],
              ),
            ),
          ),
        ),

        // Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                AnimatedOpacity(
                  opacity: expandRatio.clamp(0.0, 1.0),
                  duration: const Duration(milliseconds: 200),
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildExpandedContent(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    IconData greetingIcon;

    if (hour < 12) {
      greeting = 'Good Morning';
      greetingIcon = Icons.wb_sunny_rounded;
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      greetingIcon = Icons.wb_sunny_outlined;
    } else {
      greeting = 'Good Evening';
      greetingIcon = Icons.nightlight_round;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(greetingIcon, color: Colors.white.withOpacity(0.9), size: 20),
            const SizedBox(width: 8),
            Text(
              greeting,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'E-Shop',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            shadows: [
              Shadow(
                blurRadius: 4,
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Discover amazing products',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedTitle() {
    return const Text(
      'E-Shop',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 18,
        letterSpacing: -0.3,
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context, AuthProvider authProvider) {
    return [
      // Notifications button
      _buildActionButton(
        icon: Icons.notifications_outlined,
        onPressed: () {
          // Navigate to notifications
          _showNotifications(context);
        },
        badge: 3, // Example notification count
      ),

      const SizedBox(width: 8),

      // Cart button
      _buildActionButton(
        icon: Icons.shopping_bag_outlined,
        onPressed:
            widget.onCartPressed ??
            () {
              // Navigate to cart screen
            },
        badge: widget.cartItemCount,
      ),

      const SizedBox(width: 8),

      // Profile menu
      _buildProfileMenu(context, authProvider),

      const SizedBox(width: 16),
    ];
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    int? badge,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: Stack(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              if (badge != null && badge > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade500,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      badge > 99 ? '99+' : badge.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context, AuthProvider authProvider) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
        ),
        child: const Icon(
          Icons.person_outline_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
      onSelected: (value) async {
        HapticFeedback.lightImpact();
        await _handleMenuSelection(context, value, authProvider);
      },
      itemBuilder: (BuildContext context) => [
        _buildMenuItem(
          icon: Icons.person_outline_rounded,
          title: 'Profile',
          value: 'profile',
        ),
        _buildMenuItem(
          icon: Icons.shopping_bag_outlined,
          title: 'My Orders',
          value: 'orders',
        ),
        _buildMenuItem(
          icon: Icons.favorite_outline_rounded,
          title: 'Wishlist',
          value: 'wishlist',
        ),
        _buildMenuItem(
          icon: Icons.settings_outlined,
          title: 'Settings',
          value: 'settings',
        ),
        _buildMenuItem(
          icon: Icons.help_outline_rounded,
          title: 'Help & Support',
          value: 'help',
        ),
        const PopupMenuDivider(height: 16),
        _buildMenuItem(
          icon: Icons.logout_rounded,
          title: 'Logout',
          value: 'logout',
          isDestructive: true,
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
      offset: const Offset(0, 8),
    );
  }

  PopupMenuItem<String> _buildMenuItem({
    required IconData icon,
    required String title,
    required String value,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red.shade600 : null;

    return PopupMenuItem(
      value: value,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.shade50
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: color ?? Colors.grey.shade700),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleMenuSelection(
    BuildContext context,
    String value,
    AuthProvider authProvider,
  ) async {
    switch (value) {
      case 'profile':
        // Navigate to profile
        break;
      case 'orders':
        // Navigate to orders
        break;
      case 'wishlist':
        // Navigate to wishlist
        break;
      case 'settings':
        // Navigate to settings
        break;
      case 'help':
        // Navigate to help
        break;
      case 'logout':
        await _showLogoutDialog(context, authProvider);
        break;
    }
  }

  Future<void> _showLogoutDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      authProvider.logout();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _showNotifications(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('No new notifications'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// Enhanced custom clipper with modern curve
class ModernCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Create a more sophisticated curve
    path.lineTo(0, size.height - 30);

    // Bottom left curve
    path.quadraticBezierTo(0, size.height, 30, size.height);

    // Bottom line with slight curve
    path.lineTo(size.width - 60, size.height);

    // Bottom right curve (main feature)
    path.quadraticBezierTo(
      size.width - 20,
      size.height,
      size.width,
      size.height - 40,
    );

    // Right side
    path.lineTo(size.width, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
