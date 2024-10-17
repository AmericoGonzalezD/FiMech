import 'package:flutter/material.dart';

// Clave global para acceder al estado del ScaffoldMessenger
final messengerKey = GlobalKey<ScaffoldMessengerState>();

// Clase utilitaria que contiene métodos estáticos útiles para la aplicación
class Utils {
  // Método estático que muestra una Snackbar con un mensaje de error en la pantalla actual
  static showSnackBar(String? text) {
    if (text == null) return; // Si el texto es nulo, salir del método

    // Crear una nueva Snackbar con el texto dado y un fondo rojo
    final snackBar = SnackBar(content: Text(text), backgroundColor: Colors.red);

    // Obtener el estado actual del ScaffoldMessenger
    final messenger = messengerKey.currentState;
    if (messenger != null) {
      // Remover cualquier Snackbar actual antes de mostrar la nueva
      messenger.removeCurrentSnackBar();
      // Mostrar la nueva Snackbar
      messenger.showSnackBar(snackBar);
    }
  }
}
