class Gallery {
  final int id;
  final String title;
  final String thumbnail;
  final int count;
  final String date;

  Gallery({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.count,
    required this.date,
  });

  factory Gallery.fromJson(Map<String, dynamic> json) {
    return Gallery(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      count: json['count'] is int ? json['count'] : int.tryParse(json['count'].toString()) ?? 0,
      date: json['date'] ?? '',
    );
  }
}
