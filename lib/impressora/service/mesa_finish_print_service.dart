import 'package:app/impressora/example/venda_mesa_entity.dart';
import 'package:app/impressora/port/thermal_printer.dart';
import 'package:app/impressora/utils/flex_col.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:diacritic/diacritic.dart';
import 'package:intl/intl.dart';

class MesaFinishPrintService {
  final ThermalPrinter _printer;

  MesaFinishPrintService({required ThermalPrinter printer})
    : _printer = printer;

  Future<void> print(VendaMesaEntity mesa) async {
    List<int> printing = _printer.createNewPrinting();

    printing += _makeEmpresaName(mesa);
    printing += _printer.addSkipLines(1);
    printing += _makeMesaIdentifier(mesa);
    printing += _makeWarning();
    printing += _printer.addSkipLines(1);
    printing += _makeVendaInf(mesa);
    printing += _makeBody(mesa);
    printing += _makePaymentSummary(mesa);
    printing += _printer.addSkipLines(1);
    printing += _makeFooter();

    printing += _printer.addCutPaper();

    await _printer.sendPrint(printing);
  }

  List<int> _makeBody(VendaMesaEntity mesa) {
    List<int> body = [];
    body += _makeBodyHeader(mesa);
    body += _makeProdutosLancadosList(mesa);

    return body;
  }

  List<int> _makeBodyHeader(VendaMesaEntity mesa) {
    List<int> header = [];
    // header
    header += _printer.addDivider();

    final headerCols = [
      FlexCol(
        text: "QTD",
        units: 2,
        styles: PosStyles(bold: true),
        maxLines: 2,
      ),
      FlexCol(text: "PRODUTO", units: 4, styles: PosStyles(bold: true)),
      FlexCol(
        text: "VALOR UN.",
        units: 3,
        styles: PosStyles(bold: true),
        maxLines: 2,
      ),
      FlexCol(
        text: "VALOR TOT.",
        units: 3,
        styles: PosStyles(bold: true),
        maxLines: 2,
      ),
    ];

    header += _printer.addRow(headerCols);
    header += _printer.addDivider();

    return header;
  }

  List<int> _makeProdutosLancadosList(VendaMesaEntity mesa) {
    List<int> produtosLancados = [];

    for (final produto in mesa.produtosLancados) {
      List<FlexCol> produtoRow = [];

      produtoRow.add(
        FlexCol(
          text: produto.quantidade.toString(),
          units: 2,
          maxLines: 2,
          styles: PosStyles(bold: true),
        ),
      );

      produtoRow.add(
        FlexCol(
          text: removeDiacritics(produto.nome),
          units: 4,
          maxLines: 3,
          styles: PosStyles(bold: true),
        ),
      );

      produtoRow.add(
        FlexCol(
          text: removeDiacritics(produto.valorUnitario.toString()),
          units: 3,
          maxLines: 3,
          styles: PosStyles(bold: true),
        ),
      );

      produtoRow.add(
        FlexCol(
          text: removeDiacritics(produto.valorFinal.toString()),
          units: 3,
          maxLines: 3,
          styles: PosStyles(bold: true),
        ),
      );
      produtosLancados += _printer.addRow(produtoRow);
    }
    produtosLancados += _printer.addDivider();
    produtosLancados += _printer.addDivider();

    return produtosLancados;
  }

  List<int> _makeVendaInf(VendaMesaEntity mesa) {
    List<int> mesaInf = [];
    if (mesa.cpfCliente != null) {
      mesaInf += _makeClientIdentifier(mesa);
    }

    mesaInf += _printer.addText(
      text: "H. FIN: ${_formatDate(DateTime.now())}",
      styles: PosStyles(bold: true),
    );

    // atendente
    mesaInf += _printer.addText(
      text: "ATEND.: ${removeDiacritics(mesa.atendente)}",
      styles: PosStyles(bold: true),
    );

    return mesaInf;
  }

  List<int> _makeClientIdentifier(VendaMesaEntity mesa) {
    List<int> clientIdentifier = [];

    String clientText = "CPF/CNPJ do consumidor: ${mesa.cpfCliente}";
    clientIdentifier += _printer.addText(
      text: clientText,
      styles: PosStyles(bold: true, align: PosAlign.center),
    );

    return clientIdentifier;
  }

  List<int> _makeEmpresaName(VendaMesaEntity mesa) {
    List<int> empresaName = [];

    empresaName += _printer.addRow([
      FlexCol(
        text: removeDiacritics(mesa.nomeEmpresa),
        units: 12,
        maxLines: 2,
        styles: PosStyles(
          bold: true,
          align: PosAlign.center,
          width: PosTextSize.size2,
          height: PosTextSize.size2,
        ),
      ),
    ]);

    return empresaName;
  }

  List<int> _makeMesaIdentifier(VendaMesaEntity mesa) {
    List<int> mesaIdentifier = [];

    mesaIdentifier += _printer.addText(
      text: "MESA ${mesa.numeroMesa}",
      styles: PosStyles(
        align: PosAlign.center,
        width: PosTextSize.size2,
        height: PosTextSize.size2,
        reverse: true,
      ),
    );

    return mesaIdentifier;
  }

  List<int> _makePaymentSummary(VendaMesaEntity mesa) {
    List<int> paymentSummary = [];

    paymentSummary += _printer.addRow([
      FlexCol(
        text: "TOTAL: ",
        units: 6,
        styles: PosStyles(align: PosAlign.left, bold: true),
      ),

      FlexCol(
        text: mesa.valorTotal.toString(),
        units: 6,
        styles: PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);

    for (final payment in mesa.pagamentos) {
      List<FlexCol> paymentRow = [];
      paymentRow.add(
        FlexCol(
          text: removeDiacritics(payment.meioPagamento),
          units: 6,
          styles: PosStyles(align: PosAlign.left, bold: true),
        ),
      );

      paymentRow.add(
        FlexCol(
          text: payment.valor.toString(),
          units: 6,
          styles: PosStyles(align: PosAlign.right, bold: true),
        ),
      );

      paymentSummary += _printer.addRow(paymentRow);
    }

    paymentSummary += _printer.addRow([
      FlexCol(text: "", styles: PosStyles(), units: 6),
      FlexCol(
        text: "------",
        styles: PosStyles(align: PosAlign.right, bold: true),
        units: 6,
      ),
    ]);

    paymentSummary += _printer.addRow([
      FlexCol(
        text: "TOTAL PAGO: ",
        units: 6,
        styles: PosStyles(align: PosAlign.left, bold: true),
      ),

      FlexCol(
        text: mesa.valorTotal.toString(),
        units: 6,
        styles: PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);

    return paymentSummary;
  }

  List<int> _makeWarning() {
    List<int> mesaIdentifier = [];

    mesaIdentifier += _printer.addText(
      text: "*** NAO E DOCUMENTO FISCAL ***",
      styles: PosStyles(align: PosAlign.center),
    );

    return mesaIdentifier;
  }

  String _formatDate(DateTime date) =>
      DateFormat('dd/MM HH:mm:ss').format(date);

  List<int> _makeFooter() {
    List<int> mesaIdentifier = [];

    mesaIdentifier += _printer.addText(
      text: "JIFFY sistema Inteligente de gestao empresarial - (65) 99293-4536",
      styles: PosStyles(align: PosAlign.center),
    );

    return mesaIdentifier;
  }
}
