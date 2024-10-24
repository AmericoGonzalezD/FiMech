import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart'; // Importa un paquete para validar direcciones de correo electrónico.
import 'package:firebase_auth/firebase_auth.dart'; // Importa la autenticación de Firebase.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fimech/screens/login.dart'; // Importa la pantalla de inicio de sesión.
import 'package:fimech/widgets/utils.dart'; // Importa utilidades personalizadas.

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() =>
      _RegisterPageState(); // Define el estado para la página de registro.
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController =
      TextEditingController(); // Controlador para el campo de nombre.
  final _emailController =
      TextEditingController(); // Controlador para el campo de correo electrónico.
  final _passwordController =
      TextEditingController(); // Controlador para el campo de contraseña.
  final formKey = GlobalKey<FormState>(); // Clave global para el formulario.
  bool obscureText =
      true; // Variable para controlar la visibilidad de la contraseña.
  bool _isAdmin = false;
  @override
  void dispose() {
    _emailController.dispose(); // Limpia el controlador de correo electrónico.
    _passwordController.dispose(); // Limpia el controlador de contraseña.

    super.dispose();
  }

  Future signUp() async {
    final isValid = formKey.currentState!.validate(); // Valida el formulario.
    if (!isValid) return; // Si no es válido, retorna.

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(), // Muestra un diálogo de carga.
        ),
      );
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text
            .trim(), // Obtiene el correo electrónico del controlador y elimina espacios en blanco.
        password: _passwordController.text
            .trim(), // Obtiene la contraseña del controlador y elimina espacios en blanco.
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LoginPage()), // Navega a la pantalla de inicio de sesión.
      );
    } on FirebaseAuthException catch (e) {
      print(e);

      Utils.showSnackBar(
          e.message); // Muestra un mensaje de error en forma de Snackbar.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Theme(
            data: ThemeData(
              fontFamily: 'Roboto',
            ),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Regístrate',
                      style: GoogleFonts.roboto(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    Container(
                      // Campo de entrada para el nombre.
                      decoration: BoxDecoration(
                        color:
                            Colors.grey[200], // Color de fondo del contenedor.
                        borderRadius: BorderRadius.circular(
                            10), // Bordes redondeados del contenedor.
                      ),
                      child: TextFormField(
                        controller:
                            _nameController, // Controlador del campo de texto para el nombre.
                        decoration: const InputDecoration(
                          labelText: 'Nombre', // Etiqueta del campo de texto.
                          hintText:
                              'Ingresa tu nombre', // Texto de sugerencia dentro del campo de texto.
                          prefixIcon: Icon(Icons
                              .person), // Icono del prefijo para el nombre.
                          border: InputBorder
                              .none, // Sin borde alrededor del campo de texto.
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical:
                                  12), // Espaciado interno del campo de texto.
                        ),
                        validator: (value) => value!
                                .isNotEmpty // Validación para comprobar si el campo no está vacío.
                            ? null
                            : 'Este campo es requerido', // Mensaje de error si el campo está vacío.
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      // Campo de entrada para el correo electrónico.
                      decoration: BoxDecoration(
                        color:
                            Colors.grey[200], // Color de fondo del contenedor.
                        borderRadius: BorderRadius.circular(
                            10), // Bordes redondeados del contenedor.
                      ),
                      child: TextFormField(
                        controller:
                            _emailController, // Controlador del campo de texto para el correo electrónico.
                        decoration: const InputDecoration(
                          labelText: 'Email', // Etiqueta del campo de texto.
                          hintText:
                              'example@email.com', // Texto de sugerencia dentro del campo de texto.
                          prefixIcon: Icon(Icons
                              .email), // Icono del prefijo para el correo electrónico.
                          border: InputBorder
                              .none, // Sin borde alrededor del campo de texto.
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical:
                                  12), // Espaciado interno del campo de texto.
                        ),
                        validator: (email) => EmailValidator.validate(
                                email!) // Validación del correo electrónico utilizando el paquete 'email_validator'.
                            ? null
                            : 'Ingresa un correo valido', // Mensaje de error si el correo electrónico no es válido.
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      // Campo de entrada para la contraseña.
                      decoration: BoxDecoration(
                        color:
                            Colors.grey[200], // Color de fondo del contenedor.
                        borderRadius: BorderRadius.circular(
                            10), // Bordes redondeados del contenedor.
                      ),
                      child: TextFormField(
                        controller:
                            _passwordController, // Controlador del campo de texto para la contraseña.
                        decoration: InputDecoration(
                          labelText:
                              'Contraseña', // Etiqueta del campo de texto.
                          hintText:
                              '••••••••', // Texto de sugerencia dentro del campo de texto para la contraseña.
                          prefixIcon: const Icon(Icons
                              .lock), // Icono del prefijo para la contraseña.
                          suffixIcon: IconButton(
                            // Ícono del sufijo para alternar la visibilidad de la contraseña.
                            icon: Icon(
                              obscureText
                                  ? Icons.visibility_off
                                  : Icons.remove_red_eye,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureText =
                                    !obscureText; // Cambia la visibilidad de la contraseña.
                              });
                            },
                          ),
                          border: InputBorder
                              .none, // Sin borde alrededor del campo de texto.
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical:
                                  12), // Espaciado interno del campo de texto.
                        ),
                        obscureText:
                            obscureText, // Indica si el texto debe ser ocultado (contraseña).
                        validator: (value) => value!.length >=
                                8 // Validación para comprobar si la contraseña tiene al menos 8 caracteres.
                            ? null
                            : 'Ingresa mínimo 8 caracteres', // Mensaje de error si la contraseña no cumple con el requisito de longitud.
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    CheckboxListTile(
                      title: const Text('Registrarse como administrador'),
                      value: _isAdmin,
                      onChanged: (value) {
                        setState(() {
                          _isAdmin = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 40.0),
                    ElevatedButton(
                      // Botón para registrarse.
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(
                            double.infinity, 50), // Tamaño mínimo del botón.
                        backgroundColor:
                        Color(0xFF258EB4), // Color de fondo del botón.
                        foregroundColor:
                            Colors.white, // Color del texto del botón.
                      ),
                      child:
                          const Text('Registrarse'), // Texto dentro del botón.
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          try {
                            final UserCredential userCredential =
                                await FirebaseAuth.instance
                                    .createUserWithEmailAndPassword(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                            );
                            final User? user = userCredential.user;

                            // Almacena la información del usuario en la colección correspondiente
                            if (_isAdmin) {
                              await FirebaseFirestore.instance
                                  .collection('admin')
                                  .doc(user?.uid)
                                  .set({
                                'uid': user!.uid,
                                'name': _nameController.text,
                                'email': _emailController.text,
                                'password': _passwordController.text
                              });
                            } else {
                              await FirebaseFirestore.instance
                                  .collection('client')
                                  .doc(user?.uid)
                                  .set({
                                'uid': user!.uid,
                                'name': _nameController.text,
                                'email': _emailController.text,
                                'password': _passwordController.text
                              });
                            }

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                            );
                          } on FirebaseAuthException catch (e) {
                            print(e);

                            Utils.showSnackBar(e.message);
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 40.0),
                    GestureDetector(
                      // Enlace para ir a la página de inicio de sesión.
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: '¿Ya tienes una cuenta? ',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: 'Accede',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: const Color(0xFF258EB4),
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
        ),
      ),
    );
  }
}
