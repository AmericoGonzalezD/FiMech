import "package:custom_clippers/custom_clippers.dart";
import "package:flutter/material.dart";

class ChatSampleAD extends StatelessWidget {
  const ChatSampleAD({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 80),
          child: ClipPath(
            clipper: UpperNipMessageClipper(MessageType.receive),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
              child: Text(
                "Hola, que puedo hacer por ti?",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
        Container(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 80),
            child: ClipPath(
              clipper: LowerNipMessageClipper(MessageType.send),
              child: Container(
                padding:
                    const EdgeInsets.only(left: 20, top: 10, bottom: 25, right: 20),
                decoration: BoxDecoration(color: Colors.green[200]),
                child: Text("Buenas tardes, me gustaria saber el estatus de mi auto", style: TextStyle(fontSize: 16),),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
