import 'package:flutter/material.dart';
import '../models/hierarchy_models.dart';
import '../services/api_service.dart';
import 'track_selection_screen.dart';
import 'all_galleries_screen.dart';

class DestinationsScreen extends StatefulWidget {
  const DestinationsScreen({super.key});

  @override
  State<DestinationsScreen> createState() => _DestinationsScreenState();
}

class _DestinationsScreenState extends State<DestinationsScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Destination>> futureDestinations;

  @override
  void initState() {
    super.initState();
    futureDestinations = apiService.fetchDestinations();
  }

  Future<void> _refresh() async {
    setState(() {
      futureDestinations = apiService.fetchDestinations();
    });
    await futureDestinations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('Destinations', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Destination>>(
        future: futureDestinations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF1744)));
          } else if (snapshot.hasError) {
            // Keep RefreshIndicator even on error so they can retry
            return RefreshIndicator(
              onRefresh: _refresh,
              color: const Color(0xFFFF1744),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red))),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              color: const Color(0xFFFF1744),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                   SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: const Center(child: Text('No destinations found.', style: TextStyle(color: Colors.white))),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            color: const Color(0xFFFF1744),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(), // Ensure scroll for refresh
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85, 
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final destination = snapshot.data![index];
                return _buildCard(context, destination);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, Destination dest) {
    return GestureDetector(
      onTap: () {
        // Special check for "Sessions" -> Open directly as galleries even if API says hasChildren
        final isSessions = dest.name.toLowerCase() == 'sessions' || dest.name == 'جلسات';
        
        if (dest.hasChildren && !isSessions) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrackSelectionScreen(parentId: dest.id, parentName: dest.name),
            ),
          );
        } else {
          // Direct access for flat categories or forced "Sessions"
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AllGalleriesScreen(categoryId: dest.id, categoryName: dest.name),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: dest.thumbnail.isNotEmpty
                    ? Image.network(
                        dest.thumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: Colors.grey[900], child: const Icon(Icons.public, color: Colors.white24, size: 50)),
                      )
                    : Container(color: Colors.grey[900], child: const Icon(Icons.public, color: Colors.white24, size: 50)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                   Text(
                    dest.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dest.count} Galleries',
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
