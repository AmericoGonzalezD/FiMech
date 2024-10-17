// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:fimech/screens/admin/chatad.dart';
import 'package:fimech/screens/admin/homead.dart';

class MessagesPageAD extends StatelessWidget {
  List imgs = [
    {
      "url":
          "https://patiodeautos.com/wp-content/uploads/2018/09/6-consejos-para-convertirte-en-un-mejor-mecanico-de-autos.jpg"
    },
    {
      "url":
          "https://www.serpresur.com/wp-content/uploads/2023/06/serpresur-riesgos-mas-comunes-en-un-taller-mecanico-2-scaled.jpg"
    },
    {
      "url":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQTvoTl_IdhjnwM5YnYeAi03-FbpdOyfxUl-YnaI6jCvw&s"
    },
    {
      "url":
          "https://www.deceroacien.com.mx/u/fotografias/m/2023/6/2/f960x540-21552_95627_5050.jpg"
    },
    {
      "url":
          "https://www.cibertec.edu.pe/wp-content/uploads/2022/11/carrera-mecanica-automotriz-300x216.jpg"
    },
    {
      "url":
          "https://st4.depositphotos.com/13194036/20469/i/450/depositphotos_204690268-stock-photo-smiling-workman-posing-crossed-arms.jpg"
    },
  ];

  MessagesPageAD({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const HomePageAD()), // Navega a la página de registro.
            );
          },
        ),
        title: const Text(
          'Mensajes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ), // Título de la barra de aplicación
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              hintText: "Buscar",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.search,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            /*  const Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Text(
                        "En linea",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 6,
                  shrinkWrap: true,
                  itemBuilder: ((context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      width: 65,
                      height: 65,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            spreadRadius: 2,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Stack(
                        textDirection: TextDirection.rtl,
                        children: [
                          Center(
                            child: Container(
                              height: 65,
                              width: 65,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.network(
                                  imgs[index]["url"],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(4),
                            padding: const EdgeInsets.all(3),
                            height: 20,
                            width: 20,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ), */
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Text(
                        "Chats",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 6,
                shrinkWrap: true,
                itemBuilder: ((context, index) {
                  return ListTile(
                    minVerticalPadding: 16,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChatPageAD(),
                          ));
                    },
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                        imgs[index]["url"],
                      ),
                    ),
                    title: const Text(
                      "Mecanico Nombre",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      "Hola, voy a ser tu mecanico.",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                    trailing: const Text(
                      "12:30",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
