import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/gallery_detail_model.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import 'full_screen_image.dart';
import '../services/fab_control_service.dart';
import 'cart_screen.dart'; // Import CartScreen

class GalleryDetailScreen extends StatefulWidget {
  final int galleryId;
  final String galleryTitle;

  const GalleryDetailScreen({
    super.key,
    required this.galleryId,
    required this.galleryTitle,
  });

  @override
  State<GalleryDetailScreen> createState() => _GalleryDetailScreenState();
}

class _GalleryDetailScreenState extends State<GalleryDetailScreen> {
  final ApiService apiService = ApiService();
  final CartService cartService = CartService();
  late Future<GalleryDetail> futureDetail;

  String selectedTag = 'All';

  @override
  void initState() {
    super.initState();
    // Ensure FAB is hidden when entering this screen (in case it was left over)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FabControlService().resetToDefault();
    });
    futureDetail = apiService.fetchGalleryDetails(widget.galleryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.galleryTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          AnimatedBuilder(
            animation: cartService,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CartScreen()),
                      );
                    },
                  ),
                  if (cartService.items.isNotEmpty)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF1744), // Red
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '${cartService.items.length}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<GalleryDetail>(
        future: futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF1744)));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.images.isEmpty) {
            return const Center(child: Text('No images in this gallery.', style: TextStyle(color: Colors.white)));
          }

          final allImages = snapshot.data!.images;
          
          // Extract Unique Tags
          final Set<String> tags = {'All'};
          for (var img in allImages) {
            tags.addAll(img.tags);
          }
          final List<String> tagList = tags.toList();

          // Filter Images
          final displayImages = selectedTag == 'All' 
              ? allImages 
              : allImages.where((img) => img.tags.contains(selectedTag)).toList();

          return Stack(
            children: [
              // Background gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF121212),
                        const Color(0xFF1E1E1E),
                        const Color(0xFF000000),
                      ],
                    ),
                  ),
                ),
              ),
              
              Column(
                children: [
                  const SizedBox(height: 100), // Spacing for AppBar
                  
                  // Filter Bar
                  if (tagList.length > 1)
                    SizedBox(
                      height: 50,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: tagList.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final tag = tagList[index];
                          final isSelected = selectedTag == tag;
                          return ChoiceChip(
                            label: Text(tag, style: TextStyle(color: isSelected ? Colors.black : Colors.white)),
                            selected: isSelected,
                            selectedColor: const Color(0xFFFF1744), // RedAccent
                            backgroundColor: Colors.white.withOpacity(0.1),
                            onSelected: (bool selected) {
                              setState(() {
                                selectedTag = tag;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  
                  // Image Grid
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 160),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: displayImages.length,
                      itemBuilder: (context, index) {
                        return _buildImageCard(displayImages, index, snapshot.data!.variations);
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageCard(List<GalleryImage> images, int index, List<ProductVariation> variations) {
    final image = images[index];
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenImageScreen(
              images: images,
              initialIndex: index,
              variations: variations,
            ),
          ),
        ).then((_) {
          // Ensure FAB is reset when returning from full screen
          FabControlService().resetToDefault();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                image.url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.broken_image, color: Colors.white54),
                ),
              ),
              // Price Overlay
              Positioned(
                top: 8,
                right: 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: Colors.black.withOpacity(0.5),
                      child: Text(
                        variations.isNotEmpty ? '${variations.first.price} KWD' : '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
}
