import 'package:app/impressora/port/thermal_printer.dart';
import 'package:app/impressora/example/venda_mesa_entity.dart';
import 'package:app/impressora/utils/flex_col.dart';
import 'package:app/impressora/utils/precoUtils.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:intl/intl.dart';
import 'package:diacritic/diacritic.dart';

class MesaOrderPrintService {
  final ThermalPrinter _printer;

  MesaOrderPrintService({required ThermalPrinter printer}) : _printer = printer;

  Future<void> printe(VendaMesaEntity mesa) async {
    try {
      List<int> printing = _printer.createNewPrinting();
      printing += _makeMesaOrderHeader(mesa);
      printing += _makeOrderBody(mesa);

      printing += _printer.addCutPaper();

      await _printer.sendPrint(printing);
    } catch (e) {
      print(
        "DEEU ERROOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO ${e.toString()}" as dynamic,
      );
    }
  }

  List<int> _makeOrderBody(VendaMesaEntity mesa) {
    List<int> orderBody = [];

    orderBody += _makeOrderBodyHeader(mesa);

    orderBody += _makeProdutosLancadosList(mesa);

    return orderBody;
  }

  List<int> _makeMesaOrderHeader(VendaMesaEntity mesa) {
    List<int> orderHeader = [];
    orderHeader += _printer.addText(
      text: "MESA: ${mesa.numeroMesa} #${mesa.numeroVenda}",
      styles: PosStyles(
        align: PosAlign.center,
        width: PosTextSize.size2,
        height: PosTextSize.size2,
        bold: true,
        reverse: true,
      ),
    );
    orderHeader += _printer.addSkipLines(1);

    orderHeader += _printer.addText(
      text: "CODIGO TER.: ${mesa.codTerminal}",
      styles: PosStyles(bold: true),
    );

    // horário do pedido
    orderHeader += _printer.addText(
      text: "H. PED: ${_formatDate(DateTime.now())}",
      styles: PosStyles(bold: true),
    );

    // atendente
    orderHeader += _printer.addText(
      text: "ATEND.: ${removeDiacritics(mesa.atendente)}",
      styles: PosStyles(bold: true),
    );

    // identificação

    if (mesa.identificacao != null) {
      final col = [
        FlexCol(
          text: "IDENT.: ${removeDiacritics(mesa.identificacao!)}",
          styles: PosStyles(bold: true),
          maxLines: 2,
          units: 12,
        ),
      ];

      orderHeader += _printer.addRow(col);
    }

    // divider
    orderHeader += _printer.addDivider();
    return orderHeader;
  }

  List<int> _makeOrderBodyHeader(VendaMesaEntity mesa) {
    List<int> header = [];
    // header
    final headerCols = [
      FlexCol(
        text: "PRODUTO",
        units: 9,
        styles: PosStyles(bold: true, align: PosAlign.left),
      ),
      FlexCol(text: "", units: 1, styles: PosStyles(bold: true)),
      FlexCol(
        text: "QTD",
        units: 2,
        styles: PosStyles(bold: true, align: PosAlign.center),
      ),
    ];

    header += _printer.addRow(headerCols);

    header += _printer.addDivider();

    header += _printer.addSkipLines(1);
    return header;
  }

  List<int> _makeProdutosLancadosList(VendaMesaEntity mesa) {
    List<int> produtosLancados = [];

    for (final produto in mesa.produtosLancados) {
      List<FlexCol> produtoRow = [];

      produtoRow.add(
        FlexCol(
          text: removeDiacritics(produto.nome),
          units: 10,
          maxLines: 3,
          styles: PosStyles(bold: true, align: PosAlign.left),
        ),
      );
      // produtoRow.add(FlexCol(text: '', units: 1));
      produtoRow.add(
        FlexCol(
          text: removerDecimalSeZero(produto.quantidade),
          units: 2,
          maxLines: 2,
          styles: PosStyles(bold: true, align: PosAlign.center),
        ),
      );

      produtosLancados += _printer.addRow(produtoRow);

      // if have complementos
      if (produto.complementos.isNotEmpty) {
        produtosLancados += _makeComplementosList(produto.complementos);
      }

      produtosLancados += _printer.addDivider();
    }

    return produtosLancados;
  }

  List<int> _makeComplementosList(List<ComplementoLancadoEntity> complementos) {
    List<int> complementosLancados = [];

    for (final complemento in complementos) {
      List<FlexCol> complementoRow = [];
      final bool showQuantidade =
          complemento.tipoImpacto != TipoImpactoPreco.naoModifica;
      final complementoText =
          "${_getComplementoPrefix(complemento)} ${showQuantidade == true ? removerDecimalSeZero(complemento.quantidade) : ''} ${removeDiacritics(complemento.nome)}";

      complementoRow.add(
        FlexCol(
          text: complementoText,
          units: 10,
          maxLines: 2,
          styles: PosStyles(bold: true, align: PosAlign.left),
        ),
      );

      complementoRow.add(FlexCol(text: '', units: 2));
      complementosLancados += _printer.addRow(complementoRow);
    }

    return complementosLancados;
  }

  String _formatDate(DateTime date) =>
      DateFormat('dd/MM HH:mm:ss').format(date);

  String _getComplementoPrefix(ComplementoLancadoEntity complemento) {
    switch (complemento.tipoImpacto) {
      case TipoImpactoPreco.aumenta:
        return "+";
      case TipoImpactoPreco.diminui:
        return "-";
      default:
        return "*";
    }
  }
}
