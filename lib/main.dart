import 'dart:io';

import 'package:fimech/screens/login.dart';
import 'package:fimech/screens/user/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


// Función principal que se ejecuta cuando se inicia la aplicación
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: "AIzaSyBcV288savAEUbM-p8wwhu6OsWszSL88oo",
              appId: "1:850530092902:android:eb00ddf79745161d0f6aa7",
              messagingSenderId: "850530092902",
              projectId: "fimech-50cd0"))
      : await Firebase.initializeApp();

  runApp(MyApp());
}

// Clase que extiende StatelessWidget y representa la aplicación completa
class MyApp extends StatelessWidget {
  // Método build que devuelve el árbol de widgets que representa la aplicación
  @override
  Widget build(BuildContext context) => MaterialApp(
        // Oculta la etiqueta de depuración en la esquina superior derecha
        debugShowCheckedModeBanner: false,
        // Establece el título de la aplicación
        title: 'FiMech',
        // Establece el tema de la aplicación
        theme: ThemeData(
          // Establece el color principal de la aplicación
          primarySwatch: Colors.green,
          // Establece el color de fondo de la pantalla de la aplicación
          scaffoldBackgroundColor: Colors.white,
          // Establece la densidad visual de la aplicación
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // Establece la página de inicio de sesión como la pantalla de inicio de la aplicación
        home: AuthenticationWrapper(),
      );
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      return HomePage();
    } else {
      return LoginPage();
    }
  }
}
