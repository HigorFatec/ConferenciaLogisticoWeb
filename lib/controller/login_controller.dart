import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../view/util.dart';

class LoginController {
  //
  // CRIAR CONTA
  // Adiciona a conta de um novo usuário no serviço
  // Firebase Authentication
  //
  criarConta(context, nome, email, senha, cargo, matricula, admin) {
    if (nome.isEmpty ||
        email.isEmpty ||
        senha.isEmpty ||
        cargo.isEmpty ||
        matricula.isEmpty) {
      erro(context, 'Por favor, preencha todos os campos.');
      return;
    }

    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email,
      password: senha,
    )
        .then((resultado) {
      //Armazenar o NOME do usuário no Firestore
      FirebaseFirestore.instance.collection('usuarios').add(
        {
          'uid': resultado.user!.uid,
          'nome': nome,
          'cargo': cargo,
          'matricula': matricula,
          'admin': admin,
        },
      );

      sucesso(context, 'Usuário criado com sucesso.');
      Navigator.pop(context);
    }).catchError((e) {
      switch (e.code) {
        case 'email-already-in-use':
          erro(context, 'O email já foi cadastrado.');
          break;
        case 'invalid-email':
          erro(context, 'O email informado é inválido.');
          break;
        default:
          erro(context, 'ERRO: ${e.code.toString()}');
      }
    });
  }

  //
  // LOGIN
  //
  login(context, email, senha) {
    if (email.isEmpty || senha.isEmpty) {
      erro(context, 'Por favor, preencha todos os campos.');
      return;
    }

    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: senha)
        .then((value) {
      sucesso(context, 'Usuário autenticado com sucesso.');
      Navigator.pushNamed(context, '/servidor');
    }).catchError((e) {
      switch (e.code) {
        case 'user-not-found':
          erro(context, 'Usuário não encontrado.');
          break;
        default:
          erro(context, 'ERRO: ${e.code.toString()}');
      }
    });
  }

  //
  // ESQUECEU A SENHA
  //
  esqueceuSenha(context, String email) {
    if (email.isNotEmpty) {
      FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      sucesso(context, 'E-mail enviado com sucesso.');
    } else {
      erro(context, 'Não foi possível enviar o e-mail');
    }
    Navigator.pop(context);
  }

  //
  // LOGOUT
  //
  logout() {
    FirebaseAuth.instance.signOut();
  }

  //
  // ID do Usuário Logado
  //
  idUsuario() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  //
  // NOME do Usuário Logado
  //
// Atualizar o tipo de retorno para Future<Map<String, dynamic>>
  Future<Map<String, dynamic>> usuarioLogado() async {
    Map<String, dynamic> usuario = {};

    await FirebaseFirestore.instance
        .collection('usuarios')
        .where('uid', isEqualTo: idUsuario())
        .get()
        .then((resultado) {
      final data = resultado.docs[0].data();
      usuario = {
        'nome': data['nome'] ?? '',
        'cargo': data['cargo'] ?? '',
        'matricula': data['matricula'] ?? '',
        'email': data['email'] ?? '',
        'admin': data['admin'] ?? false, //caso não exista é nullo
      };
    });

    return usuario;
  }

  //
  // ATUALIZAR INFORMAÇÕES DO USUÁRIO
  //
  atualizarInformacoesUsuario(context, nome, matricula, cargo) {
    if (nome.isEmpty || matricula.isEmpty || cargo.isEmpty) {
      erro(context, 'Por favor, preencha todos os campos.');
      return;
    }

    String uid = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
        .collection('usuarios')
        .where('uid', isEqualTo: uid)
        .get()
        .then((resultado) {
      final docId = resultado.docs[0].id;

      FirebaseFirestore.instance.collection('usuarios').doc(docId).update({
        'nome': nome,
        'matricula': matricula,
        'cargo': cargo,
      }).then((_) {
        sucesso(context, 'Informações atualizadas com sucesso.');
        Navigator.pop(context);
      }).catchError((e) {
        erro(context, 'Erro ao atualizar informações: ${e.toString()}');
      });
    }).catchError((e) {
      erro(context, 'Erro ao buscar informações do usuário: ${e.toString()}');
    });
  }
}
