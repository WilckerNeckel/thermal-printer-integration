import 'package:app/impressora/port/thermal_printer.dart';
import 'package:app/impressora/utils/FlexEscPosTable.dart';
import 'package:app/impressora/utils/flex_col.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:sunmi_printerx/printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

// Aqui foi usado 2 pacotes principais, SunmiPrinterX e esc_pos_utils
class NetWorkPrinterAdapter implements ThermalPrinter {
  PaperSize paperSize;
  late Generator _generator;
  NetworkPrinter? _printer;

  NetWorkPrinterAdapter({required this.paperSize});

  Future<void> init({bool Function(Printer p)? choose}) async {
    final profile = await CapabilityProfile.load();
    _generator = Generator(paperSize, profile);
    _printer = NetworkPrinter(paperSize, profile);
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
  Future<void> printText(String text, PosStyles styles) async {
    // final printer = _getPrinter();
    // final translatedAlign = _translatePrinterXAlignment(align);
    // await printer.printText(text, bold: bold, align: translatedAlign);

    final printer = await _getPrinter();
    final PosPrintResult res = await printer.connect(
      "192.168.1.14",
      port: 9100,
    );
    if (res == PosPrintResult.success) {
      printer.text(text, styles: styles);
    } else {
      throw Exception("ERRRRROOOO DE CONEXÃO COM IMPRESSORA");
    }
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
    final printer = await _getPrinter();
    printer.rawBytes(bytesToPrint);

    // await p.printEscPosCommands(Uint8List.fromList(bytesToPrint));
  }

  Future<NetworkPrinter> _getPrinter() async {
    final printer = _printer;
    if (printer == null) {
      throw StateError('Printer not initialized. Call init() first.');
    }
    final PosPrintResult res = await printer.connect(
      "192.168.1.14",
      port: 9100,
    );

    if (res != PosPrintResult.success) {
      throw Exception("ERRRRROOOO DE CONEXÃO COM IMPRESSORA");
    }
    return printer;
  }
}
