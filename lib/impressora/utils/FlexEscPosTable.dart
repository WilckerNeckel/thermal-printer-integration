import 'package:app/impressora/utils/flex_col.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

/// Defaults; override if your printer differs.
const int defaultCpl58 = 32;
const int defaultCpl80 = 48;

/// Helper to manage a table-like print with wrapping & maxLines.
class EscPosFlexTable {
  final Generator g;
  final PaperSize paperSize;

  /// Override these if your printer’s CPL differs
  final int? overrideCpl58;
  final int? overrideCpl80;

  EscPosFlexTable(
    this.g, {
    required this.paperSize,
    this.overrideCpl58,
    this.overrideCpl80,
  });

  int get totalUnits => (paperSize == PaperSize.mm58) ? 12 : 24;

  int get baseCpl {
    if (paperSize == PaperSize.mm58) return overrideCpl58 ?? defaultCpl58;
    return overrideCpl80 ?? defaultCpl80;
    // Note: bold/underline typically don't change width; width scale does.
  }

  /// Compute max characters for a column, accounting for its unit share and width scaling.
  int _maxCharsForColumn(int colUnits, int textWidthScale) {
    final perUnit = baseCpl / totalUnits;
    final raw = (perUnit * colUnits) / (textWidthScale.clamp(1, 8));
    final v = raw.floor();
    return v < 1 ? 1 : v;
  }

  /// Simple word wrap with hard-break for long tokens.
  List<String> _wrapByWords(String text, int maxChars) {
    if (text.isEmpty) return [''];
    final words = text.split(RegExp(r'\s+'));
    final lines = <String>[];
    var cur = StringBuffer();

    void pushCur() {
      if (cur.isNotEmpty) {
        lines.add(cur.toString());
        cur = StringBuffer();
      }
    }

    for (final w in words) {
      if (w.length > maxChars) {
        // close current line first
        pushCur();
        // break long token
        for (var i = 0; i < w.length; i += maxChars) {
          final end = (i + maxChars < w.length) ? i + maxChars : w.length;
          lines.add(w.substring(i, end));
        }
      } else if (cur.isEmpty) {
        cur.write(w);
      } else if (cur.length + 1 + w.length <= maxChars) {
        cur.write(' ');
        cur.write(w);
      } else {
        pushCur();
        cur.write(w);
      }
    }
    pushCur();
    return lines.isEmpty ? [''] : lines;
  }

  /// Trim a wrapped list to maxLines and add ellipsis on the last line if truncated.
  List<String> _enforceMaxLines(
    List<String> wrapped,
    int maxLines,
    int maxChars,
  ) {
    if (wrapped.length <= maxLines) return wrapped;
    final trimmed = wrapped.take(maxLines).toList();
    // add ellipsis to the last line
    final last = trimmed.last;
    const ell = '...';
    if (last.length >= ell.length) {
      // replace end with ellipsis
      final keep = (last.length - ell.length).clamp(0, maxChars);
      trimmed[trimmed.length - 1] = last.substring(0, keep) + ell;
    } else {
      trimmed[trimmed.length - 1] = ell;
    }
    return trimmed;
  }

  /// Add one logical row that may expand to multiple physical rows due to wrapping.
  /// Returns the bytes appended so you can accumulate.
  List<int> addRow(List<FlexCol> cols) {
    // 1) Wrap each column independently
    final wrappedPerCol = <int, List<String>>{};
    final widthsPerCol = <int, int>{}; // characters per line for each column
    for (var i = 0; i < cols.length; i++) {
      final c = cols[i];
      final maxChars = _maxCharsForColumn(c.units, c.textWidthScale);
      widthsPerCol[i] = maxChars;
      final wrapped = _wrapByWords(c.text, maxChars);
      final bounded = _enforceMaxLines(wrapped, c.maxLines, maxChars);
      wrappedPerCol[i] = bounded;
    }

    // 2) Determine how many physical lines we need
    var physicalLines = 0;
    for (final lines in wrappedPerCol.values) {
      if (lines.length > physicalLines) physicalLines = lines.length;
    }

    // 3) Emit rows line by line
    List<int> out = [];
    for (var lineIdx = 0; lineIdx < physicalLines; lineIdx++) {
      final posCols = <PosColumn>[];
      for (var i = 0; i < cols.length; i++) {
        final c = cols[i];
        final slice = wrappedPerCol[i]!;
        final lineText = (lineIdx < slice.length) ? slice[lineIdx] : '';
        posCols.add(
          PosColumn(
            text: lineText,
            width: c.units,
            styles: c.styles.copyWith(
              height: PosTextSize.size1,
              // width multiplier should be set via styles if you’re using it;
              // many esc_pos utils use styles.height/width for scaling.
              // Here we assume width scaling is handled in styles,
              // and we only used textWidthScale to compute capacity.
            ),
          ),
        );
      }
      out += g.row(posCols);
    }
    return out;
  }
}
