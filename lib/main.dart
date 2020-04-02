import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?" +
    "array_limit=1&fields=only_results,currencies&key=3014b5b6";

void main() async {
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
      title: "Conversor de Moedas",
      home: MyHomePage(),
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          hintStyle: TextStyle(color: Colors.amber),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _dolar, _euro, _libras, _bitcoin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: Text("\$ Conversor \$"),
      ),
      body: FutureBuilder<Map>(
        future: _getData(),
        builder: (context, snapshot) => _buildResponse(snapshot),
      ),
    );
  }

  Widget _buildResponse(AsyncSnapshot<Map> snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
      case ConnectionState.waiting:
        return _buildText("Carregando, aguarde...", Colors.amber);
        break;
      default:
        if (snapshot.hasError) {
          return _buildText("Erro ao carregar dados...", Colors.red);
        } else {
          _refreshResults(snapshot.data["currencies"]);
          return _buildBody();
        }
        break;
    }
  }

  Widget _buildText(String texto, Color cor) {
    return Center(
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: TextStyle(color: cor, fontSize: 30),
      ),
    );
  }

  void _refreshResults(Map data) {
    _dolar = data["USD"]["buy"];
    _euro = data["EUR"]["buy"];
    _libras = data[""]["buy"];
    _bitcoin = data[""]["buy"];
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Icon(
              Icons.monetization_on,
              color: Colors.amber,
              size: 130.0,
            ),
          ),
          _generateInputText("Reais", "R\$"),
          Divider(),
          _generateInputText("Dólares", "US\$"),
          Divider(),
          _generateInputText("Euros", "€"),
          Divider(),
          _generateInputText("Libras", "£"),
          Divider(),
          _generateInputText("Bitcoins", "₿")
        ],
      ),
    );
  }

  Widget _generateInputText(String labelText, String prefixText) {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          labelText: (labelText),
          labelStyle: TextStyle(color: Colors.amber, fontSize: 25),
          border: OutlineInputBorder(),
          prefixText: prefixText),
      style: TextStyle(color: Colors.amber, fontSize: 25.0),
    );
  }
}
