import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meuapp/controller/conferencia_controller.dart';
import 'package:meuapp/controller/login_controller.dart';
import 'package:meuapp/controller/drawner_controller.dart';
import 'package:meuapp/controller/relatorio_ativos.dart';
import 'package:meuapp/view/util.dart';

import '../carretas/excel_carretas.dart';
import '../controller/json.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() {
    return _AdminPageState();
  }
}

class _AdminPageState extends State<AdminPage> {
  final excelControl2 = RelatorioAtivos();
  final excelControl = ConferenciaControl();
  final jsonControl = JsonClass();
  final excelCarreta = ExcelCarreta();

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
      sucesso(context, 'Usuário já está autenticado com sucesso.');
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
                      leading: const Icon(Icons.loop),
                      title: const Text('Trocar'),
                      subtitle: const Text('Trocar de servidor'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/servidor');
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
        title: const Text('Conferência de Mapas'),
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
                color: Colors.green,
                child: InkWell(
                  onTap: () async {
                    //OBTER O ATRIBUTO "ADMIN"
                    LoginController loginController = LoginController();
                    Map<String, dynamic> usuario =
                        await loginController.usuarioLogado();
                    String admin = usuario['admin'];

                    //VERIFICANDO SE É ADMIN
                    if (admin == 'true' ||
                        admin == 'true2' ||
                        admin == 'true3') {
                      await excelCarreta.CriarPlanilha();
                    } else {
                      erro(
                          context, 'Não autorizado, consulte o Administrador!');
                    }
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
                          'Gerar Controle de Carretas',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Card(
                color: Colors.red,
                child: InkWell(
                  onTap: () async {
                    //OBTER O ATRIBUTO "ADMIN"
                    LoginController loginController = LoginController();
                    Map<String, dynamic> usuario =
                        await loginController.usuarioLogado();
                    String admin = usuario['admin'];

                    //VERIFICANDO SE É ADMIN
                    if (admin == 'true') {
                      try {
                        await jsonControl.downloadFirestoreCollection();
                        sucesso(
                            context, 'Relatorio gerado de Ativos com sucesso!');
                      } catch (e) {
                        erro(context, 'Ocorreu um erro: $e');
                        print(e);
                      }
                      ;
                    } else {
                      (erro(context,
                          'Não autorizado, consulte o Administrador!'));
                    }
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
                          'Gerar Relatorio de Dev.Ativos',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Card(
                color: Colors.red,
                child: InkWell(
                  onTap: () async {
                    //OBTER O ATRIBUTO "ADMIN"
                    LoginController loginController = LoginController();
                    Map<String, dynamic> usuario =
                        await loginController.usuarioLogado();
                    String admin = usuario['admin'];

                    //VERIFICANDO SE É ADMIN
                    if (admin == 'true') {
                      try {
                        await jsonControl.downloadFirestoreDevolutivos();
                        sucesso(context,
                            'Relatorio gerado de devolução (Retornaveis) com sucesso!');
                      } catch (e) {
                        erro(context, 'Falha ao enviar a conferencia: $e');
                        print(e);
                      }
                      ;
                    } else {
                      (erro(context,
                          'Não autorizado, consulte o Administrador!'));
                    }
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
                          'Gerar Relatorio Devolução de Ativos',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Card(
                color: Colors.red,
                child: InkWell(
                  onTap: () async {
                    //OBTER O ATRIBUTO "ADMIN"
                    LoginController loginController = LoginController();
                    Map<String, dynamic> usuario =
                        await loginController.usuarioLogado();
                    String admin = usuario['admin'];

                    //VERIFICANDO SE É ADMIN
                    if (admin == 'true') {
                      try {
                        await jsonControl.downloadFirestoreAvarias();
                        sucesso(context,
                            'Relatorio gerado de avarias com sucesso!');
                      } catch (e) {
                        erro(context, 'Falha ao enviar o relatorio: $e');
                        print(e);
                      }
                      ;
                    } else {
                      (erro(context,
                          'Não autorizado, consulte o Administrador!'));
                    }
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
                          'Gerar Relatorio Avarias',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Card(
                color: Colors.red,
                child: InkWell(
                  onTap: () async {
                    //OBTER O ATRIBUTO "ADMIN"
                    LoginController loginController = LoginController();
                    Map<String, dynamic> usuario =
                        await loginController.usuarioLogado();
                    String admin = usuario['admin'];

                    //VERIFICANDO SE É ADMIN
                    if (admin == 'true' || admin == 'true2') {
                      Navigator.of(context).pushReplacementNamed('/recuperar');
                    } else {
                      erro(
                          context, 'Não autorizado, consulte o Administrador!');
                    }
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
                          'Recuperar DTs enviadas',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Card(
                color: Colors.green,
                child: InkWell(
                  onTap: () async {
                    //OBTER O ATRIBUTO "ADMIN"
                    LoginController loginController = LoginController();
                    Map<String, dynamic> usuario =
                        await loginController.usuarioLogado();
                    String admin = usuario['admin'];

                    //VERIFICANDO SE É ADMIN
                    if (admin == 'true' ||
                        admin == 'true2' ||
                        admin == 'true3') {
                      await excelControl2.exportarExcel();
                    } else {
                      erro(
                          context, 'Não autorizado, consulte o Administrador!');
                    }
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
                          'Gerar Excel de Ativos',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
