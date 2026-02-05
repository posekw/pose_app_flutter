import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gallery_model.dart';
import '../models/gallery_model.dart';
import '../models/gallery_detail_model.dart';
import '../models/hierarchy_models.dart';

class ApiService {
  static const String baseUrl = 'https://posekw.com/wp-json/pose-app/v1';

  // Fetch Hierarchy: Destinations
  Future<List<Destination>> fetchDestinations() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/hierarchy/destinations'));
      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((dynamic item) => Destination.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load destinations');
      }
    } catch (e) {
      throw Exception('Error fetching destinations: $e');
    }
  }

  // Fetch Hierarchy: SubCategories
  Future<List<TrackCategory>> fetchSubCategories(int parentId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/hierarchy/categories?parent=$parentId'));
      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((dynamic item) => TrackCategory.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load subcategories');
      }
    } catch (e) {
      throw Exception('Error fetching subcategories: $e');
    }
  }

  // Fetch list of galleries
  Future<List<Gallery>> fetchGalleries({int? categoryId}) async {
    try {
      print('Fetching galleries...');
      String url = '$baseUrl/galleries';
      if (categoryId != null) {
        url += '?category=$categoryId';
      }
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'PoseApp/1.0', 'Accept': 'application/json'},
      );
      print('Galleries Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        List<Gallery> galleries = body.map((dynamic item) => Gallery.fromJson(item)).toList();
        return galleries;
      } else {
        print('Error body: ${response.body}');
        throw Exception('Failed to load galleries: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception fetching galleries: $e');
      throw Exception('Error fetching galleries: $e');
    }
  }

  // Fetch specific gallery details
  Future<GalleryDetail> fetchGalleryDetails(int id) async {
    try {
      print('Fetching details for ID: $id');
      final response = await http.get(
        Uri.parse('$baseUrl/gallery/$id'),
        headers: {'User-Agent': 'PoseApp/1.0', 'Accept': 'application/json'},
      );
      print('Details Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return GalleryDetail.fromJson(json.decode(response.body));
      } else {
        print('Error body: ${response.body}');
        throw Exception('Failed to load gallery details: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception fetching details: $e');
      throw Exception('Error fetching gallery details: $e');
    }
  }
  // Create Order
  Future<String> createOrder(List<Map<String, dynamic>> items) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'items': items}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['payment_url'];
      } else {
        throw Exception('Failed to create order: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }
}
