import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:meuapp/controller/login_controller.dart';

class ExcelCarreta {
  var excel;
  String cidade = 'RPU';

  ExcelCarreta() {
    lerPlanilha();
  }

  lerPlanilha() async {
    ByteData data = await rootBundle.load("lib/assets/RelatorioCarretas.xlsx");
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    excel = Excel.decodeBytes(bytes);
  }

  Future<void> CriarPlanilha() async {
    try {
      //
      //Obtendo nome do usuario logado
      //

      LoginController loginController = LoginController();

      Map<String, dynamic> usuario = await loginController.usuarioLogado();
      String nome = usuario['nome'];
      Sheet p = excel['CARRETA'];
      p.cell(CellIndex.indexByString("L2")).value = nome;

      // Exibir dados da coleção "motoristas"
      QuerySnapshot entradaSnapshot =
          await FirebaseFirestore.instance.collection('EntradaCarreta').get();
      if (entradaSnapshot.docs.isNotEmpty) {
        int linha =
            2; // Comece a partir da linha 6 (ou qualquer outra linha desejada)
        for (DocumentSnapshot entradaDocument in entradaSnapshot.docs) {
          String tipo = entradaDocument.get('tipo');
          String transportadora = entradaDocument.get('transportadora');
          String dt = entradaDocument.get('dt');
          String data_chegada = entradaDocument.get('data');
          String horario_chegada = entradaDocument.get('horario');
          String produto = entradaDocument.get('produto');
          String veiculo = entradaDocument.get('veiculo');

          // Preencher os dados da devolução na planilha
          Sheet p = excel['CARRETA'];
          p.cell(CellIndex.indexByString("A$linha")).value = dt;
          p.cell(CellIndex.indexByString("B$linha")).value = transportadora;
          p.cell(CellIndex.indexByString("C$linha")).value = tipo;
          p.cell(CellIndex.indexByString("D$linha")).value = veiculo;
          p.cell(CellIndex.indexByString("E$linha")).value = produto;
          p.cell(CellIndex.indexByString("F$linha")).value = data_chegada;
          p.cell(CellIndex.indexByString("G$linha")).value = horario_chegada;

          //INCLUINDO A SAIDA DE CARRETA
          QuerySnapshot descargaSnapshot = await FirebaseFirestore.instance
              .collection('InfoCarretas')
              .where('dt', isEqualTo: dt)
              .where('operacao', isEqualTo: 'descarga')
              .get();

          for (DocumentSnapshot descargaDocument in descargaSnapshot.docs) {
            String data_entrada = descargaDocument.get('data_descarga');
            String horario_entrada = descargaDocument.get('horario_descarga');

            p.cell(CellIndex.indexByString("H$linha")).value = data_entrada;
            p.cell(CellIndex.indexByString("I$linha")).value = horario_entrada;
          }

          QuerySnapshot saidaSnapshot = await FirebaseFirestore.instance
              .collection('InfoCarretas')
              .where('dt', isEqualTo: dt)
              .where('operacao', isEqualTo: 'saida')
              .get();

          for (DocumentSnapshot saidaDocument in saidaSnapshot.docs) {
            String data_saida = saidaDocument.get('data_saida');
            String horario_saida = saidaDocument.get('horario_saida');

            p.cell(CellIndex.indexByString("J$linha")).value = data_saida;
            p.cell(CellIndex.indexByString("K$linha")).value = horario_saida;
          }
          linha++;
        }

        // ARMAZENANDO TODO TIPO DE DEVOLUÇÃO EM UMA SÓ COLEÇÃO

        QuerySnapshot motoristasSnapshot2 =
            await FirebaseFirestore.instance.collection('EntradaCarreta').get();
        if (motoristasSnapshot2.docs.isNotEmpty) {
          DocumentSnapshot motoristaDocument = motoristasSnapshot2.docs[0];

          String pasta = getCurrentDate2();
          String motorista = motoristaDocument.get('placa_carreta');

          var fileBytes = excel.save();
          var fileName = 'Rib/Controle_Carretas/$pasta/$motorista.xlsx';
          print(motorista);

          var storage = FirebaseStorage.instance;
          var reference = storage.ref().child(fileName);

          try {
            await reference.putData(fileBytes);

            var downloadUrl = await reference.getDownloadURL();

            print(
                'O arquivo foi enviado com sucesso para o Firebase Cloud Storage.');
            print('URL de download: $downloadUrl');
          } catch (e) {
            print('Ocorreu um erro durante o envio do arquivo: $e');
          }
        } else {
          print('A coleção "motoristas" está vazia.');
        }
      }
    } catch (error) {
      print(error);
    }
  }
}

String getCurrentDate() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd/MM/yyyy').format(now);
  return formattedDate;
}

String getCurrentDate2() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd.MM.yyyy').format(now);
  return formattedDate;
}

String getCurrentTime() {
  DateTime now = DateTime.now();
  String formattedTime = DateFormat('HH:mm:ss').format(now);
  return formattedTime;
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
