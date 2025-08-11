import 'package:app/impressora/adapter/printer_start.dart';
import 'package:app/impressora/adapter/sunmi_printerx_esc_pos.dart';
import 'package:app/impressora/example/venda_mesa_entity.dart';
import 'package:app/impressora/service/mesa_finish_print_service.dart';
import 'package:app/impressora/service/mesa_order_print_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupPrinter();
  runApp(const MyApp());
  print("teste");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // SunmiPrinterAdapter printer = SunmiPrinterAdapter();

  // SunmiXPrinterAdapter printer = printerAdapter;

  // SunmiPrinter printer = printerAdapter;
  // final printerService = MesaOrderPrintService(printer: printerAdapter);

  final vendaMock = VendaMesaEntity(
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

  final printerService2 = MesaFinishPrintService(printer: printerAdapter);
  final printerService = MesaOrderPrintService(printer: printerAdapter);

  Future<void> _printPedido() async {
    await printerService.printe(vendaMock);
    // await printer.printText(
    //   'Hello Sunmi!',
    //   // alignment: align.Align.center,
    //   bold: true,
    //   textWidthRatio: 2,
    //   textHeightRatio: 2,
    // );

    // await printerAdapter.printColumns(
    //   ['2x', 'Burger Combo', '12.50'], // Qty, Product, Value
    //   columnWidths: [
    //     3,
    //     6,
    //     3,
    //   ], // total 12 units: 3 for qty, 6 for name, 3 for price
    //   columnAligns: [
    //     align.Align.left, // Qty left-aligned
    //     align.Align.left, // Product name left-aligned
    //     align.Align.right, // Price right-aligned
    //   ],
    // );

    // await printer.lineWrap();
    // await printer.printBoldColumnsEscPosDemo();

    // await printer.printText();
    // await printer.cutPaper();

    // await printer.printEscPos();
  }

  Future<void> _printFinalizacao() async {
    await printerService2.print(vendaMock);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Clique para imprimir o pedido',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(onPressed: _printPedido, child: Icon(Icons.add)),
            Text(
              'Clique para imprimir a finalizacao',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              onPressed: _printFinalizacao,
              child: Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
