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
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final libraController = TextEditingController();
  final bitcoinController = TextEditingController();
  GlobalKey<FormState> _keyForm = GlobalKey<FormState>();

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
    _libras = data["GBP"]["buy"];
    _bitcoin = data["BTC"]["buy"];
  }

  Widget _buildBody() {
    return Center(
      child: SingleChildScrollView(
          padding: EdgeInsets.only(right: 10, left: 10),
          child: Form(
            key: _keyForm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Icon(
                    Icons.monetization_on,
                    color: Colors.amber,
                    size: 130.0,
                  ),
                ),
                _generateInputText("Reais", "R\$", realController, _realChange),
                Divider(),
                _generateInputText(
                    "Dólares", "US\$", dolarController, _dolarChange),
                Divider(),
                _generateInputText("Euros", "€", euroController, _euroChange),
                Divider(),
                _generateInputText(
                    "Libras", "£", libraController, _libraChange),
                Divider(),
                _generateInputText(
                    "Bitcoins", "₿", bitcoinController, _bitcoinChange)
              ],
            ),
          )),
    );
  }

  Widget _generateInputText(String labelText, String prefixText,
      TextEditingController myController, Function myFunction) {
    return TextFormField(
      controller: myController,
      onChanged: myFunction,
      keyboardType: TextInputType.number,
      validator: (value) => _validate(value),
      style: TextStyle(color: Colors.amber, fontSize: 25.0),
      decoration: InputDecoration(
          labelText: (labelText),
          labelStyle: TextStyle(color: Colors.amber, fontSize: 25),
          border: OutlineInputBorder(),
          prefixText: prefixText,
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: _clearAll,
          )),
    );
  }

  void _realChange(String texto) {
    if (texto == "") {
      _clearAll();
    } else if (_keyForm.currentState.validate()) {
      double valorReais = double.parse(texto);
      _convertToString(dolarController, valorReais / _dolar);
      _convertToString(euroController, valorReais / _euro);
      _convertToString(libraController, valorReais / _libras);
      _convertToString(bitcoinController, valorReais / _bitcoin);
    }
  }

  void _dolarChange(String texto) {
    if (texto == "") {
      _clearAll();
    } else if (_keyForm.currentState.validate()) {
      double valorDolar = double.parse(texto);
      _convertToString(realController, valorDolar * _dolar);
      _convertToString(euroController, valorDolar * _dolar / _euro);
      _convertToString(libraController, valorDolar * _dolar / _libras);
      _convertToString(bitcoinController, valorDolar * _dolar / _bitcoin);
    }
  }

  void _euroChange(String texto) {
    if (texto == "") {
      _clearAll();
    } else if (_keyForm.currentState.validate()) {
      double valorEuro = double.parse(texto);
      _convertToString(realController, valorEuro * _euro);
      _convertToString(dolarController, valorEuro * _euro / _dolar);
      _convertToString(libraController, valorEuro * _euro / _libras);
      _convertToString(bitcoinController, valorEuro * _euro / _bitcoin);
    }
  }

  void _libraChange(String texto) {
    if (texto == "") {
      _clearAll();
    } else if (_keyForm.currentState.validate()) {
      double valorLibra = double.parse(texto);
      _convertToString(realController, valorLibra * _libras);
      _convertToString(dolarController, valorLibra * _libras / _dolar);
      _convertToString(euroController, valorLibra * _libras / _euro);
      _convertToString(bitcoinController, valorLibra * _libras / _bitcoin);
    }
  }

  void _bitcoinChange(String texto) {
    if (texto == "") {
      _clearAll();
    } else if (_keyForm.currentState.validate()) {
      double valorBitcoins = double.parse(texto);
      _convertToString(realController, valorBitcoins * _bitcoin);
      _convertToString(dolarController, valorBitcoins * _bitcoin / _dolar);
      _convertToString(libraController, valorBitcoins * _bitcoin / _libras);
      _convertToString(euroController, valorBitcoins * _bitcoin / _euro);
    }
  }

  void _convertToString(TextEditingController controller, double value) {
    if (value < 1) {
      controller.text = value.toStringAsPrecision(2);
    } else {
      controller.text = value.toStringAsFixed(2);
    }
  }

  // ignore: missing_return
  String _validate(String value) {
    if (value.length > 0) {
      try {
        double doubleValue = double.parse(value);
        if (doubleValue < 0) {
          return "Valor inválido!";
        }
      } catch (erro) {
        return "Valor inválido!";
      }
    }
  }

  void _clearAll() {
    realController.clear();
    dolarController.clear();
    euroController.clear();
    libraController.clear();
    bitcoinController.clear();
  }
}
