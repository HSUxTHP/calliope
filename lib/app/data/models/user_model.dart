import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  DateTime editedAt;

  @HiveField(3)
  String name;

  @HiveField(4)
  String bio;

  @HiveField(5)
  String email;

  @HiveField(6)
  String? avatarUrl;

  UserModel({
    required this.id,
    required this.createdAt,
    required this.editedAt,
    required this.name,
    required this.bio,
    required this.email,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      editedAt: DateTime.parse(json['editedAt'] as String),
      name: json['name'] as String,
      bio: json['bio'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'editedAt': editedAt.toIso8601String(),
      'name': name,
      'bio': bio,
      'email': email,
      'avatarUrl': avatarUrl,
    };
  }
}


