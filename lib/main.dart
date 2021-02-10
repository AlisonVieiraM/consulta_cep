import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  String nomeDoApp = "Gestor de Clientes";

  runApp(
      MaterialApp(
        title: nomeDoApp,
        home: Home(title: nomeDoApp),
      )
  );
}
