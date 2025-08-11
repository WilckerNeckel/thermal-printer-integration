class VendaMesaEntity {
  String numeroMesa;
  String terminal;
  String atendente;
  String? identificacao = "Cliente esta com pressa";
  String codigoVenda;

  String nomeEmpresa = "PIZZARIA DO WIL";
  String cnpjEmpresa = "37.775.928/0001-58";
  String? inscricaoEstadual;

  String? cpfCliente;
  String? cnpjCliente;

  String? nomeCliente;

  List<ProdutoLancadoEntity> produtosLancados;
  List<PagamentoEntity> pagamentos;

  double valorTotal;
  double? troco;

  DateTime dataCriacao;

  VendaMesaEntity({
    required this.numeroMesa,
    required this.codigoVenda,
    required this.terminal,
    required this.atendente,
    required this.inscricaoEstadual,
    this.cpfCliente,
    this.nomeCliente,
    required this.produtosLancados,
    required this.pagamentos,
    required this.valorTotal,
    this.troco,
    required this.dataCriacao,
  });
}

class ProdutoLancadoEntity {
  String nome;
  double quantidade;
  double valorUnitario;
  double valorFinal;
  List<ComplementoLancadoEntity> complementos;
  DateTime dataLancamento;

  ProdutoLancadoEntity({
    required this.nome,
    required this.quantidade,
    required this.valorUnitario,
    required this.valorFinal,
    required this.complementos,
    required this.dataLancamento,
  });
}

class ComplementoLancadoEntity {
  String nome;
  double quantidade;
  double valorUnitario;
  double valorFinal;
  TipoImpactoPreco tipoImpacto;

  ComplementoLancadoEntity({
    required this.nome,
    required this.quantidade,
    required this.valorUnitario,
    required this.valorFinal,
    required this.tipoImpacto,
  });
}

class PagamentoEntity {
  String meioPagamento;
  double valor;

  PagamentoEntity({required this.meioPagamento, required this.valor});
}

enum TipoImpactoPreco { aumenta, diminui, naoModifica }
