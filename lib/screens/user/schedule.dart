import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fimech/screens/login.dart';
import 'package:fimech/screens/user/citeform.dart';
import 'package:fimech/screens/user/widgets/cancelled.dart';
import 'package:fimech/screens/user/widgets/completed.dart';
import 'package:fimech/screens/user/widgets/upcoming.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  int _buttonIndex = 0;
  final _ScheduleWidgets = [
    UpcomingSchedule(),
    //CompletedWidget
    CompletedSchedule(),
    //CanceledWidget
    CancelledSchedule(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xF3FFF8F2),
        title: const Text(
          'Citas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          // Verifica si el usuario está autenticado
          if (FirebaseAuth.instance.currentUser != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                // Eliminar sesión guardada y cerrar sesión de Firebase
                try {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('saved_uid');
                  await prefs.remove('saved_isAdmin');
                } catch (_) {}
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
        ], // Título de la barra de aplicación
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  "Calendario",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 56, // Altura fija para el contenedor que contiene los botones.
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    // Cada opción ocupa 1/3 del ancho total
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _buttonIndex = 0),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: _buttonIndex == 0 ? Colors.green[300] : Colors.grey[100],
                          ),
                          child: Text(
                            'Próximas',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _buttonIndex == 0 ? Colors.black : Colors.black38,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _buttonIndex = 1),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: _buttonIndex == 1 ? Colors.green[300] : Colors.grey[100],
                          ),
                          child: Text(
                            'Completadas',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _buttonIndex == 1 ? Colors.black : Colors.black38,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _buttonIndex = 2),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: _buttonIndex == 2 ? Colors.green[300] : Colors.grey[100],
                          ),
                          child: Text(
                            'Canceladas',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _buttonIndex == 2 ? Colors.black : Colors.black38,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              _ScheduleWidgets[_buttonIndex],
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          backgroundColor: Colors.green[300],
          onPressed: () {
            Navigator.push(
              // Navega a la página de notificaciones (NotifiesPage)
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const CiteForm(workshopData: {},)), // Crea una ruta para la página de notificaciones
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
