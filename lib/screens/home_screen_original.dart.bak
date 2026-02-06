import 'package:flutter/material.dart';
import '../models/gallery_detail_model.dart';
import '../services/api_service.dart';
import 'full_screen_image.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Dark background
      body: CustomScrollView(
        slivers: [
          // Custom Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Color(0xFF1E1E1E)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Center align
                children: [
                  const Text(
                    'POSE MEDIA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      fontFamily: 'Segoe UI', 
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Motorsports Photography & Social Media',
                    style: TextStyle(
                      color: const Color(0xFFFF1744).withOpacity(0.9), // Red accent
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 30), // More space
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), // Larger badge
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF1744).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFF1744).withOpacity(0.3)),
                    ),
                    child: const Text(
                      'LAST EVENT', // UPPPERCASE
                      style: TextStyle(
                        color: Color(0xFFFF1744),
                        fontSize: 16, // Larger text
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Album Grid (ID 26242)
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
                    crossAxisCount: 1, // Full width (row)
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 20, // More space between rows
                    childAspectRatio: 1.5, // Wider aspect ratio
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final image = snapshot.data!.images[index];
                      return _buildImageTile(context, image, index, snapshot.data!); // Pass full detail for variations
                    },
                    childCount: snapshot.data!.images.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImageTile(BuildContext context, GalleryImage image, int index, GalleryDetail detail) {
    return GestureDetector(
      onTap: () {
        // Since Home shows an ALBUM (list of galleries), clicking an item (which is a sub-gallery)
        // should open that Gallery's details.
        // We stored the Sub-Gallery ID in image.id
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryDetailScreen(
              galleryId: int.parse(image.id), // The ID is the sub-gallery ID
              galleryTitle: image.title,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white.withOpacity(0.05),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
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
                  const Center(child: Icon(Icons.broken_image, size: 20, color: Colors.white24)),
            ),
            // Overlay with Title for clearer navigation
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                color: Colors.black.withOpacity(0.6),
                child: Text(
                  image.title,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
