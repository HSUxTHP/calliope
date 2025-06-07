import 'package:hive/hive.dart';
import 'frame_model.dart';

part 'draw_project_model.g.dart';

@HiveType(typeId: 3)
class DrawProjectModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime updatedAt;

  @HiveField(3)
  List<FrameModel> frames;

  DrawProjectModel({
    required this.id,
    required this.name,
    required this.updatedAt,
    required this.frames,
  });

  factory DrawProjectModel.fromJson(Map<String, dynamic> json) {
    return DrawProjectModel(
      id: json['id'],
      name: json['name'],
      updatedAt: DateTime.parse(json['updatedAt']),
      frames: (json['frames'] as List)
          .map((e) => FrameModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'updatedAt': updatedAt.toIso8601String(),
      'frames': frames.map((f) => f.toJson()).toList(),
    };
  }
}
