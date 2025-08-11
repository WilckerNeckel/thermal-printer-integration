// import 'package:app/impressora/adapter/sunmi_printerx.dart';
import 'package:app/impressora/adapter/sunmi_printerx_esc_pos.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

// final printerAdapter = SunmiXPrinterAdapter();
// Future<void> setupPrinter() async {
//   try {
//     await printerAdapter.init();
//     // Optional: choose a specific printer
//     // await printerAdapter.init(choose: (p) => p.name.contains('V2'));
//     // debugPrint('Printer initialized');
//   } catch (e) {
//     // debugPrint('Failed to init printer: $e');
//   }
// }

final printerAdapter = SunmiPrinter(paperSize: PaperSize.mm58);
Future<void> setupPrinter() async {
  try {
    await printerAdapter.init();
    // Optional: choose a specific printer
    // await printerAdapter.init(choose: (p) => p.name.contains('V2'));
    // debugPrint('Printer initialized');
  } catch (e) {
    // debugPrint('Failed to init printer: $e');
  }
}
