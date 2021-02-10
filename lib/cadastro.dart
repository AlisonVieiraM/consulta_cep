import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class Cadastro extends StatefulWidget {

  final String usuario;
  const Cadastro({Key key, this.usuario}) : super(key: key);

  @override
  _CadastroState createState() => _CadastroState();

}

class _CadastroState extends State<Cadastro> {
  TextEditingController _nomeCompletoController = new TextEditingController();
  TextEditingController _cpfController = new TextEditingController();
  TextEditingController _telefoneController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _cepController = new TextEditingController();
  TextEditingController _logradouroController = new TextEditingController();
  TextEditingController _numeroController = new TextEditingController();
  TextEditingController _bairroController = new TextEditingController();
  TextEditingController _complementoController = new TextEditingController();
  TextEditingController _cidadeController = new TextEditingController();
  TextEditingController _ufController = new TextEditingController();
  var cepFormatter = new MaskTextInputFormatter(mask: '#####-###', filter: {"#": RegExp(r'[0-9]')});
  var telefoneFormatter = new MaskTextInputFormatter(mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});
  var cpfFormatter = new MaskTextInputFormatter(mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  String _telefoneNoFirebase, _cpfNoFirebase, _cepNoFirebase;

  @override
  void initState() {
    if (widget.usuario != null) {
      dadosParaEdicao();
    } else {
      _nomeCompletoController.text = "";
      _cpfController.text = "";
      _telefoneController.text = "";
      _emailController.text = "";
      _cepController.text = "";
      _logradouroController.text = "";
      _numeroController.text = "";
      _bairroController.text = "";
      _complementoController.text = "";
      _cidadeController.text = "";
      _ufController.text = "";
    }
    super.initState();
  }

  void dadosParaEdicao() async {

    if (widget.usuario != null){
      FirebaseFirestore.instance.collection("usuarios").doc(widget.usuario).snapshots().listen((event) {
        setState(() {

          _nomeCompletoController.text = event["nome-completo"];

          _telefoneController.text = telefoneFormatter.maskText(event["telefone"]);
          _telefoneNoFirebase = event["telefone"];

          _cpfController.text = cpfFormatter.maskText(event["cpf"]);
          _cpfNoFirebase = event["cpf"];

          _emailController.text = event["email"];

          _cepController.text = cepFormatter.maskText(event["endereco"]["cep"]);
          _cepNoFirebase = event["endereco"]["cep"];

          _logradouroController.text = event["endereco"]["logradouro"];

          _numeroController.text = event["endereco"]["numero"];

          _bairroController.text = event["endereco"]["bairro"];

          _complementoController.text = event["endereco"]["complemento"];

          _cidadeController.text = event["endereco"]["cidade"];

          _ufController.text = event["endereco"]["uf"];

        });
      });
    }

  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void saveAccount() async {
    if (validateAndSave()) {

      Timestamp cadastradoEm = Timestamp.fromDate(DateTime.now());
      Timestamp atualizadoEm = Timestamp.fromDate(DateTime.now());

      final Map<String, dynamic> dadosEndereco = {
        'cep': cepFormatter.getUnmaskedText() == "" ? _cepNoFirebase : cepFormatter.getUnmaskedText(),
        'logradouro': _logradouroController.text,
        'numero': _numeroController.text,
        'bairro': _bairroController.text,
        'complemento': _complementoController.text,
        'cidade': _cidadeController.text,
        'uf': _ufController.text,
      };

      if (widget.usuario == null) {

        ///cadastrando novo usuario

        final Map<String, dynamic> novoUsuario = {
          'nome-completo': _nomeCompletoController.text,
          'cpf': cpfFormatter.getUnmaskedText() == "" ? _cpfNoFirebase : cpfFormatter.getUnmaskedText(),
          'telefone': telefoneFormatter.getUnmaskedText()== "" ? _telefoneNoFirebase : telefoneFormatter.getUnmaskedText(),
          'email': _emailController.text,
          'cadastrado-em': cadastradoEm,
          'endereco': dadosEndereco,
        };

        await FirebaseFirestore.instance.collection('usuarios').add(novoUsuario).then((result) {
          alertaCadastroOk("Sucesso!","Cadastro efetuado com sucesso ✅");
        });

      } else {

        ///editando o usuario

        final Map<String, dynamic> dados = {
          'nome-completo': _nomeCompletoController.text,
          'cpf': cpfFormatter.getUnmaskedText() == "" ? _cpfNoFirebase : cpfFormatter.getUnmaskedText(),
          'telefone': telefoneFormatter.getUnmaskedText()== "" ? _telefoneNoFirebase : telefoneFormatter.getUnmaskedText(),
          'email': _emailController.text,
          'atualizado-em': atualizadoEm,
          'endereco': dadosEndereco,
        };

        await FirebaseFirestore.instance.collection("usuarios").doc(widget.usuario).update(dados).then((result){
          alertaCadastroOk("Sucesso!","Cadastro alterado com sucesso ✅");
        });

      }

    } else {
      print("nao validado");
    }
  }

  /// CONSUMO DA API
  Future<void> _buscarDadosCep(String cep) async {
    alertaBusca("Buscado dados do CEP $cep ...", Colors.orange);

    setState(() {
      _logradouroController.text = "";
      _complementoController.text = "";
      _bairroController.text = "";
      _cidadeController.text = "";
      _ufController.text = "";
      _numeroController.text = "";
    });

    String apiUrl = "https://viacep.com.br/ws/$cep/json/";
    http.Response response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      Map<String, dynamic> cep = json.decode(response.body);
      print(cep);
      if (cep['erro'] == true) {
        alertaCepNaoEncontrado();
      } else {
        alertaBusca("Dados localizados!", Colors.green);
        setState(() {
          _logradouroController.text = cep['logradouro'];
          _complementoController.text = cep['complemento'];
          _bairroController.text = cep['bairro'];
          _cidadeController.text = cep['localidade'];
          _ufController.text = cep['uf'];
        });
      }
    } else {
      throw Exception("Falhou!");
    }
  }

  void alertaCepNaoEncontrado() {
    var alert = AlertDialog(
      title: Text("Erro!"),
      content: Row(
        children: <Widget>[
          Expanded(
            child: Text("CEP não encontrado..."),
          ),
        ],
      ),
      actions: [
        FlatButton(
          onPressed: () {
            setState(() {
              _cepController.text = "";
            });
            Navigator.pop(context);
            scaffoldKey.currentState.removeCurrentSnackBar();
          },
          child: Text("Tentar novamente"),
        ),
      ],
    );
    showDialog(context: context, builder: (_) => alert);
  }

  void alertaBusca(String text, Color color) {
    SnackBar snackBar = SnackBar(
      content: Text(text),
      backgroundColor: color,
      duration: Duration(milliseconds: 1500),
    );
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void alertaCadastroOk(String titulo, String texto) {
    var alert = AlertDialog(
      title: Text(titulo),
      content: Row(
        children: <Widget>[
          Expanded(
            child: Text(texto),
          ),
        ],
      ),
      actions: [
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.of(context).pop();
          },
          child: Text("🆗"),
        ),
      ],
    );
    showDialog(context: context, barrierDismissible: false, builder: (_) => alert);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text("Cadastrar Cliente"),
        ),
        body: Form(
          key: formKey,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _nomeCompletoController,
                  decoration: InputDecoration(
                    labelText: "Nome Completo",
                    labelStyle: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                    ),
                  ),
                  style: TextStyle(fontSize: 20),
                  validator: (value) => value.isEmpty
                      ? 'Nome Completo precisa ser preenchido'
                      : null,
                ),
              ),
              Row(
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _cpfController,
                        inputFormatters: [cpfFormatter],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "CPF",
                          labelStyle: TextStyle(
                            color: Colors.black38,
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                        style: TextStyle(fontSize: 20),
                        validator: (value) =>
                        value.isEmpty ? 'Preencher...' : null,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _telefoneController,
                        inputFormatters: [telefoneFormatter],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Telefone",
                          labelStyle: TextStyle(
                            color: Colors.black38,
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                        style: TextStyle(fontSize: 20),
                        validator: (value) =>
                        value.isEmpty ? 'Preencher...' : null,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "E-mail",
                    labelStyle: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                    ),
                  ),
                  style: TextStyle(fontSize: 20),
                  validator: (value) =>
                  value.isEmpty ? 'E-mail precisa ser preenchido' : null,
                ),
              ),
              Row(
                children: [
                  Flexible(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _cepController,
                        inputFormatters: [cepFormatter],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Inserir CEP aqui",
                          labelStyle: TextStyle(
                            color: Colors.black38,
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                        style: TextStyle(fontSize: 20),
                        validator: (value) => value.isEmpty ? 'CEP precisa ser preenchido' : null,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Ink(
                          decoration: const ShapeDecoration(
                              color: Colors.blue, shape: CircleBorder()),
                          child: IconButton(
                            icon: Icon(Icons.search),
                            color: Colors.white,
                            onPressed: () {
                              _buscarDadosCep(cepFormatter.getUnmaskedText());
                              FocusScope.of(context).requestFocus(new FocusNode());
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Flexible(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _cidadeController,
                        decoration: InputDecoration(
                          labelText: "Cidade",
                          labelStyle: TextStyle(
                            color: Colors.black38,
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                        style: TextStyle(fontSize: 20),
                        validator: (value) => value.isEmpty
                            ? 'Cidade precisa ser preenchida'
                            : null,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _ufController,
                        decoration: InputDecoration(
                          labelText: "UF",
                          labelStyle: TextStyle(
                            color: Colors.black38,
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                        style: TextStyle(fontSize: 20),
                        validator: (value) =>
                        value.isEmpty ? 'Preencher...' : null,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _logradouroController,
                  decoration: InputDecoration(
                    labelText: "Logradouro",
                    labelStyle: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                    ),
                  ),
                  style: TextStyle(fontSize: 20),
                  validator: (value) => value.isEmpty
                      ? 'Logradouro precisa ser preenchido'
                      : null,
                ),
              ),
              Row(
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _numeroController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "nº",
                          labelStyle: TextStyle(
                            color: Colors.black38,
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                        style: TextStyle(fontSize: 20),
                        validator: (value) =>
                        value.isEmpty ? 'Preencher...' : null,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _bairroController,
                        decoration: InputDecoration(
                          labelText: "Bairro",
                          labelStyle: TextStyle(
                            color: Colors.black38,
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                        style: TextStyle(fontSize: 20),
                        validator: (value) => value.isEmpty
                            ? 'Bairro precisa ser preenchido'
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _complementoController,
                  decoration: InputDecoration(
                    labelText: "Complemento",
                    labelStyle: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                    ),
                  ),
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  child: Text("Salvar Cadastro"),
                  color: Colors.green,
                  onPressed: () {
                    saveAccount();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
