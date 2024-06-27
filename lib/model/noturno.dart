import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meuapp/controller/conferencia_controller.dart';
import 'package:meuapp/controller/drawner_controller.dart';
import 'package:meuapp/model/produtos_noturno.dart';
import 'package:meuapp/view/util.dart';

class NoturnasScreen extends StatefulWidget {
  final Noturn? Noturnaselecionada;

  const NoturnasScreen({Key? key, this.Noturnaselecionada}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _NoturnasScreenState createState() => _NoturnasScreenState();
}

class _NoturnasScreenState extends State<NoturnasScreen> {
  final excelControl = ConferenciaControl();

  final List<Noturna> _Noturnas = [];

  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _vendpaletController = TextEditingController();
  final _vendcxController = TextEditingController();
  final _venduniController = TextEditingController();
  final _dtController = TextEditingController();
  final _codigoController = TextEditingController();

  String nome = '';
  String quantidade = '';
  String tipo = 'caixa';

  String palet = '';
  String cx = '';
  String uni = '';
  String dt = '';
  String codigo = '';

  // ignore: prefer_typing_uninitialized_variables
  var excel;

  @override
  @override
  void initState() {
    super.initState();
    _carregarNoturnas();
    if (widget.Noturnaselecionada != null) {
      _nomeController.text = widget.Noturnaselecionada!.Noturna;
      nome = widget.Noturnaselecionada!.Noturna;

      _vendpaletController.text = widget.Noturnaselecionada!.vendpalet;
      palet = widget.Noturnaselecionada!.vendpalet;

      _vendcxController.text = widget.Noturnaselecionada!.vendcx;
      cx = widget.Noturnaselecionada!.vendcx;

      _venduniController.text = widget.Noturnaselecionada!.venduni;
      uni = widget.Noturnaselecionada!.venduni;

      _dtController.text = widget.Noturnaselecionada!.dt;
      dt = widget.Noturnaselecionada!.dt;

      _codigoController.text = widget.Noturnaselecionada!.codigo;
      codigo = widget.Noturnaselecionada!.codigo;
    }
  }

  Future<void> _carregarNoturnas() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Noturnas').get();

    final Noturnas = snapshot.docs.map((doc) {
      final data = doc.data();
      return Noturna(
        data: data['data'],
        dt: data['dt'],
        codigo: data['codigo'],
        nome: data['nome'],
        quantidade: data['quantidade'],
        observacoes: data['observacoes'],
        docId: doc.id, // Atribuir o ID do documento ao objeto Devolucao
      );
    }).toList();

    setState(() {
      _Noturnas.clear();
      _Noturnas.addAll(Noturnas);
    });
  }

  void _adicionarNoturna() async {
    final novaNoturna = Noturna(
      data: getCurrentDate(),
      dt: _dtController.text,
      codigo: _codigoController.text,
      nome: _nomeController.text,
      quantidade: _quantidadeController.text,
      observacoes: tipo,
      docId: '', // Será preenchido posteriormente com o ID do documento
    );

    final vendpalet = _vendpaletController.text;
    final vendcx = _vendcxController.text;
    final venduni = _venduniController.text;
    final quantidade = novaNoturna.quantidade;

    if (tipo == 'caixa' && vendcx != quantidade) {
      // Os valores são diferentes para o tipo 'caixa'
      print('O valor de vendcx é diferente da quantidade');
      erro(context, 'O valor de caixas é diferente de $vendcx');
      // Exiba um erro ou faça o que for necessário aqui
    } else if (tipo == 'unidade' && venduni != quantidade) {
      // Os valores são diferentes para o tipo 'unidade'
      print('O valor de venduni é diferente da quantidade');
      erro(context, 'O valor de unidades é diferente de $venduni');
      // Exiba um erro ou faça o que for necessário aqui
    } else if (tipo == 'palet' && vendpalet != quantidade) {
      // Os valores são diferentes para o tipo 'palet'
      erro(context, 'O valor de palet é diferente de $vendpalet');
    } else {
      sucesso(context, 'Produto inserido com Sucesso!');

      final docRef = await FirebaseFirestore.instance
          .collection('Noturnas')
          .add(novaNoturna.toMap());

      final docId = docRef.id;

      novaNoturna.docId = docId;

      setState(() {
        _Noturnas.add(novaNoturna); // Adiciona a devolução à lista
      });

      _nomeController.clear();
      _quantidadeController.clear();
      //}
    }
  }

