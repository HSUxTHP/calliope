import 'package:calliope/app/data/models/user_model.dart';

class CommentModel {
  final int id;
  final String data;
  final int id_user;
  final DateTime created_at;
  final int id_post;
  UserModel? user;

  CommentModel({
    required this.id,
    required this.data,
    required this.id_user,
    required this.created_at,
    required this.id_post,
    this.user,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      data: json['data'],
      id_user: json['id_user'],
      created_at: DateTime.parse(json['created_at']),
      id_post: json['id_post'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
      'id_user': id_user,
      'created_at': created_at.toIso8601String(),
      'id_post': id_post,
    };
  }


}