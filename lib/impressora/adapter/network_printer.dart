import 'dart:typed_data';

import 'package:app/impressora/enum/print_alignment.dart';
import 'package:app/impressora/port/thermal_printer.dart';
import 'package:app/impressora/utils/FlexEscPosTable.dart';
import 'package:app/impressora/utils/flex_col.dart';
import 'package:sunmi_printerx/sunmi_printerx.dart';
import 'package:sunmi_printerx/printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:sunmi_printerx/align.dart';

// Aqui foi usado 2 pacotes principais, SunmiPrinterX e esc_pos_utils
class SunmiPrinter implements ThermalPrinter {
  final SunmiPrinterX _plugin = SunmiPrinterX();
  Printer? _printer;
  PaperSize paperSize;
  late Generator _generator;

  SunmiPrinter({required this.paperSize});

  Future<void> init({bool Function(Printer p)? choose}) async {
    final printers = await _plugin.getPrinters();
    if (printers.isEmpty) {
      throw StateError('No Sunmi printers found');
    }
    _printer = choose != null
        ? (printers.firstWhere(choose, orElse: () => printers.first))
        : printers.first;

    final profile = await CapabilityProfile.load();
    _generator = Generator(paperSize, profile);
  }

  @override
  List<int> createNewPrinting() {
    List<int> newPrinting = [];
    newPrinting += _generator.reset();
    return newPrinting;
  }

  @override
  List<int> addText({required String text, required PosStyles styles}) {
    List<int> bText = [];

    bText += _generator.reset();

    bText += _generator.text(text, styles: styles);
    return bText;
  }

  @override
  Future<void> printText(String text, bool bold, PrintAlignment align) async {
    final printer = _getPrinter();
    final translatedAlign = _translatePrinterXAlignment(align);
    await printer.printText(text, bold: bold, align: translatedAlign);
  }

  @override
  List<int> addRow(List<FlexCol> cols) {
    final table = EscPosFlexTable(_generator, paperSize: paperSize);

    return table.addRow(cols);
  }

  @override
  List<int> addDivider() {
    return _generator.hr();
  }

  @override
  List<int> addCutPaper() {
    return _generator.cut();
  }

  @override
  List<int> addSkipLines(int linesToSkip) {
    return _generator.emptyLines(linesToSkip);
  }

  @override
  Future<void> sendPrint(List<int> bytesToPrint) async {
    final p = _getPrinter();

    await p.printEscPosCommands(Uint8List.fromList(bytesToPrint));
  }

  Printer _getPrinter() {
    final p = _printer;
    if (p == null) {
      throw StateError('Printer not initialized. Call init() first.');
    }
    return p;
  }

  Align _translatePrinterXAlignment(PrintAlignment align) {
    switch (align) {
      case PrintAlignment.left:
        return Align.left;
      case PrintAlignment.center:
        return Align.center;
      case PrintAlignment.right:
        return Align.right;
    }
  }
}