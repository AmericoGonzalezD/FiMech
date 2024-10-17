import 'package:flutter/material.dart';
import 'package:fimech/screens/user/chatabout.dart';
import 'package:fimech/screens/user/home.dart';
import 'package:fimech/screens/user/widgets/chatsample.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: AppBar(
          backgroundColor: Colors.green[300],
          leadingWidth: 30,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const HomePage()), // Navega a la página de registro.
              );
            },
          ),
          title: const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(
                    "https://patiodeautos.com/wp-content/uploads/2018/09/6-consejos-para-convertirte-en-un-mejor-mecanico-de-autos.jpg",
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    "Mecanico",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboutChatPage(),
                    ));
              },
              child: const Padding(
                padding: EdgeInsets.only(top: 8, right: 20),
                child: Icon(Icons.info, color: Colors.white, size: 26),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: 10,
          padding: const EdgeInsets.only(
            top: 20,
            left: 15,
            right: 15,
            bottom: 80,
          ),
          itemBuilder: (context, index) => const ChatSample(),
        ),
      ),
      bottomSheet: Container(
        height: 65,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 2,
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Container(
                alignment: Alignment.centerRight,
                width: 250,
                child: TextFormField(
                  decoration: const InputDecoration(
                      hintText: "Mensaje...", border: InputBorder.none),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(
                Icons.send,
                size: 30,
                color: Colors.green[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
