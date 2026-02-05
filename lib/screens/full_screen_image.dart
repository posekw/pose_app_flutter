import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/gallery_detail_model.dart';
import '../models/gallery_detail_model.dart';
import '../models/cart_item_model.dart';
import '../services/cart_service.dart';

import '../services/fab_control_service.dart';

import 'package:screen_protector/screen_protector.dart';

class FullScreenImageScreen extends StatefulWidget {
  final List<GalleryImage> images;
  final int initialIndex;
  final List<ProductVariation> variations;

  const FullScreenImageScreen({
    super.key, 
    required this.images,
    required this.initialIndex,
    required this.variations,
  });

  @override
  State<FullScreenImageScreen> createState() => _FullScreenImageScreenState();
}

class _FullScreenImageScreenState extends State<FullScreenImageScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _enableSecureMode();
    // Enable Global Add to Cart FAB
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFab();
    });
  }

  @override
  void dispose() {
    _disableSecureMode();
    _pageController.dispose();
    // Reset FAB
    FabControlService().resetToDefault();
    super.dispose();
  }

  void _updateFab() {
    FabControlService().setAddToCartMode(
      onPressed: () => _showAddToCartModal(context),
      price: widget.variations.isNotEmpty ? '${widget.variations.first.price} KWD' : '',
    );
  }

  Future<void> _enableSecureMode() async {
    try {
      await ScreenProtector.preventScreenshotOn();
    } catch (e) {
      print('Error verifying security: $e');
    }
  }

  Future<void> _disableSecureMode() async {
    try {
      await ScreenProtector.preventScreenshotOff();
    } catch (e) {
      print('Error clearing security: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              // No need to update FAB here as the action refers to _currentIndex which is now updated
              // and the modal uses widget.variations which are constant for the gallery, 
              // and _showAddToCartModal uses _currentIndex to pick the image.
            },
            itemBuilder: (context, index) {
              final image = widget.images[index];
              return InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4,
                child: CachedNetworkImage(
                  imageUrl: image.url,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: Colors.white)),
                  errorWidget: (context, url, ex) => const Center(
                      child: Icon(Icons.broken_image, color: Colors.white, size: 50)),
                ),
              );
            },
          ),
          
          // Watermark Overlay
          IgnorePointer(
            child: Center(
              child: Opacity(
                opacity: 0.15, 
                child: CachedNetworkImage(
                  imageUrl: 'https://posekw.com/wp-content/uploads/2026/01/logo-watermark-pose-2.png',
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const SizedBox(),
                  errorWidget: (context, url, error) => const SizedBox(),
                ),
              ),
            ),
          ),
          // Pattern Watermark
          IgnorePointer(
            child: Opacity(
              opacity: 0.05,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemBuilder: (context, index) {
                  return Center(
                    child: Transform.rotate(
                      angle: -0.5,
                      child: const Text(
                        'POSE',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddToCartModal(BuildContext context) {
    if (widget.variations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No price options available for this item.')),
      );
      return;
    }

    // Hide FAB while modal is open
    FabControlService().resetToDefault();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Option',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...widget.variations.map((v) => ListTile(
                title: Text(v.name, style: const TextStyle(color: Colors.white)),
                trailing: Text('${v.price} KWD', style: const TextStyle(color: Color(0xFFFF1744), fontWeight: FontWeight.bold)),
                onTap: () {
                  CartService().addToCart(widget.images[_currentIndex], v);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${v.name} added to cart'),
                      backgroundColor: const Color(0xFFFF1744), // Red
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              )),
              const SizedBox(height: 120), // Padding to clear the floating bottom bar
            ],
          ),
        );
      },
    ).whenComplete(() {
      // Restore FAB when modal closes, if we are still mounted
      if (mounted) {
        _updateFab();
      }
    });
  }
}
