import 'package:flutter/material.dart';
import 'cadastro.dart';
import 'listagem.dart';

class Home extends StatefulWidget {
  final String title;

  const Home({Key key, this.title}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: Text(
                  "Olá! Seja bem-vindo! 😃",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: FlatButton(
                child: Text(
                  "🆕 Cadastrar Cliente",
                  style: TextStyle(fontSize: 25),
                ),
                color: Colors.green,
                height: 100,
                onPressed: () {
                  /// PASSANDO NULL PQ ESTA SENDO CRIADO UM NOVO USUARIO.
                  /// NA TELA LISTAGEM EH PASSADO O UID DO FIRESTORE, ISSO DETERMINA QUE EH EDICAO.
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Cadastro(usuario: null)));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: FlatButton(
                child: Text(
                  "👥 Gerenciar Clientes",
                  style: TextStyle(fontSize: 25),
                ),
                color: Colors.green,
                height: 100,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Listagem()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
