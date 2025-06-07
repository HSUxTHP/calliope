import 'package:hive/hive.dart';
import 'layer_model.dart';

part 'frame_model.g.dart';

@HiveType(typeId: 4)
class FrameModel extends HiveObject {
  @HiveField(0)
  List<LayerModel> layers;

  @HiveField(1)
  bool isHidden; // <== THÊM DÒNG NÀY

  FrameModel({
    int numberOfLayers = 3,
    this.isHidden = false, // <== THÊM VÀ GÁN MẶC ĐỊNH
  }) : layers = List.generate(numberOfLayers, (_) => LayerModel());

  FrameModel.copyFrom(this.layers, {this.isHidden = false});

  FrameModel copy() => FrameModel.copyFrom(
    layers.map((layer) => layer.copy()).toList(),
    isHidden: isHidden, // <== ĐẢM BẢO COPY GIÁ TRỊ
  );

  factory FrameModel.fromJson(Map<String, dynamic> json) {
    return FrameModel.copyFrom(
      (json['layers'] as List<dynamic>)
          .map((layer) => LayerModel.fromJson(layer as Map<String, dynamic>))
          .toList(),
      isHidden: json['isHidden'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'layers': layers.map((layer) => layer.toJson()).toList(),
      'isHidden': isHidden,
    };
  }
}
