class VendaMesaEntity {
  String numeroMesa;
  String terminal;
  String atendente;
  String nomeEmpresa = "PIZZARIA DO WIL";

  String? cpfCliente;
  String? nomeCliente;

  List<ProdutoLancadoEntity> produtosLancados;
  List<PagamentoEntity> pagamentos;

  double valorTotal;
  double? troco;

  DateTime dataCriacao;

  VendaMesaEntity({
    required this.numeroMesa,
    required this.terminal,
    required this.atendente,
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

final vendaGrandeMock = VendaMesaEntity(
  numeroMesa: '27',
  terminal: 'T2',
  atendente: 'Carla Nunes',
  cpfCliente: '987.654.321-00',
  nomeCliente: 'Paulo Andrade',
  dataCriacao: DateTime.now(),

  produtosLancados: [
    // 1) Burger com complementos (aumenta e naoModifica)
    ProdutoLancadoEntity(
      nome: 'Burger Artesanal',
      quantidade: 2,
      valorUnitario: 22.50,
      valorFinal: 55.00, // 2 * 22.50 = 45.00 + (bacon 10.00) = 55.00
      complementos: [
        ComplementoLancadoEntity(
          nome: 'Extra Bacon',
          quantidade: 2,
          valorUnitario: 5.00,
          valorFinal: 10.00,
          tipoImpacto: TipoImpactoPreco.aumenta,
        ),
        ComplementoLancadoEntity(
          nome: 'Sem Cebola',
          quantidade: 1,
          valorUnitario: 0.00,
          valorFinal: 0.00,
          tipoImpacto: TipoImpactoPreco.naoModifica,
        ),
      ],
      dataLancamento: DateTime.now(),
    ),

    // 2) Pizza com aumento e desconto
    ProdutoLancadoEntity(
      nome: 'Pizza Portuguesa brotinho media',
      quantidade: 1,
      valorUnitario: 48.00,
      valorFinal: 54.00, // 48.00 + 8.00 - 2.00 = 54.00
      complementos: [
        ComplementoLancadoEntity(
          nome: 'Borda Recheada',
          quantidade: 1,
          valorUnitario: 8.00,
          valorFinal: 8.00,
          tipoImpacto: TipoImpactoPreco.aumenta,
        ),
        ComplementoLancadoEntity(
          nome: 'Metade sem azeitona (desconto)',
          quantidade: 1,
          valorUnitario: 2.00,
          valorFinal: -2.00,
          tipoImpacto: TipoImpactoPreco.diminui,
        ),
      ],
      dataLancamento: DateTime.now(),
    ),

    // 3) Sushi sem complementos
    ProdutoLancadoEntity(
      nome: 'Sushi Combo 16 peças',
      quantidade: 3,
      valorUnitario: 30.00,
      valorFinal: 90.00, // 3 * 30
      complementos: [],
      dataLancamento: DateTime.now(),
    ),

    // 4) Salada com desconto
    ProdutoLancadoEntity(
      nome: 'Salada Caesar',
      quantidade: 1,
      valorUnitario: 28.00,
      valorFinal: 22.00, // 28.00 - 6.00
      complementos: [
        ComplementoLancadoEntity(
          nome: 'Retirar frango (desconto)',
          quantidade: 1,
          valorUnitario: 6.00,
          valorFinal: -6.00,
          tipoImpacto: TipoImpactoPreco.diminui,
        ),
      ],
      dataLancamento: DateTime.now(),
    ),

    // 5) Massa com troca sem custo
    ProdutoLancadoEntity(
      nome: 'Nhoque ao Sugo',
      quantidade: 1,
      valorUnitario: 35.00,
      valorFinal: 35.00,
      complementos: [
        ComplementoLancadoEntity(
          nome: 'Trocar massa (sem custo)',
          quantidade: 1,
          valorUnitario: 0.00,
          valorFinal: 0.00,
          tipoImpacto: TipoImpactoPreco.naoModifica,
        ),
      ],
      dataLancamento: DateTime.now(),
    ),

    // 6) Sobremesa com complemento que aumenta
    ProdutoLancadoEntity(
      nome: 'Petit Gateau',
      quantidade: 2,
      valorUnitario: 17.00,
      valorFinal: 43.00, // 2 * 17 = 34 + (2 * 4.50) = 43
      complementos: [
        ComplementoLancadoEntity(
          nome: 'Bola extra de sorvete',
          quantidade: 2,
          valorUnitario: 4.50,
          valorFinal: 9.00,
          tipoImpacto: TipoImpactoPreco.aumenta,
        ),
      ],
      dataLancamento: DateTime.now(),
    ),

    // 7) Bebida sem custo extra
    ProdutoLancadoEntity(
      nome: 'Refrigerante Lata',
      quantidade: 4,
      valorUnitario: 6.00,
      valorFinal: 24.00, // 4 * 6
      complementos: [
        ComplementoLancadoEntity(
          nome: 'Gelo extra (sem custo)',
          quantidade: 1,
          valorUnitario: 0.00,
          valorFinal: 0.00,
          tipoImpacto: TipoImpactoPreco.naoModifica,
        ),
      ],
      dataLancamento: DateTime.now(),
    ),
  ],

  pagamentos: [
    PagamentoEntity(meioPagamento: 'PIX', valor: 150.00),
    PagamentoEntity(meioPagamento: 'Cartão Crédito', valor: 120.00),
    PagamentoEntity(meioPagamento: 'Dinheiro', valor: 60.00),
    PagamentoEntity(meioPagamento: 'Voucher Refeição', valor: 10.00),
  ],

  valorTotal: 323.00, // soma dos valorFinal dos produtos acima
  troco: 17.00, // total pagos (340) - total (323)
);
