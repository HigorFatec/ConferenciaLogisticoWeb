import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meuapp/view/devolucoes.dart';

class Dev {
  final String devolucao;
  final String codigo;

  Dev({
    required this.devolucao,
    required this.codigo,
  });
}

Future<List<Dev>?> fetchDevolucoesFromExcel() async {
  // Carregue o arquivo Excel como um objeto ByteData
  final ByteData data = await rootBundle.load('lib/assets/sku.xlsx');

  // Converta o ByteData para uma lista de bytes
  final Uint8List bytes = data.buffer.asUint8List();

  // Crie um objeto Excel a partir dos bytes da planilha
  final excel = Excel.decodeBytes(bytes);

  // Obtenha a primeira planilha do arquivo Excel
  final sheet = excel.tables[excel.tables.keys.first];

  // Converta as linhas da planilha em objetos Dev
  final devolucoes = sheet?.rows.map((row) {
    final codigo = row[0]?.value?.toString() ?? '';
    final devolucao = row[1]?.value?.toString() ?? '';

    return Dev(
      devolucao: devolucao,
      codigo: codigo,
    );
  }).toList();

  return devolucoes;
}

class DevolucaoScreen extends StatefulWidget {
  const DevolucaoScreen({Key? key}) : super(key: key);

  @override
  _DevolucaoScreenState createState() => _DevolucaoScreenState();
}

class _DevolucaoScreenState extends State<DevolucaoScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  List<Dev> devolucoes = [];

  @override
  void initState() {
    super.initState();
    fetchDevolucoesFromExcel().then((devolucoesList) {
      if (devolucoesList != null) {
        setState(() {
          devolucoes = devolucoesList;
        });
      }
    }).catchError((error) {
      print('Erro ao carregar devoluções: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Devoluções'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/back2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Buscar por nome do Produto',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: devolucoes.length,
                itemBuilder: (BuildContext context, int index) {
                  final devolucao = devolucoes[index];
                  if (_searchText.isNotEmpty &&
                      !devolucao.devolucao
                          .toLowerCase()
                          .contains(_searchText.toLowerCase())) {
                    return const SizedBox.shrink();
                  }
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => DevolucoesScreen(
                            devolucaoSelecionada: devolucao,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Text(devolucao.devolucao),
                            subtitle: Text('Código: ${devolucao.codigo}'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
