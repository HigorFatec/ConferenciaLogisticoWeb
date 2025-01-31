import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meuapp/controller/drawner_controller.dart';
import 'package:meuapp/view/produtos_troca.dart';
import 'package:meuapp/view/util.dart';

import '../controller/login_controller.dart';

class TrocasScreen extends StatefulWidget {
  final Troc? trocaSelecionada;

  const TrocasScreen({Key? key, this.trocaSelecionada}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TrocasScreenState createState() => _TrocasScreenState();
}

class _TrocasScreenState extends State<TrocasScreen> {
  final List<Troca> _trocas = [];

  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController();

  String nome = '';
  String quantidade = '';

  // PROJETO PARA CONFERIR VARIOS CAMINHOES DE UMA SO VEZ
  final IdentificacaoController = LoginController();

  @override
  @override
  void initState() {
    super.initState();
    _carregarTrocas();
    if (widget.trocaSelecionada != null) {
      _nomeController.text = widget.trocaSelecionada!.troca;
      nome = widget.trocaSelecionada!.troca;
    }
  }

  Future<void> _carregarTrocas() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('trocas')
        .where('uid', isEqualTo: IdentificacaoController.idUsuario())
        .get();

    final trocas = snapshot.docs.map((doc) {
      final data = doc.data();
      return Troca(
        nome: data['nome'],
        quantidade: data['quantidade'],
        uid: data['uid'],
        docId: doc.id, // Atribuir o ID do documento ao objeto Devolucao
      );
    }).toList();

    setState(() {
      _trocas.clear();
      _trocas.addAll(trocas);
    });
  }

  void _adicionarTroca() async {
    final novaTroca = Troca(
      nome: _nomeController.text,
      quantidade: _quantidadeController.text,
      uid: IdentificacaoController.idUsuario(),
      docId: '', // Será preenchido posteriormente com o ID do documento
    );

    final docRef = await FirebaseFirestore.instance
        .collection('trocas')
        .add(novaTroca.toMap());
    final docId = docRef.id;

    novaTroca.docId = docId;

    setState(() {
      _trocas.add(novaTroca); // Adiciona a devolução à lista
    });

    _nomeController.clear();
    _quantidadeController.clear();
  }

  void _removerTroca(int index) async {
    if (index >= 0 && index < _trocas.length) {
      final troca = _trocas[index];
      final docId = troca.docId;

      final docRef = FirebaseFirestore.instance.collection('trocas').doc(docId);
      print('Documento ID: $docId');
      await docRef.delete();

      setState(() {
        _trocas.removeAt(index);
      });
    }
  }

  void _salvarTrocas() {
    sucesso(context, 'Trocas salvas com Sucesso!');

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
                        Navigator.of(context).pushReplacementNamed('/home');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Dados do Motorista'),
                      subtitle: const Text('Inserir os dados'),
                      onTap: () {
                        Navigator.of(context)
                            .pushReplacementNamed('/dados_motorista');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.reply),
                      title: const Text('Devoluções'),
                      subtitle: const Text('Devolução de produtos'),
                      onTap: () {
                        Navigator.of(context)
                            .pushReplacementNamed('/devolucoes');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text('Sobras'),
                      subtitle: const Text('Sobras de produtos'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/sobras');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.remove),
                      title: const Text('Faltas'),
                      subtitle: const Text('Faltas de produtos'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/faltas');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.swap_horiz),
                      title: const Text('Trocas'),
                      subtitle: const Text('Trocas de produtos'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/trocas');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.warning),
                      title: const Text('Avarias'),
                      subtitle: const Text('Avarias de produtos'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/avarias');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.local_shipping),
                      title: const Text('Caixas'),
                      subtitle: const Text('Caixas/Garrafas'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/caixas');
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
        title: const Text('Trocas'),
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
                itemCount: _trocas.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: ListTile(
                      leading: GestureDetector(
                        child: const Icon(Icons.delete, size: 40),
                        onTap: () {
                          _removerTroca(index);
                        },
                      ),
                      title: Text(_trocas[index].nome),
                      subtitle:
                          Text('${_trocas[index].quantidade} unidades(s)'),
                      trailing: FloatingActionButton(
                        onPressed: () {
                          _nomeController.text = _trocas[index].nome;
                          // Ação adicional ao pressionar o botão "+" dentro do Card
                        },
                        mini: true,
                        child: const Icon(Icons.add),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Nova Troca',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      onChanged: (text) {
                        nome = text;
                      },
                      controller: _nomeController,
                      decoration: InputDecoration(
                        labelText: 'Nome da troca',
                        border: const OutlineInputBorder(),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/listtroca');
                          },
                          child: const Icon(Icons.list),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      onChanged: (text) {
                        quantidade = text;
                      },
                      controller: _quantidadeController,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_validateFields() == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Trocas inserida com sucesso!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          _adicionarTroca();
                        } else {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Campos incompletos'),
                              content: const Text(
                                  'Por favor, preencha todos os campos.'),
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
                      child: const Text('Adicionar troca'),
                    ),
                    const SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: _salvarTrocas,
                      child: const Text('Salvar'),
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
    if (nome.isEmpty || quantidade.isEmpty) {
      return false;
    } else {
      return true;
    }
  }
}

class Troca {
  final String nome;
  final String quantidade;
  final String uid;
  String? docId;

  Troca({
    required this.nome,
    required this.quantidade,
    required this.uid,
    this.docId,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'quantidade': quantidade,
      'uid': uid,
    };
  }
}
