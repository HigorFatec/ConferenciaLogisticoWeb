import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meuapp/view/dados_motorista.dart';

class Motorista {
  final String motorista;
  final String dt;
  final String placa;

  Motorista({
    required this.motorista,
    required this.dt,
    required this.placa,
  });
}

Future<bool> _verificarDtNoFirebase(String dt) async {
  final query = await FirebaseFirestore.instance
      .collection('DTSConferidas')
      .where('dt', isEqualTo: dt)
      .get();

  //print('Verificando Firestore para DT: $dt, Existe: ${query.docs.isNotEmpty}');
  return query.docs.isNotEmpty;
}

Future<List<Motorista>?> fetchMotoristasFromExcel() async {
  // Carregue o arquivo Excel como um objeto ByteData
  final ByteData data = await rootBundle.load('lib/assets/escala.xlsx');

  // Converta o ByteData para uma lista de bytes
  final Uint8List bytes = data.buffer.asUint8List();

  // Crie um objeto Excel a partir dos bytes da planilha
  final excel = Excel.decodeBytes(bytes);

  // Obtenha a primeira planilha do arquivo Excel
  final sheet = excel.tables[excel.tables.keys.first];

  // Converta as linhas da planilha em objetos Motorista
  final motoristas = sheet?.rows.map((row) {
    final motorista = row[2]?.value?.toString() ?? '';
    final dt = row[1]?.value?.toString() ?? '';
    final placa = row[0]?.value?.toString() ?? '';

    return Motorista(
      motorista: motorista,
      dt: dt,
      placa: placa,
    );
  }).toList();
  return motoristas;
}

class MotoristasScreen extends StatefulWidget {
  const MotoristasScreen({Key? key}) : super(key: key);

  @override
  _MotoristasScreenState createState() => _MotoristasScreenState();
}

class _MotoristasScreenState extends State<MotoristasScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Motoristas'),
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
                      hintText: 'Buscar por nome',
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
              child: FutureBuilder<List<Motorista>?>(
                future: fetchMotoristasFromExcel().catchError((error) {
                  print('Erro ao carregar motoristas: $error');
                  return null; // Return null to indicate error
                }),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Motorista>?> snapshot) {
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
                            !motorista.motorista
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
                                    builder: (context) => DadosMotoristaScreen(
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
                                      title: Text(motorista.motorista),
                                      subtitle: Text(
                                          'DT: ${motorista.dt}, Placa: ${motorista.placa}'),
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
