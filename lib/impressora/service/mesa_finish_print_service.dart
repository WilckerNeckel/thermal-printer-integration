import 'package:app/impressora/example/venda_mesa_entity.dart';
import 'package:app/impressora/port/thermal_printer.dart';
import 'package:app/impressora/utils/flex_col.dart';
import 'package:app/impressora/utils/precoUtils.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:diacritic/diacritic.dart';
import 'package:intl/intl.dart';

class MesaFinishPrintService {
  final ThermalPrinter _printer;

  MesaFinishPrintService({required ThermalPrinter printer})
    : _printer = printer;

  Future<void> print(VendaMesaEntity venda) async {
    List<int> printing = _printer.createNewPrinting();

    printing += _makeHeader(venda);
    printing += _printer.addSkipLines(1);
    printing += _makeVendaInfTop(venda);
    printing += _makeBody(venda);
    printing += _makePaymentSummary(venda);
    printing += _printer.addSkipLines(1);
    printing += _makeVendaInfBottom(venda);
    printing += _printer.addSkipLines(1);
    printing += _makeFooter();

    printing += _printer.addCutPaper();

    await _printer.sendPrint(printing);
  }

  List<int> _makeHeader(VendaMesaEntity venda) {
    List<int> header = [];

    // nome empresa
    header += _printer.addText(
      text: removeDiacritics(venda.nomeEmpresa),
      styles: PosStyles(
        bold: true,
        align: PosAlign.center,
        width: PosTextSize.size1,
        height: PosTextSize.size1,
      ),
    );

    header += _printer.addText(
      text: "CNPJ: ${venda.cnpjEmpresa}",
      styles: PosStyles(
        bold: true,
        align: PosAlign.center,
        width: PosTextSize.size1,
        height: PosTextSize.size1,
      ),
    );

    // cnpj + I.E
    if (venda.inscricaoEstadual != null) {
      header += _printer.addText(
        text: "I.E: ${venda.inscricaoEstadual!}",
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

  List<int> _makeVendaInfTop(VendaMesaEntity venda) {
    List<int> vendaInf = [];
    vendaInf += _makeVendaIdentifier(venda);
    vendaInf += _makeWarning();
    vendaInf += _printer.addSkipLines(1);

    vendaInf += _printer.addText(
      text: "ATEND.: ${removeDiacritics(venda.atendente)}",
      styles: PosStyles(),
    );

    // codigo venda
    vendaInf += _printer.addText(
      text: "CODIGO V.: #${venda.codigoVenda}",
      styles: PosStyles(),
    );

    vendaInf += _printer.addText(
      text: "CODIGO TER.: #${venda.codTerminal}",
      styles: PosStyles(),
    );

    return vendaInf;
  }

  List<int> _makeVendaIdentifier(VendaMesaEntity venda) {
    List<int> vendaIdentifier = [];
    String tipoVenda = _getTipoVenda().toUpperCase();

    String vendaText =
        "$tipoVenda${_isMesa() ? ": ${venda.numeroMesa}" : ''} #${venda.numeroVenda}";

    vendaIdentifier += _printer.addText(
      text: vendaText,
      styles: PosStyles(
        align: PosAlign.center,
        width: PosTextSize.size1,
        height: PosTextSize.size1,
        bold: true,
      ),
    );

    return vendaIdentifier;
  }


  List<int> _makeWarning() {
    List<int> vendaWarning = [];

    vendaWarning += _printer.addText(
      text: "*** NAO E DOCUMENTO FISCAL ***",
      styles: PosStyles(align: PosAlign.center),
    );

    return vendaWarning;
  }


  List<int> _makeBody(VendaMesaEntity venda) {
    List<int> body = [];
    body += _makeBodyHeader();
    body += _makeProdutosLancadosList(venda);

    return body;
  }

  List<int> _makeBodyHeader() {
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
      FlexCol(text: "Produto", units: 4, styles: PosStyles(bold: true)),
      FlexCol(
        text: "Qtd",
        units: 2,
        styles: PosStyles(bold: true, align: PosAlign.center),
        maxLines: 2,
      ),
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

  List<int> _makeProdutosLancadosList(VendaMesaEntity venda) {
    List<int> produtosLancados = [];

    for (final produto in venda.produtosLancados) {
      List<FlexCol> produtoRow = [];

      produtoRow.add(
        FlexCol(
          text: _dateToHour(produto.dataLancamento),
          units: 3,
          maxLines: 3,
          styles: PosStyles(),
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
          text: removerDecimalSeZero(produto.quantidade),
          units: 2,
          maxLines: 2,
          styles: PosStyles(bold: true, align: PosAlign.center),
        ),
      );

      produtoRow.add(
        FlexCol(
          text: formatPreco(produto.valorFinal),
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

  List<int> _makePaymentSummary(VendaMesaEntity venda) {
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
        text: formatPreco(venda.valorTotal),
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

    for (final payment in venda.pagamentos) {
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
          text: formatPreco(payment.valor),
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
        text: formatPreco(venda.valorTotal),
        units: 7,
        styles: PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);

    if (venda.troco != null && venda.troco! > 0) {
      paymentSummary += _printer.addRow([
        FlexCol(
          text: "TROCO: ",
          units: 4,
          styles: PosStyles(align: PosAlign.left, bold: true),
        ),

        FlexCol(
          text: venda.troco.toString(),
          units: 8,
          styles: PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
    }

    return paymentSummary;
  }

  List<int> _makeVendaInfBottom(VendaMesaEntity venda) {
    List<int> vendaInf = [];

    if (venda.cpfCliente != null) {
      vendaInf += _makeClientIdentifier(venda);
    }

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

  List<int> _makeClientIdentifier(VendaMesaEntity venda) {
    List<int> clientIdentifier = [];

    String? cpfCnpj = venda.cnpjCliente ?? venda.cpfCliente;

    if (cpfCnpj != null) {
      String clientText = "CPF/CNPJ do consumidor: ${venda.cpfCliente}";
      clientIdentifier += _printer.addText(
        text: clientText,
        styles: PosStyles(align: PosAlign.left),
      );
    }

    return clientIdentifier;
  }

  List<int> _makeFooter() {
    List<int> vendaFooter = [];

    vendaFooter += _printer.addText(
      text: "JIFFY sistema Inteligente de gestao empresarial - (65) 99293-4536",
      styles: PosStyles(align: PosAlign.center, underline: true),
    );

    return vendaFooter;
  }

  String _formatDate(DateTime date) =>
      DateFormat('dd/MM HH:mm:ss').format(date);

  String _dateToHour(DateTime date) => DateFormat('HH:mm').format(date);

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

  bool _isMesa() => false;

  String _getTipoVenda() => _isMesa() ? "mesa" : "balcao";
}
