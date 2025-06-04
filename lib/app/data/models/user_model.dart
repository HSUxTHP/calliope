import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  DateTime created_at;

  @HiveField(2)
  DateTime edited_at;

  @HiveField(3)
  String name;

  @HiveField(4)
  String bio;

  @HiveField(5)
  String email;

  @HiveField(6)
  String? avatar_url;

  UserModel({
    this.id,
    required this.created_at,
    required this.edited_at,
    required this.name,
    required this.bio,
    required this.email,
    this.avatar_url,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      created_at: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      edited_at: DateTime.parse(json['edited_at'] ?? DateTime.now().toIso8601String()),
      name: json['name'] ?? '',
      bio: json['bio'] ?? '',
      email: json['email'] ?? '',
      avatar_url: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'created_at': created_at.toIso8601String(),
      'edited_at': edited_at.toIso8601String(),
      'name': name,
      'bio': bio,
      'email': email,
      'avatar_url': avatar_url,
    };
  }
}