  void _removerNoturna(int index) async {
    if (index >= 0 && index < _Noturnas.length) {
      final Noturna = _Noturnas[index];
      final docId = Noturna.docId;

      // Remova o documento da coleção "Noturnas"
      final docRef =
          FirebaseFirestore.instance.collection('Noturnas').doc(docId);
      print('Documento ID (Noturnas): $docId');
      await docRef.delete();

      setState(() {
        _Noturnas.removeAt(index);
      });
    }
  }

  void _salvarNoturnas() {
    sucesso(context, 'Noturnas salvas com Sucesso!');

    // Navegar para a tela inicial
    Navigator.of(context).pushNamed('/home');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    if (args != null) {
      setState(() {
        _nomeController.text = args;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            CustomDrawerHeader.getHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.home),
                      title: const Text('Inicio'),
                      subtitle: const Text('Tela Inicial'),
                      onTap: () {
                        Navigator.of(context)
                            .pushReplacementNamed('/principal');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Selecionar DT'),
                      subtitle: const Text('Escolher a DT a conferir'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/dados_dt');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.local_shipping),
                      title: const Text('Confêrencia'),
                      subtitle: const Text('Conferir os produtos da DT'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/Noturna');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.control_point_rounded),
                      title: const Text('Palets'),
                      subtitle: const Text('Saida de palets'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/palets');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Conferência de Produtos'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/new3.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _Noturnas.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: ListTile(
                      leading: GestureDetector(
                        child: const Icon(Icons.delete, size: 40),
                        onTap: () {
                          _removerNoturna(index);
                        },
                      ),
                      title: Text(_Noturnas[index].nome),
                      subtitle: Text(
                          '${_Noturnas[index].quantidade} ${_Noturnas[index].observacoes}(s)'),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Reduzindo a margem
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child: Text(
                        'Adicionar Produtos',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0), // Reduzindo o espaçamento
                    TextField(
                      onChanged: (text) {
                        nome = text;
                      },
                      controller: _nomeController,
                      decoration: InputDecoration(
                        labelText: 'Nome do item',
                        border: const OutlineInputBorder(),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/listNoturna');
                          },
                          child: const Icon(Icons.list),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0), // Reduzindo o espaçamento
                    TextField(
                      onChanged: (text) {
                        quantidade = text;
                      },
                      controller: _quantidadeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8.0), // Reduzindo o espaçamento
                    DropdownButtonFormField<String>(
                      value: tipo, // Valor selecionado
                      onChanged: (newValue) {
                        setState(() {
                          tipo = newValue!;
                        });
                      },
                      items: ['caixa', 'unidade', 'palet'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Caixa/Unidade?',
                        border: OutlineInputBorder(),
                      ),
                      dropdownColor: Colors.white,
                    ),
                    const SizedBox(height: 8.0), // Reduzindo o espaçamento
                    ElevatedButton(
                      onPressed: () {
                        if (_validateFields() == true) {
                          _adicionarNoturna();
                        } else {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Campos incompletos'),
                              content: const Text(
                                  'Por favor, preencha todos os campos.\nO campo "Quantidade" não pode ser 0.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: const Text('Adicionar Item'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateFields() {
    if (nome.isEmpty || quantidade.isEmpty || quantidade == '0') {
      return false;
    } else {
      return true;
    }
  }
}

class Noturna {
  final String data;
  final String dt;
  final String codigo;
  final String nome;
  final String quantidade;
  final String observacoes;
  String? docId;

  Noturna({
    required this.data,
    required this.dt,
    required this.codigo,
    required this.nome,
    required this.quantidade,
    required this.observacoes,
    this.docId,
  });

  Map<String, dynamic> toMap() {
    return {
      'data': data,
      'dt': dt,
      'codigo': codigo,
      'nome': nome,
      'quantidade': quantidade,
      'observacoes': observacoes,
    };
  }
}

Future<List<String>> getMotoristas() async {
  final snapshot =
      await FirebaseFirestore.instance.collection('motoristas2').get();
  final motoristas2 = snapshot.docs.map((doc) => doc['dt'] as String).toList();
  return motoristas2;
}

String getCurrentDate() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd/MM/yyyy').format(now);
  return formattedDate;
}
