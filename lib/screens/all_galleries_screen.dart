import 'package:flutter/material.dart';
import '../models/gallery_model.dart';
import '../services/api_service.dart';
import 'gallery_detail_screen.dart';

class AllGalleriesScreen extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;

  const AllGalleriesScreen({super.key, this.categoryId, this.categoryName});

  @override
  State<AllGalleriesScreen> createState() => _AllGalleriesScreenState();
}

class _AllGalleriesScreenState extends State<AllGalleriesScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Gallery>> futureGalleries;

  @override
  void initState() {
    super.initState();
    futureGalleries = apiService.fetchGalleries(categoryId: widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Dark background
      appBar: AppBar(
        title: Text(widget.categoryName ?? 'All Galleries', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: widget.categoryId != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: FutureBuilder<List<Gallery>>(
        future: futureGalleries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No galleries found.', style: TextStyle(color: Colors.white)));
          }

          return GridView.builder(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100), // Extra bottom padding for navbar
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 columns
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8, // Taller cards
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final gallery = snapshot.data![index];
              return _buildGalleryCard(context, gallery);
            },
          );
        },
      ),
    );
  }

  Widget _buildGalleryCard(BuildContext context, Gallery gallery) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryDetailScreen(galleryId: gallery.id, galleryTitle: gallery.title),
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
                child: gallery.thumbnail.isNotEmpty
                    ? Image.network(
                        gallery.thumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                      )
                    : const Center(child: Icon(Icons.image, color: Colors.grey)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gallery.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${gallery.count} Images',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
