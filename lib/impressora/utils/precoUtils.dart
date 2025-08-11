import 'package:intl/intl.dart';

String formatPreco(double valor, {bool cifrao = false}) {
  final NumberFormat formato = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: cifrao ? 'R\$' : '',
    decimalDigits: 2,
  );

  return formato.format(valor).trim();
}

String removerDecimalSeZero(double valor) {
  // Se não tiver parte decimal
  if (valor.remainder(1) == 0) {
    return valor.toInt().toString();
  }
  return valor.toString();
}
