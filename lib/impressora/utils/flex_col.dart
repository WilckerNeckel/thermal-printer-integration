import 'package:esc_pos_utils/esc_pos_utils.dart';

/// Column descriptor for flexible rows.
class FlexCol {
  final String text;

  /// Column width in "units". For mm58, total is 12; for mm80, total is 24.
  final int units;
  final PosStyles styles;

  /// Maximum wrapped lines this column may occupy. Extra content is ellipsized.
  final int maxLines;

  /// Optional text width multiplier (ESC/POS width scale). 1 = normal, 2 = double width, etc.
  final int textWidthScale;

  FlexCol({
    required this.text,
    required this.units,
    this.styles = const PosStyles(),
    this.maxLines = 1,
    this.textWidthScale = 1,
  });
}
