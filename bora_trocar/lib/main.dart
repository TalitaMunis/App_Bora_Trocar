import 'package:flutter/material.dart';
import 'my_app.dart'; // Importa o widget raiz do app

void main() {
  // No futuro, este é o local para inicializar serviços
  // como Firebase, SharedPreferences, etc.
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  // 1. O app começa executando o widget MyApp
  runApp(const MyApp());
}
