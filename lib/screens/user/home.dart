import 'package:fimech/screens/user/talleresScreen.dart';
import 'package:flutter/material.dart';
//import 'package:fimech/screens/user/chat.dart';
//import 'package:fimech/screens/user/feed.dart'; // Importando la pantalla de alimentación
//import 'package:fimech/screens/user/messages.dart';
import 'package:fimech/screens/user/profile2.dart';
import 'package:fimech/screens/user/schedule.dart';
import 'package:fimech/screens/user/tracking.dart'; // Importando la pantalla de perfil

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex =
      0; // Índice del elemento seleccionado en la barra de navegación inferior

  @override
  Widget build(BuildContext context) {
    final screens = [
      // Lista de las pantallas a mostrar
      //   FeedPage(),
      SchedulePage(),
      TalleresScreen(),
      TrackingPage(),
      //ChatPage(),
      ProfilePage2()
    ];

    Color selectedColor = Colors.green[300]!; // Color del elemento seleccionado en la barra de navegación inferior
    Color unselectedColor = Colors.grey[
        600]!; // Color del elemento no seleccionado en la barra de navegación inferior

    return Scaffold(
      // Crea una nueva instancia de la clase Scaffold
      body: IndexedStack(
        // Muestra una de las pantallas según el índice seleccionado
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        // Barra de navegación inferior
        currentIndex: selectedIndex, // Índice del elemento seleccionado
        onTap: (value) {
          // Llamado cuando se selecciona un elemento
          setState(() {
            selectedIndex = value; // Actualiza el índice seleccionado
          });
        },
        elevation: 10, // Sombra del elemento
        selectedItemColor: selectedColor, // Color del elemento seleccionado
        unselectedItemColor:
            unselectedColor, // Color del elemento no seleccionado
        backgroundColor: const Color(0xF3FFF8F2),

        items: const <BottomNavigationBarItem>[
          //Elementos de la barra de navegación inferior
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.home), // Icono del elemento
          //   label: 'Inicio', // Etiqueta del elemento
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month), // Icono del elemento
            label: 'Citas', // Etiqueta del elemento
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store), // Icono del elemento
            label: 'Talleres', // Etiqueta del elemento
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.content_paste_search), // Icono del elemento
            label: 'Seguimiento', // Etiqueta del elemento
          ),
          //     BottomNavigationBarItem(
          //      icon: Icon(Icons.message),
          //      label: 'Mensajes',
          //     ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
