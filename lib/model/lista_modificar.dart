import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Motorista2 {
  final String dt;
  final String placa;

  Motorista2({
    required this.dt,
    required this.placa,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Motorista2 && other.dt == dt && other.placa == placa;
  }

  @override
  int get hashCode => dt.hashCode ^ placa.hashCode;
}

Future<bool> _verificarDtNoFirebase(String dt) async {
  final query = await FirebaseFirestore.instance
      .collection('Conferencia')
      .where('dt', isEqualTo: dt)
      .get();

  //print('Verificando Firestore para DT: $dt, Existe: ${query.docs.isNotEmpty}');
  return query.docs.isNotEmpty;
}

Future<List<Motorista2>?> fetchMotoristasFromExcel() async {
  // Carregue o arquivo Excel como um objeto ByteData
  final ByteData data = await rootBundle.load('lib/assets/resultado.xlsx');

  // Converta o ByteData para uma lista de bytes
  final Uint8List bytes = data.buffer.asUint8List();

  // Crie um objeto Excel a partir dos bytes da planilha
  final excel = Excel.decodeBytes(bytes);

  // Obtenha a primeira planilha do arquivo Excel
  final sheet = excel.tables[excel.tables.keys.first];

  // Converta as linhas da planilha em objetos Motorista
  final motoristas2 = sheet?.rows.map((row) {
    final dt = row[0]?.value?.toString() ?? '';
    final placa = row[8]?.value?.toString() ?? '';

    return Motorista2(
      dt: dt,
      placa: placa,
    );
  }).toList();
  return motoristas2?.toSet().toList();
}

class MotoristasScreen2 extends StatefulWidget {
  const MotoristasScreen2({Key? key}) : super(key: key);

  @override
  _MotoristasScreenState2 createState() => _MotoristasScreenState2();
}

class _MotoristasScreenState2 extends State<MotoristasScreen2> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DTs'),
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
                      hintText: 'Buscar por Placa',
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
              child: FutureBuilder<List<Motorista2>?>(
                future: fetchMotoristasFromExcel().catchError((error) {
                  print('Erro ao carregar DTS: $error');
                  return null; // Return null to indicate error
                }),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Motorista2>?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || snapshot.data == null) {
                    return const Center(child: Text('Erro ao carregar DTS'));
                  } else {
                    final motoristas2 = snapshot.data!;
                    return ListView.builder(
                      itemCount: motoristas2.length,
                      itemBuilder: (BuildContext context, int index) {
                        final motorista = motoristas2[index];
                        if (_searchText.isNotEmpty &&
                            !motorista.placa
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
                                Navigator.pushNamed(
                                  context,
                                  '/dados_dt',
                                  arguments: motorista,
                                );
                              },
                              child: Card(
                                color: cardColor,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      title: Text('Placa: ${motorista.placa}'),
                                      subtitle: Text('DT: ${motorista.dt}'),
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
