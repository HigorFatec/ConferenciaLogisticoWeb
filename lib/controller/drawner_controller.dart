import 'package:flutter/material.dart';
import 'package:meuapp/controller/login_controller.dart';
import 'package:meuapp/controller/modificar.dart';

class CustomDrawerHeader {
  static UserAccountsDrawerHeader getHeader(BuildContext context) {
    return UserAccountsDrawerHeader(
      currentAccountPicture: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const AtualizarInformacoesUsuarioScreen()),
          );
        },
        child: const CircleAvatar(
          backgroundImage: AssetImage('lib/images/logo.png'),
        ),
      ),
      accountEmail: FutureBuilder<Map<String, dynamic>>(
        future: LoginController().usuarioLogado(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Carregando...');
          }
          if (snapshot.hasError) {
            return const Text('Erro ao obter informações do usuário');
          }
          final data = snapshot.data;
          final nome = data?['nome'] ?? '';
          final cargo = data?['cargo'] ?? '';
          final matricula = data?['matricula'] ?? '';

          return Text(
            'Nome: $nome \nFunção: $cargo \nMatrícula: $matricula',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        },
      ),
      accountName: FutureBuilder<Map<String, dynamic>>(
        future: LoginController().usuarioLogado(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Carregando...');
          }
          if (snapshot.hasError) {
            return const Text('Erro ao obter informações do usuário');
          }
          final data = snapshot.data;
          final nome = data?['nome'] ?? '';
          final cargo = data?['cargo'] ?? '';

          return Text(
            'Bem vindo $cargo $nome',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}
