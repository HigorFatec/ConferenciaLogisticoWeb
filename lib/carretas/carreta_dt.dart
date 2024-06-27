import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'entrada.dart';

class CarretaDT {
  final String nome;
  final String dt;

  CarretaDT({
    required this.nome,
    required this.dt,
  });
}

Future<bool> _verificarDtNoFirebase(String dt) async {
  final query = await FirebaseFirestore.instance
      .collection('CarretasComEntrada')
      .where('dt', isEqualTo: dt)
      .get();

  //print('Verificando Firestore para DT: $dt, Existe: ${query.docs.isNotEmpty}');
  return query.docs.isNotEmpty;
}

Future<List<CarretaDT>?> fetchMotoristasFromExcel() async {
  // Carregue o arquivo Excel como um objeto ByteData
  final ByteData data = await rootBundle.load('lib/assets/abastecimento.xlsx');

  // Converta o ByteData para uma lista de bytes
  final Uint8List bytes = data.buffer.asUint8List();

  // Crie um objeto Excel a partir dos bytes da planilha
  final excel = Excel.decodeBytes(bytes);

  // Obtenha a primeira planilha do arquivo Excel
  final sheet = excel.tables[excel.tables.keys.first];

  // Converta as linhas da planilha em objetos Motorista
  final motoristas = sheet?.rows.map((row) {
    final nome = row[1]?.value?.toString() ?? '';
    final dt = row[0]?.value?.toString() ?? '';

    return CarretaDT(
      nome: nome,
      dt: dt,
    );
  }).toList();
  return motoristas;
}

class CarretaDTScreen extends StatefulWidget {
  const CarretaDTScreen({Key? key}) : super(key: key);

  @override
  _CarretaDTScreenState createState() => _CarretaDTScreenState();
}

class _CarretaDTScreenState extends State<CarretaDTScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carreta DTS'),
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
                      hintText: 'Buscar por DT',
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
              child: FutureBuilder<List<CarretaDT>?>(
                future: fetchMotoristasFromExcel().catchError((error) {
                  print('Erro ao carregar motoristas: $error');
                  return null; // Return null to indicate error
                }),
                builder: (BuildContext context,
                    AsyncSnapshot<List<CarretaDT>?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || snapshot.data == null) {
                    return const Center(
                        child: Text('Erro ao carregar motoristas'));
                  } else {
                    final motoristas = snapshot.data!;
                    return ListView.builder(
                      itemCount: motoristas.length,
                      itemBuilder: (BuildContext context, int index) {
                        final motorista = motoristas[index];
                        if (_searchText.isNotEmpty &&
                            !motorista.dt
                                .toLowerCase()
                                .contains(_searchText.toLowerCase())) {
                          return const SizedBox.shrink();
                        }

                        return FutureBuilder<bool>(
                          future: _verificarDtNoFirebase(motorista.dt),
                          builder: (context, snapshot) {
                            Color cardColor = Colors.white; // cor padrão

                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.data == true) {
                                cardColor = Colors
                                    .green; // cor se dt estiver no Firebase
                              }
                            }

                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => EntradaScreen(
                                      motoristaSelecionado: motorista,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                color: cardColor,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      title: Text(motorista.nome),
                                      subtitle: Text(
                                          'DT: ${motorista.dt}, Nome: ${motorista.nome}'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
