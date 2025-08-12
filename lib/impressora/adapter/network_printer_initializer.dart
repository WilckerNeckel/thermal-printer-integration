// import 'package:app/impressora/adapter/sunmi_printerx.dart';
import 'package:app/impressora/adapter/network_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

final networkPrinter = NetWorkPrinterAdapter(paperSize: PaperSize.mm80);
Future<void> initNetworkPrinter() async {
  try {
    await networkPrinter.init();
  } catch (e) {
    print("PROBLEMA AO INICIAR IMPRESSORA DE REDE ${e.toString()}");
  }
}
