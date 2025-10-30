import 'package:flutter/material.dart';
import 'package:fimech/screens/user/home.dart';
import 'package:fimech/screens/user/widgets/actualtracking.dart';
import 'package:fimech/screens/user/widgets/completedtracking.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  int _buttonIndex = 0;
  final _ScheduleWidgets = [
    const ActualTracking(),
    //CompletedWidget
    const CompletedTracking(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xF3FFF8F2),
        title: const Text(
          'Seguimiento',
          style: TextStyle(fontWeight: FontWeight.bold),
        ), // Título de la barra de aplicación
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  "Servicios",
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
                height: 56,
                width: MediaQuery.of(context).size.width,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _buttonIndex = 0;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 50),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: _buttonIndex == 0
                                  ? Colors.green[300]
                                  : Colors.grey[100],
                            ),
                            child: Text("Actuales",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: _buttonIndex == 0
                                      ? Colors.black
                                      : Colors.black38,
                                )),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _buttonIndex = 1;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 30),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: _buttonIndex == 1
                                  ? Colors.green[300]
                                  : Colors.grey[100],
                            ),
                            child: Text("Completados",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: _buttonIndex == 1
                                      ? Colors.black
                                      : Colors.black38,
                                )),
                          ),
                        ),
                      ],
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
    );
  }
}
