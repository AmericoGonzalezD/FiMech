import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fimech/model/appointment.dart';
import 'package:fimech/screens/admin/trackingdetailsad.dart';
import 'package:fimech/services/appointment_service.dart';

class ActualTrackingAD extends StatefulWidget {
  const ActualTrackingAD({super.key});

  @override
  State<ActualTrackingAD> createState() => _ActualTrackingADState();
}

class _ActualTrackingADState extends State<ActualTrackingAD> {
  late String userId;

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  Future<void> getUserId() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    } else {
      userId = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Appointment>>(
      future: AppointmentService().getAllAppointments1(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<Appointment> appointments = snapshot.data ?? [];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Servicios Pendientes",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 15),
                SingleChildScrollView(
                  child: Column(
                    children: appointments.map((appointment) {
                      if (appointment.costo == "Aceptado") {
                        return CardAppointment(appointment.id, appointment);
                      } else if (appointment.costo != "Aceptado" &&
                          appointment.status2 != "Reparacion") {
                        return CardAppointment(appointment.id,
                            appointment); // O cualquier otro widget que no ocupe espacio
                      } else {
                        return Container();
                      }
                    }).toList(),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class CardAppointment extends StatefulWidget {
  final String appointmentId;
  final Appointment appointment_1;
  const CardAppointment(this.appointmentId, this.appointment_1, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _CardAppointmentState();
  }
}

class _CardAppointmentState extends State<CardAppointment> {
  Appointment? _appointment; //state local
  late String userId;

  Future<void> getUserId() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    } else {
      userId = '';
    }
  }

  @override
  void initState() {
    super.initState();
    _getAppointment(widget.appointmentId);
    getUserId();
  }

  void _getAppointment(String appointmentId) async {
    var appointment = await AppointmentService().getAppointment(appointmentId);
    setState(() {
      _appointment = appointment;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Appointment> appointments = [];

    if (_appointment == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (_appointment!.status == "Pendiente") {
      appointments.add(_appointment!);
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                spreadRadius: 2,
              ),
            ],
          ),
          
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    _appointment!.auto,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(_appointment!.motivo),
                  trailing: const CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(
                        "https://patiodeautos.com/wp-content/uploads/2018/09/6-consejos-para-convertirte-en-un-mejor-mecanico-de-autos.jpg"),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Divider(
                    thickness: 1,
                    height: 20,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Actualizado: ",
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          DateFormat('dd/MM/yyyy').format(_appointment!.date),
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_filled,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          DateFormat.jm().format(_appointment!.date),
                          style: const TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        _openTrackingDetails(context, _appointment);
                      },
                      child: Container(
                        width: 300,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Color(0xFF258EB4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            "Ver detalles",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
     
      );
    } else {
      if (appointments.isEmpty) {
        return Container();
      } else {
        return Container(); //
      }
    }
  }

  void _openTrackingDetails(BuildContext context, Appointment? appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TrackDetailsPageAD(appointment!)),
    );
  }
}
