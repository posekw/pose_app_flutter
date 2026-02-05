class GalleryImage {
  final String id;
  final String title;
  final String url;
  final int width;
  final int height;
  final List<String> tags;

  GalleryImage({
    required this.id,
    required this.title,
    required this.url,
    required this.width,
    required this.height,
    required this.tags,
  });

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      width: json['width'] is int ? json['width'] : (int.tryParse(json['width']?.toString() ?? '0') ?? 0),
      height: json['height'] is int ? json['height'] : (int.tryParse(json['height']?.toString() ?? '0') ?? 0),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    );
  }
}

class ProductVariation {
  final String id;
  final String name;
  final double price;
  final double regularPrice;

  ProductVariation({
    required this.id,
    required this.name,
    required this.price,
    required this.regularPrice,
  });

  factory ProductVariation.fromJson(Map<String, dynamic> json) {
    return ProductVariation(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      regularPrice: (json['regular_price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class GalleryDetail {
  final int id;
  final String title;
  final int count;
  final List<GalleryImage> images;
  final List<ProductVariation> variations;
  final bool isAlbum; // New field

  GalleryDetail({
    required this.id,
    required this.title,
    required this.count,
    required this.images,
    required this.variations,
    this.isAlbum = false, // Default to false
  });

  factory GalleryDetail.fromJson(Map<String, dynamic> json) {
    var list = json['images'] as List;
    List<GalleryImage> imagesList = list.map((i) => GalleryImage.fromJson(i)).toList();

    var varList = json['variations'] as List? ?? [];
    List<ProductVariation> variationsList = varList.map((i) => ProductVariation.fromJson(i)).toList();

    return GalleryDetail(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      count: json['count'] is int ? json['count'] : int.tryParse(json['count'].toString()) ?? 0,
      images: imagesList,
      variations: variationsList,
      isAlbum: json['is_album'] ?? false, // Check API flag
    );
  }
}
