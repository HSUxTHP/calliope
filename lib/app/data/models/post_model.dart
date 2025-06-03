class PostModel {
  final int? id;
  final DateTime created_at;
  final DateTime edited_at;
  final String name;
  final String? description;
  final String url;
  final int status;
  final int user_id;
  final int views;
  final String thumbnail;

  PostModel({
    this.id,
    required this.created_at,
    required this.edited_at,
    required this.name,
    this.description,
    required this.url,
    required this.status,
    required this.user_id,
    required this.views,
    required this.thumbnail,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      created_at: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      edited_at: DateTime.parse(json['edited_at'] ?? DateTime.now().toIso8601String()),
      name: json['name'] ?? '',
      description: json['description'],
      url: json['url'] ?? '',
      status: json['status'] ?? 0,
      user_id: json['user_id'] ?? 0,
      views: json['views'] ?? 0,
      thumbnail: json['thumbnail'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // if (id != null) 'id': id,
      'created_at': created_at.toIso8601String(),
      'edited_at': edited_at.toIso8601String(),
      'name': name,
      'description': description,
      'url': url,
      'status': status,
      'user_id': user_id,
      'views': views,
      'thumbnail': thumbnail,
    };
  }
}