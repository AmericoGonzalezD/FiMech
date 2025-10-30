import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart'; // Importa el paquete email_validator para validar correos electrónicos.
import 'package:fimech/screens/admin/homead.dart';
import 'package:fimech/screens/recovery.dart';// Importa la pantalla de recuperación de contraseña.
import 'package:fimech/screens/register.dart';// Importa la pantalla de registro.
import 'package:fimech/screens/user/home.dart';// Importa la pantalla de inicio de la aplicación.
import 'package:firebase_auth/firebase_auth.dart'; // Importa la autenticación de Firebase.
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart'; // Importa el paquete flutter material.

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    checkCurrentUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkCurrentUser();
  }

  Future<bool> _isUserAuthenticated(User user) async {
    await user.reload();
    return user
        .emailVerified; // Verifica si el correo electrónico del usuario ha sido verificado
  }

  Future<void> checkCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && await _isUserAuthenticated(user)) {
      final credencial = user.uid;
      // Intentar determinar rol desde Firestore
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('admin')
            .doc(credencial)
            .get();
        final isAdmin = userDoc.exists;
        // Persistir en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_uid', credencial);
        await prefs.setBool('saved_isAdmin', isAdmin);

        if (isAdmin) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePageAD()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false,
          );
        }
      } catch (_) {
        // Si falla la lectura en Firestore, no navegar automáticamente
      }
      return;
    }

    // Si no hay user en FirebaseAuth, intentar restaurar desde SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUid = prefs.getString('saved_uid');
      final savedIsAdmin = prefs.getBool('saved_isAdmin') ?? false;
      if (savedUid != null && savedUid.isNotEmpty) {
        if (savedIsAdmin) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePageAD()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false,
          );
        }
      }
    } catch (_) {
      // ignore errors reading prefs
    }
  }

  Future<void> signIn() async {
    final isValid = _formKey.currentState!.validate();
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
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? user = userCredential.user;
      final credencial = user?.uid;
      if (user != null) {
        // Cerrar el diálogo de carga
        Navigator.pop(context);
        // Persistir sesión en SharedPreferences
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('saved_uid', credencial ?? '');
        } catch (_) {}
        final userDoc = await FirebaseFirestore.instance
            .collection('admin')
            .doc(credencial)
            .get();

        final isAdmin = userDoc.exists;
        // Guardar flag de admin
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('saved_isAdmin', isAdmin);
        } catch (_) {}

        if (isAdmin) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePageAD()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'wrong-password') {
        showDialog(
          context: context,
          builder: (context) {
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.of(context).pop(true);
            });
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Contraseña incorrecta. Inténtalo de nuevo.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error al iniciar sesión, intente de nuevo')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Accede',
                    style: TextStyle(
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
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'example@email.com',
                        prefixIcon: Icon(Icons.email),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      validator: (email) =>
                          email != null && !EmailValidator.validate(email)
                              ? 'Ingresa un correo válido'
                              : null,
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
                          icon: Icon(_obscureText
                              ? Icons.visibility_off
                              : Icons.remove_red_eye),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      obscureText: _obscureText,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) => value != null && value.length < 8
                          ? 'Ingresa una contraseña de al menos 8 caracteres'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.green[300],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Iniciar sesión'),
                    onPressed: () async {
                      try {
                        await signIn();
                      } catch (e) {
                        if (e is FirebaseAuthException &&
                            e.code == 'wrong-password') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Correo y/o Contraseña incorrectos'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 40.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RecoverPasswordPage()),
                      );
                    },
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        color: Colors.green[300],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: '¿Aún no tienes una cuenta? ',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: 'Regístrate',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.green[300],
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
    );
  }
}
