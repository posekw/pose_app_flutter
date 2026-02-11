import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/gallery_detail_model.dart';
import '../services/api_service.dart';
import 'gallery_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  late Future<GalleryDetail> futureDetail;
  final int lastEventAlbumId = 31758; // ID for "Last Event" Album (Fixed)

  @override
  void initState() {
    super.initState();
    futureDetail = apiService.fetchGalleryDetails(lastEventAlbumId);
  }

  // Contact URLs
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Dark background
      appBar: AppBar(
        title: const Text('POSE MEDIA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // Subtitle and LAST EVENT badge
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: const Color(0xFF1E1E1E),
              child: Column(
                children: [
                  Text(
                    'Motorsports Photography & Social Media',
                    style: TextStyle(
                      color: const Color(0xFFFF1744).withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF1744).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFF1744).withOpacity(0.3)),
                    ),
                    child: const Text(
                      'LAST EVENT',
                      style: TextStyle(
                        color: Color(0xFFFF1744),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Album Grid - Same style as Gallery (2 columns)
          FutureBuilder<GalleryDetail>(
            future: futureDetail,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: Color(0xFFFF1744))),
                );
              } else if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red))),
                );
              } else if (!snapshot.hasData || snapshot.data!.images.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No images found in this album.', style: TextStyle(color: Colors.white))),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 columns like Gallery
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8, // Same as Gallery
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final image = snapshot.data!.images[index];
                      return _buildGalleryCard(context, image);
                    },
                    childCount: snapshot.data!.images.length,
                  ),
                ),
              );
            },
          ),

          // Contact Buttons - Footer (below gallery)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Website
                  GestureDetector(
                    onTap: () => _launchUrl('https://posekw.com'),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.public, color: Colors.white, size: 20),
                        SizedBox(width: 6),
                        Text('Website', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                  // Instagram
                  GestureDetector(
                    onTap: () => _launchUrl('https://www.instagram.com/pose965'),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.photo_camera_outlined, color: Colors.white, size: 20),
                        SizedBox(width: 6),
                        Text('Instagram', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                  // WhatsApp
                  GestureDetector(
                    onTap: () => _launchUrl('https://wa.me/+96565033587'),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.phone, color: Colors.white, size: 20),
                        SizedBox(width: 6),
                        Text('WhatsApp', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Privacy Policy Link
          SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () => _launchUrl('https://posekw.com/privacy-policy/'),
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          
          // Bottom spacing for navbar
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  // Gallery Card - Same style as AllGalleriesScreen
  Widget _buildGalleryCard(BuildContext context, GalleryImage image) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryDetailScreen(
              galleryId: int.parse(image.id),
              galleryTitle: image.title,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  image.url,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.white24,
                        strokeWidth: 2,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                image.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
