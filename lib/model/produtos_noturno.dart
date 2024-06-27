import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meuapp/model/noturno.dart';

class Noturn {
  final String Noturna;
  final String codigo;
  final String dt;
  final String vendpalet;
  final String vendcx;
  final String venduni;
  final String placa;

  Noturn({
    required this.Noturna,
    required this.codigo,
    required this.dt,
    required this.vendpalet,
    required this.vendcx,
    required this.venduni,
    required this.placa,
  });
}

Future<List<Noturn>?> fetchDevolucoesFromExcel() async {
  // Carregue o arquivo Excel como um objeto ByteData
  final ByteData data = await rootBundle.load('lib/assets/resultado.xlsx');

  // Converta o ByteData para uma lista de bytes
  final Uint8List bytes = data.buffer.asUint8List();

  // Crie um objeto Excel a partir dos bytes da planilha
  final excel = Excel.decodeBytes(bytes);

  // Obtenha a primeira planilha do arquivo Excel
  final sheet = excel.tables[excel.tables.keys.first];

  // Converta as linhas da planilha em objetos Dev
  final Noturnas = sheet?.rows.map((row) {
    final dt = row[0]?.value?.toString() ?? '';
    final codigo = row[1]?.value?.toString() ?? '';
    final nome = row[2]?.value?.toString() ?? '';
    final vendpalet = row[3]?.value?.toString() ?? '';
    final vendcx = row[4]?.value?.toString() ?? '';
    final venduni = row[5]?.value?.toString() ?? '';
    final placa = row[8]?.value?.toString() ?? '';

    return Noturn(
      Noturna: nome,
      dt: dt,
      codigo: codigo,
      vendpalet: vendpalet,
      vendcx: vendcx,
      venduni: venduni,
      placa: placa,
    );
  }).toList();

  return Noturnas;
}

class NoturnaScreen extends StatefulWidget {
  const NoturnaScreen({Key? key}) : super(key: key);

  @override
  _NoturnaScreenState createState() => _NoturnaScreenState();
}

class _NoturnaScreenState extends State<NoturnaScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  List<Noturn> Noturnas = [];
  Map<String, bool> codigoExisteMap =
      {}; // Mapa para armazenar resultados da verificação

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dtList = await getdt();
    setState(() {
      _searchText = dtList.join(
          ', '); // Separe os valores com vírgula ou outro separador, se desejar
    });

    final excelData = await fetchDevolucoesFromExcel();
    if (excelData != null) {
      setState(() {
        Noturnas = excelData;

        // Pré-carregue as informações do Firebase e armazene em um mapa
        Noturnas.forEach((Noturna) async {
          final exists = await _verificarCodigoNoFirebase(Noturna.codigo);
          setState(() {
            codigoExisteMap[Noturna.codigo] = exists;
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Produtos'),
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
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: 'CONFERINDO A DT: $_searchText',
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
                itemCount: Noturnas.length,
                itemBuilder: (BuildContext context, int index) {
                  final Noturna = Noturnas[index];
                  final bool codigoExiste =
                      codigoExisteMap[Noturna.codigo] ?? false;
                  Color itemColor = codigoExiste ? Colors.green : Colors.white;

                  if (_searchText.isNotEmpty &&
                      !Noturna.dt
                          .toLowerCase()
                          .contains(_searchText.toLowerCase())) {
                    return const SizedBox.shrink();
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => NoturnasScreen(
                            Noturnaselecionada: Noturna,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      color:
                          itemColor, // Defina a cor do cartão com base na condição
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Text(Noturna.Noturna),
                            subtitle: Text(
                                'Código: ${Noturna.codigo} \nVenda Palet: ${Noturna.vendpalet}, Venda Caixa: ${Noturna.vendcx}, \nVenda Unidade: ${Noturna.venduni}, PLACA: ${Noturna.placa}'),
                          ), //\nVenda Palet: ${Noturna.vendpalet}, Venda Caixa: ${Noturna.vendcx}, \nVenda Unidade: ${Noturna.venduni}
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

Future<List<String>> getdt() async {
  final snapshot =
      await FirebaseFirestore.instance.collection('motoristas2').get();
  final motoristas2 = snapshot.docs.map((doc) => doc['dt'] as String).toList();
  return motoristas2;
}

Future<bool> _verificarCodigoNoFirebase(String codigo) async {
  final query = await FirebaseFirestore.instance
      .collection(
          'Noturnas') // Substitua 'DTS' pelo nome da sua coleção no Firebase
      .where('codigo', isEqualTo: codigo)
      .get();

  return query.docs.isNotEmpty;
}
