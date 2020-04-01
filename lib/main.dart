import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request =
    "https://api.hgbrasil.com/finance?array_limit=1&fields=only_results,currencies&key=3014b5b6";

void main() async {
  //print(await getData());
  runApp(MeuApp());
}

Future<Map> _getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class MeuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "conversor_de_moedas",
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: Text("\$ Conversor \$", textAlign: TextAlign.center),
      ),
      body: FutureBuilder<Map>(
        future: _getData(),
        builder: (context, snapshot) => _buildResponse(context, snapshot),
      ),
    );
  }
}

Widget _buildResponse(context, snapshot) {
  switch (snapshot.connectionState) {
    case ConnectionState.none:
    case ConnectionState.waiting:
      return _buildText("Carregando, aguarde...");
      break;
    default:
      if (snapshot.hasError) {
        return _buildText("Erro ao carregar dados");
      } else {
        return _buildBody();
      }
      break;
  }
}

Widget _buildText(String text) {
  return Center(
    child: Text(
      text,
      style: TextStyle(color: Colors.amber, fontSize: 30),
      textAlign: TextAlign.center,
    ),
  );
}

Widget _buildBody() {
  return Container();
}
