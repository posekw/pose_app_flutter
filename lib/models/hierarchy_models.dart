class Destination {
  final int id;
  final String name;
  final int count;
  final String thumbnail;
  final bool hasChildren;

  Destination({
    required this.id,
    required this.name,
    required this.count,
    required this.thumbnail,
    this.hasChildren = true,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      count: json['count'] ?? 0,
      thumbnail: json['thumbnail'] ?? '',
      hasChildren: json['has_children'] ?? true, // Default true if missing
    );
  }
}

class TrackCategory {
  final int id;
  final String name;
  final int count;
  final String thumbnail;

  TrackCategory({
    required this.id,
    required this.name,
    required this.count,
    required this.thumbnail,
  });

  factory TrackCategory.fromJson(Map<String, dynamic> json) {
    return TrackCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      count: json['count'] ?? 0,
      thumbnail: json['thumbnail'] ?? '',
    );
  }
}
