import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/fab_control_service.dart';
import '../screens/home_screen.dart';
import '../screens/destinations_screen.dart';
import '../screens/all_galleries_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/appointments_screen.dart';
import 'lazy_load_indexed_stack.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final FabControlService _fabService = FabControlService();

  // Keys for nested navigators to handle back presses
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      // Reset FAB when switching tabs to prevent button from persisting
      _fabService.resetToDefault();
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<bool> _onWillPop() async {
    final isFirstRouteInCurrentTab = !await _navigatorKeys[_selectedIndex].currentState!.maybePop();
    if (isFirstRouteInCurrentTab) {
      if (_selectedIndex != 0) {
        setState(() {
          _selectedIndex = 0;
          // Reset FAB when switching back to home via back button
          _fabService.resetToDefault();
        });
        return false;
      }
    }
    return isFirstRouteInCurrentTab;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: AnimatedBuilder(
        animation: _fabService,
        builder: (context, child) {
          return Scaffold(
            extendBody: true,
            body: LazyLoadIndexedStack(
              index: _selectedIndex,
              children: [
                _buildNavigator(0, const HomeScreen()),
                _buildNavigator(1, const DestinationsScreen()),
                _buildNavigator(2, const AppointmentsScreen()),
                _buildNavigator(3, const CartScreen()),
              ],
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: _buildFab(),
            bottomNavigationBar: _buildBottomBar(),
          );
        },
      ),
    );
  }

  Widget _buildNavigator(int index, Widget child) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => child,
        );
      },
    );
  }

  Widget _buildFab() {
    final bool showCart = _fabService.showAddToCart;
    
    if (!showCart) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 75), // Moved closer to bottom bar
      child: GestureDetector(
        onTap: _fabService.onAddToCartPressed,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.9, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow Effect
              Container(
                width: 180, // Slightly smaller glow
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF1744).withOpacity(0.4), // Slightly less intense
                      blurRadius: 15,
                      spreadRadius: -5,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
              // Skewed "Motorsport" Button
              Transform(
                transform: Matrix4.skewX(-0.2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6), // Slightly tighter radius
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Compact padding
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1E1E1E).withOpacity(0.9),
                            const Color(0xFF000000).withOpacity(0.95),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: const Color(0xFFFF1744).withOpacity(0.8), // Red Border
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Transform(
                         // Un-skew text for readability
                        transform: Matrix4.skewX(0.2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.shopping_cart_outlined, color: Color(0xFFFF1744), size: 18), // Smaller icon
                            const SizedBox(width: 8), // Tighter spacing
                            const Text(
                              'ADD TO CART',
                              style: TextStyle(
                                fontWeight: FontWeight.w900, 
                                color: Colors.white, 
                                fontSize: 14, // Smaller text
                                letterSpacing: 0.8,
                                fontStyle: FontStyle.italic, // Speed look
                              ),
                            ),
                            if (_fabService.priceText.isNotEmpty) ...[
                              Container(
                                height: 16, // Smaller divider
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                width: 1,
                                color: Colors.white38,
                              ),
                              Text(
                                _fabService.priceText, 
                                style: const TextStyle(
                                  fontSize: 14, // Smaller price
                                  color: Color(0xFFFF1744),
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                )
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF121212).withOpacity(0.9),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(0, Icons.home_rounded, 'HOME'),
                  _buildNavItem(1, Icons.grid_view_rounded, 'GALLERY'),
                  _buildNavItem(2, Icons.calendar_month_rounded, 'SESSION'),
                  _buildNavItem(3, Icons.shopping_cart_rounded, 'CART'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with "Glow" if selected
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                boxShadow: isSelected ? [
                   BoxShadow(
                    color: const Color(0xFFFF1744).withOpacity(0.6),
                    blurRadius: 15,
                    spreadRadius: -2,
                  ) 
                ] : [],
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFFFF1744) : Colors.white54,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            // Text Label
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white38,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal,
                letterSpacing: 1.0,
              ),
            ),
            // "Speed Stripe" Indicator
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: isSelected ? 20 : 0,
              decoration: BoxDecoration(
                color: const Color(0xFFFF1744),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFFF1744).withOpacity(0.8), blurRadius: 4)
                ]
              ),
            )
          ],
        ),
      ),
    );
  }
}

class NavBarWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintRed = Paint()
      ..color = const Color(0xFFFF1744).withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final paintWhite = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final paintBlack = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Red Wave
    final pathRed = Path();
    pathRed.moveTo(0, size.height * 0.6);
    pathRed.quadraticBezierTo(
        size.width * 0.25, size.height * 0.8, size.width * 0.5, size.height * 0.5);
    pathRed.quadraticBezierTo(
        size.width * 0.75, size.height * 0.2, size.width, size.height * 0.6);
    canvas.drawPath(pathRed, paintRed);

    // White Wave (Opposite flow)
    final pathWhite = Path();
    pathWhite.moveTo(0, size.height * 0.4);
    pathWhite.quadraticBezierTo(
        size.width * 0.25, size.height * 0.1, size.width * 0.5, size.height * 0.4);
    pathWhite.quadraticBezierTo(
        size.width * 0.75, size.height * 0.7, size.width, size.height * 0.3);
    canvas.drawPath(pathWhite, paintWhite);
    
    // Black Shadow Wave (Deeper, lower)
    final pathBlack = Path();
    pathBlack.moveTo(0, size.height * 0.8);
    pathBlack.quadraticBezierTo(
        size.width * 0.5, size.height * 1.0, size.width, size.height * 0.8);
    canvas.drawPath(pathBlack, paintBlack);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
