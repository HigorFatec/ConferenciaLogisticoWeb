import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meuapp/controller/login_controller.dart';
import 'package:meuapp/controller/drawner_controller.dart';
import 'package:meuapp/view/util.dart';

import 'excel_carretas copy.dart';
import 'excel_carretas.dart';

class PrincipalCarretas extends StatefulWidget {
  const PrincipalCarretas({super.key});

  @override
  State<PrincipalCarretas> createState() {
    return _PrincipalCarretasState();
  }
}

class _PrincipalCarretasState extends State<PrincipalCarretas> {
  final excelCarreta = ExcelCarreta();
  final excelCarreta2 = ExcelCarreta2();

  var excel;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
// Verifica se o usuário está autenticado
    User? user = FirebaseAuth.instance.currentUser;
    // Se o usuário não estiver autenticado, navegue para a página de login
    if (user == null) {
      // Substitua a página atual pela página de login
      Navigator.of(context).pushReplacementNamed('/');
      exibirAviso(context,
          'Atualização Importante! \n Agora é necessário fazer o login para acessar o sistema.\n Caso não tenha login, cadastre-se!');
      erro(context, 'Usuário não está autenticado!');
      // Você também pode usar Navigator.push se não quiser substituir a página atual
    } else {
      // Se o usuário estiver autenticado, exiba a página inicial
      //sucesso(context, 'Usuário já está autenticado com sucesso.');
      // return HomePage();
    }

    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            //Menu com nome,foto e cargo
            CustomDrawerHeader.getHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                        leading: const Icon(Icons.add),
                        title: const Text('Gerar Relatorio de Entrada',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                        onTap: () async {
                          await excelCarreta.CriarPlanilha();
                          sucesso(context, 'Planilha enviada com sucesso!');
                        }
                        // Simulando o processo de seleção de arquivo              },
                        ),
                    ListTile(
                        leading: const Icon(Icons.add),
                        title: const Text('Gerar Relatorio Carreta',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                        onTap: () async {
                          await excelCarreta2.CriarPlanilha();
                          sucesso(context, 'Planilha enviada com sucesso!');
                        }
                        // Simulando o processo de seleção de arquivo              },
                        ),
                    ListTile(
                      leading: const Icon(Icons.loop),
                      title: const Text('Trocar'),
                      subtitle: const Text('Trocar de servidor'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/servidor');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logoff'),
                      subtitle: const Text('finaliza a sessão'),
                      onTap: () {
                        LoginController().logout();
                        Navigator.of(context).pushReplacementNamed('/');
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
        title: const Text('Controle de Entrada e Saida de Carretas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              print("desativado");
              //Navigator.of(context).push(MaterialPageRoute(
              // builder: (BuildContext context) => const SobrePage()));
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/images/fundoinicial.png"),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              Card(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/entrada');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 16.0,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 20),
                        Text(
                          'Entrada de Carreta',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Card(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/descarga');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 16.0,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.local_shipping),
                        SizedBox(width: 20),
                        Text(
                          'Descarga de Carreta',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Card(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/saida');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 16.0,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.local_shipping),
                        SizedBox(width: 20),
                        Text(
                          'Saida de Carreta',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void exibirAviso(BuildContext context, String mensagem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Aviso'),
          content: Text(mensagem),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Fecha o diálogo ao pressionar OK.
              },
            ),
          ],
        );
      },
    );
  }
}
