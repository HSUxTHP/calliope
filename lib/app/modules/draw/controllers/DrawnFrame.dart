import '../../../data/models/DrawnLine_model.dart';

class DrawnFrame {
  final List<DrawnLine> lines;

  DrawnFrame({required this.lines});

  DrawnFrame copy() {
    return DrawnFrame(
      lines: lines.map((line) => line.copy()).toList(),
    );
  }
}
