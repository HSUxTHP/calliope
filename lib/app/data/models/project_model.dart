import 'package:hive/hive.dart';

part 'project_model.g.dart';

@HiveType(typeId: 1)
class ProjectModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  DateTime created_at;

  @HiveField(2)
  DateTime edited_at;

  @HiveField(3)
  String name;

  @HiveField(4)
  int status;

  @HiveField(5)
  String? thumbnail;

  ProjectModel({
    required this.id,
    required this.created_at,
    required this.edited_at,
    required this.name,
    required this.status,
    this.thumbnail,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      created_at: DateTime.parse(json['created_at']),
      edited_at: DateTime.parse(json['edited_at']),
      name: json['name'],
      status: json['status'],
      thumbnail: json['thumbnail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': created_at.toIso8601String(),
      'edited_at': edited_at.toIso8601String(),
      'name': name,
      'status': status,
      'thumbnail': thumbnail,
    };
  }
}