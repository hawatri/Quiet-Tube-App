class Song {
  final String id;
  final String title;
  final String url;

  Song({
    required this.id,
    required this.title,
    required this.url,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
    };
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Song copyWith({
    String? id,
    String? title,
    String? url,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
    );
  }
}