import 'package:app/impressora/enum/print_alignment.dart';
import 'package:app/impressora/utils/flex_col.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

abstract class ThermalPrinter {
  Future<void> printText(String text, bool bold, PrintAlignment align);

  List<int> createNewPrinting();

  List<int> addText({required String text, required PosStyles styles});

  List<int> addRow(List<FlexCol> cols);

  List<int> addDivider();

  List<int> addCutPaper();

  List<int> addSkipLines(int linesToSkip);

  Future<void> sendPrint(List<int> printing);
}
