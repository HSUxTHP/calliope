import 'package:calliope/app/data/models/user_model.dart';

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
  UserModel? user;

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
    this.user,
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

  PostModel copyWith({
    int? id,
    DateTime? created_at,
    DateTime? edited_at,
    String? name,
    String? description,
    String? url,
    int? status,
    int? user_id,
    int? views,
    String? thumbnail,
  }) {
    return PostModel(
      id: id ?? this.id,
      created_at: created_at ?? this.created_at,
      edited_at: edited_at ?? this.edited_at,
      name: name ?? this.name,
      description: description ?? this.description,
      url: url ?? this.url,
      status: status ?? this.status,
      user_id: user_id ?? this.user_id,
      views: views ?? this.views,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }
}