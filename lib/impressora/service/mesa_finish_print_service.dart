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

    printing += _makeHeader(mesa);
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
        text: "Hora",
        units: 3,
        styles: PosStyles(bold: true),
        maxLines: 2,
      ),
      FlexCol(
        text: "Qtd",
        units: 2,
        styles: PosStyles(bold: true),
        maxLines: 2,
      ),
      FlexCol(text: "Produto", units: 4, styles: PosStyles(bold: true)),
      FlexCol(
        text: "Valor Tot.",
        units: 3,
        styles: PosStyles(bold: true, align: PosAlign.right),
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
          text: _dateToHour(produto.dataLancamento),
          units: 3,
          maxLines: 3,
          styles: PosStyles(bold: true),
        ),
      );

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
          text: produto.valorFinal.toString(),
          units: 3,
          maxLines: 3,
          styles: PosStyles(bold: true, align: PosAlign.right),
        ),
      );
      produtosLancados += _printer.addRow(produtoRow);
    }
    produtosLancados += _printer.addDivider();

    return produtosLancados;
  }

  List<int> _makeVendaInf(VendaMesaEntity mesa) {
    List<int> vendaInf = [];
    vendaInf += _makeVendaIdentifier(mesa);
    vendaInf += _makeWarning();
    vendaInf += _printer.addSkipLines(1);

    if (mesa.cpfCliente != null) {
      vendaInf += _makeClientIdentifier(mesa);
    }

    // codigo venda
    vendaInf += _printer.addText(
      text: "CODIGO V.: ${mesa.codigoVenda}",
      styles: PosStyles(),
    );

    // atendente
    vendaInf += _printer.addText(
      text: "ATEND.: ${removeDiacritics(mesa.atendente)}",
      styles: PosStyles(),
    );

    vendaInf += _printer.addText(
      text: "H. FIN: ${_formatDate(DateTime.now())}",
      styles: PosStyles(),
    );

    vendaInf += _printer.addText(
      text: "TEMPO PERMANENCIA: ${_getPermanencia()}",
      styles: PosStyles(),
    );

    return vendaInf;
  }

  List<int> _makeClientIdentifier(VendaMesaEntity mesa) {
    List<int> clientIdentifier = [];

    String? cpfCnpj = mesa.cnpjCliente ?? mesa.cpfCliente;

    if (cpfCnpj != null) {
      String clientText = "CPF/CNPJ do consumidor: ${mesa.cpfCliente}";
      clientIdentifier += _printer.addText(
        text: clientText,
        styles: PosStyles(align: PosAlign.left),
      );
    }

    return clientIdentifier;
  }

  List<int> _makeHeader(VendaMesaEntity mesa) {
    List<int> header = [];

    // nome empresa
    header += _printer.addText(
      text: removeDiacritics(mesa.nomeEmpresa),
      styles: PosStyles(
        bold: true,
        align: PosAlign.center,
        width: PosTextSize.size1,
        height: PosTextSize.size1,
      ),
    );

    header += _printer.addText(
      text: "CNPJ: ${mesa.cnpjEmpresa}",
      styles: PosStyles(
        bold: true,
        align: PosAlign.center,
        width: PosTextSize.size1,
        height: PosTextSize.size1,
      ),
    );

    // cnpj + I.E
    if (mesa.inscricaoEstadual != null) {
      header += _printer.addText(
        text: "I.E: ${mesa.inscricaoEstadual!}",
        styles: PosStyles(
          bold: true,
          align: PosAlign.center,
          width: PosTextSize.size1,
          height: PosTextSize.size1,
        ),
      );
    }

    return header;
  }

  List<int> _makeVendaIdentifier(VendaMesaEntity mesa) {
    List<int> mesaIdentifier = [];

    mesaIdentifier += _printer.addText(
      text: "MESA ${mesa.numeroMesa}",
      styles: PosStyles(
        align: PosAlign.center,
        width: PosTextSize.size2,
        height: PosTextSize.size2,
        bold: true,
      ),
    );

    return mesaIdentifier;
  }

  List<int> _makePaymentSummary(VendaMesaEntity mesa) {
    List<int> paymentSummary = [];

    paymentSummary += _printer.addRow([
      FlexCol(
        text: "TOTAL: ",
        units: 4,
        styles: PosStyles(
          align: PosAlign.left,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),

      FlexCol(
        text: mesa.valorTotal.toString(),
        units: 8,
        styles: PosStyles(
          align: PosAlign.right,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
    ]);

    paymentSummary += _printer.addSkipLines(1);

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
        units: 5,
        styles: PosStyles(align: PosAlign.left, bold: true),
      ),

      FlexCol(
        text: mesa.valorTotal.toString(),
        units: 7,
        styles: PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);

    if (mesa.troco != null && mesa.troco! > 0) {
      paymentSummary += _printer.addRow([
        FlexCol(
          text: "TROCO: ",
          units: 4,
          styles: PosStyles(align: PosAlign.left, bold: true),
        ),

        FlexCol(
          text: mesa.troco.toString(),
          units: 8,
          styles: PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
    }

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

  String _dateToHour(DateTime date) => DateFormat('HH:mm').format(date);

  List<int> _makeFooter() {
    List<int> mesaIdentifier = [];

    mesaIdentifier += _printer.addText(
      text: "JIFFY sistema Inteligente de gestao empresarial - (65) 99293-4536",
      styles: PosStyles(align: PosAlign.center, underline: true),
    );

    return mesaIdentifier;
  }

  String _getPermanencia() {
    DateTime inicio = DateTime(2025, 8, 11, 14, 0); // 14:00
    DateTime fim = DateTime(2025, 8, 11, 15, 33); // 15:33

    Duration diff = fim.difference(inicio);

    // formata manualmente no formato HH:mm
    String horas = diff.inHours.toString().padLeft(2, '0');
    String minutos = (diff.inMinutes % 60).toString().padLeft(2, '0');
    String tempoFormatado = "$horas:$minutos";

    return tempoFormatado;
  }
}
