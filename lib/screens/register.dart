import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fimech/screens/login.dart';
import 'package:fimech/widgets/utils.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _workshopNameController = TextEditingController(); // Nuevo controlador para el nombre del taller
  final _workshopAddressController = TextEditingController(); // Nuevo controlador para la dirección del taller
  final formKey = GlobalKey<FormState>();
  bool obscureText = true;
  bool _isMechanic = false; // Cambiamos _isAdmin a _isMechanic para mayor claridad

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _workshopNameController.dispose(); // Limpia el nuevo controlador
    _workshopAddressController.dispose(); // Limpia el nuevo controlador
    super.dispose();
  }

  Future signUp() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      final UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final User? user = userCredential.user;

      if (_isMechanic) {
        await FirebaseFirestore.instance.collection('admin').doc(user?.uid).set({
          'uid': user!.uid,
          'name': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'workshopName': _workshopNameController.text, // Guarda el nombre del taller
          'workshopAddress': _workshopAddressController.text, // Guarda la dirección del taller
          'isMechanic': true, // Indica que es un mecánico
        });
      } else {
        await FirebaseFirestore.instance.collection('client').doc(user?.uid).set({
          'uid': user!.uid,
          'name': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'isMechanic': false, // Indica que no es un mecánico
        });
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      print(e);
      Utils.showSnackBar(e.message);
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
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          hintText: 'Ingresa tu nombre',
                          prefixIcon: Icon(Icons.person),
                          border: InputBorder.none,
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        validator: (value) =>
                        value!.isNotEmpty ? null : 'Este campo es requerido',
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'example@email.com',
                          prefixIcon: Icon(Icons.email),
                          border: InputBorder.none,
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        validator: (email) => EmailValidator.validate(email!)
                            ? null
                            : 'Ingresa un correo valido',
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureText
                                  ? Icons.visibility_off
                                  : Icons.remove_red_eye,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureText = !obscureText;
                              });
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        obscureText: obscureText,
                        validator: (value) => value!.length >= 8
                            ? null
                            : 'Ingresa mínimo 8 caracteres',
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    if (_isMechanic) // Muestra los campos del taller si _isMechanic es true
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextFormField(
                              controller: _workshopNameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre del taller',
                                hintText: 'Ingresa el nombre del taller',
                                prefixIcon: Icon(Icons.store),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              validator: (value) => value!.isNotEmpty
                                  ? null
                                  : 'Este campo es requerido',
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextFormField(
                              controller: _workshopAddressController,
                              decoration: const InputDecoration(
                                labelText: 'Dirección del taller',
                                hintText: 'Ingresa la dirección del taller',
                                prefixIcon: Icon(Icons.location_on),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              validator: (value) => value!.isNotEmpty
                                  ? null
                                  : 'Este campo es requerido',
                            ),
                          ),
                          const SizedBox(height: 20.0),
                        ],
                      ),
                    CheckboxListTile(
                      title: const Text('Registrarse como mecánico'),
                      value: _isMechanic,
                      onChanged: (value) {
                        setState(() {
                          _isMechanic = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 40.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Color(0xFF258EB4),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Registrarse'),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          // Aquí podrías añadir una validación adicional para los campos del taller si _isMechanic es true
                          if (_isMechanic && (_workshopNameController.text.isEmpty || _workshopAddressController.text.isEmpty)) {
                            Utils.showSnackBar('Por favor, completa los datos del taller.');
                            return;
                          }
                          await signUp();
                        }
                      },
                    ),
                    const SizedBox(height: 40.0),
                    GestureDetector(
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