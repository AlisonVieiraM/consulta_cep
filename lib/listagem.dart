import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:consulta_cep/cadastro.dart';

class Listagem extends StatefulWidget {
  @override
  _ListagemState createState() => _ListagemState();
}

class _ListagemState extends State<Listagem> {

  void _editarCliente(String id) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Cadastro(usuario: id)));
  }

  void _apagarCliente(String cliente, String uid) async {
    var alert = AlertDialog(
      title: Text("Atenção ❗"),
      content: Row(
        children: <Widget>[
          Expanded(
            child: Text("Tem certeza que deseja apagar o cliente $cliente? Essa ação não pode ser desfeita!"),
          ),
        ],
      ),
      actions: [
        FlatButton(
          onPressed: () {
            FirebaseFirestore.instance.collection('usuarios').doc(uid).delete().then((value) {
              Navigator.pop(context);
              Navigator.of(context).pop();
            });
          },
          child: Text("Sim, excluir!"),
        ),
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Cancelar"),
        ),
      ],
    );
    showDialog(context: context, barrierDismissible: false, builder: (_) => alert);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        appBar: AppBar(
            title: Text("Gerenciar Clientes")
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
          builder: (context, snapshot){
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (snapshot.data.documents.length == 0) {
                return Center(
                  child: Text("Você ainda não tem clientes cadastrados!"),
                );
              } else {
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot user = snapshot.data.documents[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.person),
                              title: Text(user["nome-completo"]),
                              subtitle: Text(user["cpf"]),
                              trailing: Container(
                                width: 100,
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      color: Colors.orange,
                                      onPressed: () {
                                        _editarCliente(user.id);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      color: Colors.redAccent,
                                      onPressed: () {
                                        _apagarCliente(user["nome-completo"],user.id);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            }
          },
        ),
      ),
    );
  }
}
