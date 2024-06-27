import 'dart:convert';
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JsonClass extends StatelessWidget {
  const JsonClass({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  Future<void> downloadFirestoreCollection() async {
    // Acessar a coleção
    CollectionReference collection =
        FirebaseFirestore.instance.collection('Ativos');

    // Ler os documentos
    QuerySnapshot querySnapshot =
        await collection.where('data', isEqualTo: (getYesterdayDate())).get();

    // Converter os documentos em JSON
    List<Map<String, dynamic>> jsonData = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    // Criar um objeto Blob com os dados JSON
    final blob = html.Blob([json.encode(jsonData)]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Criar e clicar no elemento de âncora para iniciar o download
    html.AnchorElement(href: url)
      ..setAttribute('download', 'json.json')
      ..click();

    // Revogar a URL do objeto Blob
    html.Url.revokeObjectUrl(url);
  }

  Future<void> downloadFirestoreDevolutivos() async {
    // Acessar a coleção
    CollectionReference collection =
        FirebaseFirestore.instance.collection('Devolutivos');

    // Ler os documentos
    QuerySnapshot querySnapshot =
        await collection.where('data', isEqualTo: (getYesterdayDate())).get();

    // Converter os documentos em JSON
    List<Map<String, dynamic>> jsonData = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    // Criar um objeto Blob com os dados JSON
    final blob = html.Blob([json.encode(jsonData)]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Criar e clicar no elemento de âncora para iniciar o download
    html.AnchorElement(href: url)
      ..setAttribute('download', 'devolutivos.json')
      ..click();

    // Revogar a URL do objeto Blob
    html.Url.revokeObjectUrl(url);
  }

  Future<void> downloadFirestoreAvarias() async {
    // Acessar a coleção
    CollectionReference collection =
        FirebaseFirestore.instance.collection('AvariadosGerais');

    // Ler os documentos
    QuerySnapshot querySnapshot =
        await collection.where('data', isEqualTo: getYesterdayDate()).get();

    // Converter os documentos em JSON
    List<Map<String, dynamic>> jsonData = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    // Criar um objeto Blob com os dados JSON
    final blob = html.Blob([json.encode(jsonData)]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Criar e clicar no elemento de âncora para iniciar o download
    html.AnchorElement(href: url)
      ..setAttribute('download', 'avariados.json')
      ..click();

    // Revogar a URL do objeto Blob
    html.Url.revokeObjectUrl(url);
  }
}

String getCurrentDate() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd/MM/yyyy').format(now);
  return formattedDate;
}

String getYesterdayDate() {
  // Obtém a data e hora atual
  DateTime now = DateTime.now();

  // Subtrai um dia da data atual para obter a data de ontem
  DateTime yesterday = now.subtract(Duration(days: 1));

  // Formata a data de ontem como uma string no formato 'dd/MM/yyyy'
  String formattedDate = DateFormat('dd/MM/yyyy').format(yesterday);

  return formattedDate;
}
