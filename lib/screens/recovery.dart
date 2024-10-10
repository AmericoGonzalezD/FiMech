import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fimech/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fimech/widgets/utils.dart';

// Clase que representa la pantalla de recuperación de contraseña
class RecoverPasswordPage extends StatefulWidget {
  // Constructor sin parámetros
  RecoverPasswordPage({Key? key}) : super(key: key);

  @override
  _RecoverPasswordPageState createState() => _RecoverPasswordPageState();
}

// Clase que extiende State y representa el estado de la pantalla de recuperación de contraseña
class _RecoverPasswordPageState extends State<RecoverPasswordPage> {
  // Controlador para el TextFormField de email
  final _emailController = TextEditingController();
  // Llave global para el Form
  final _formKey = GlobalKey<FormState>();

  // Método que se ejecuta cuando se elimina el widget de la pantalla
  @override
  void dispose() {
    _emailController.dispose(); // Eliminar el controlador del TextFormField

    super.dispose();
  }

  // Método asíncrono que envía un email de restablecimiento de contraseña
  Future resetPassword() async {
    final isValid = _formKey.currentState!.validate(); // Validar el formulario
    if (!isValid) return;

    try {
      showDialog(
        // Mostrar un indicador de progreso mientras se envía el email
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Enviar el email de restablecimiento de contraseña
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());

      Navigator.pop(context); // Eliminar el indicador de progreso
    } on FirebaseAuthException catch (e) {
      print(e); // Imprimir el error en la consola
      Utils.showSnackBar(e.message); // Mostrar el error como una Snackbar
      Navigator.pop(context); // Eliminar el indicador de progreso
    }
  }

  // Método build que devuelve la interfaz de usuario de la pantalla de recuperación de contraseña
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Centrar el contenido en la pantalla
      body: Center(
        child: Theme(
          // Establecer la fuente del tema en Roboto
          data: ThemeData(
            fontFamily: 'Roboto',
          ),
          child: Container(
            // Agregar un margen alrededor del contenido
            padding: const EdgeInsets.all(20.0),
            child: Column(
              // Centrar los widgets verticalmente
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Título de la pantalla
                Text(
                  'Recupera',
                  style: GoogleFonts.roboto(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 40.0), // Agregar un espacio vertical
                Form(
                  // Asociar el Form con la llave global
                  key: _formKey,
                  child: Container(
                    // Agregar un fondo de color y redondear las esquinas
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      // Asociar el controlador al TextFormField
                      controller: _emailController,
                      // Decoración del TextFormField
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'example@email.com',
                        prefixIcon: Icon(Icons.email),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      // Validador del TextFormField
                      validator: (email) => EmailValidator.validate(email!)
                          ? null
                          : 'Ingresa un correo valido',
                    ),
                  ),
                ),
                const SizedBox(height: 40.0), // Agregar un espacio vertical
                // Botón para enviar el email de restablecimiento de contraseña
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Color(0xFF258EB4),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Recuperar contraseña'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await resetPassword();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      } on FirebaseAuthException catch (e) {
                        print(e);
                        Utils.showSnackBar(e.message);
                      }
                    }
                  },
                ),
                const SizedBox(height: 40.0), // Agregar un espacio vertical
                // Enlace para volver a la pantalla de inicio de sesión
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: '¿Ya recordaste tu contraseña? ',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: 'Accede',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: Color(0xFF258EB4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
