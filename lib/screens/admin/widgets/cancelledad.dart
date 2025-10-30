import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fimech/model/appointment.dart';
import 'package:fimech/screens/user/scheduledetails.dart';
import 'package:fimech/services/appointment_service.dart';

class CancelledScheduleAD extends StatefulWidget {
  const CancelledScheduleAD({super.key});

  @override
  State<CancelledScheduleAD> createState() => _CancelledScheduleADState();
}

class _CancelledScheduleADState extends State<CancelledScheduleAD> {
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

  Future<List<Appointment>> _fetchCancelledAppointmentsForMechanic(
      String mechanicId) async {
    try {
      final appointments = await AppointmentService()
          .getAllAppointments(mechanicId, "Cancelado");
      return appointments;
    } catch (e) {
      // Error fetching cancelled appointments
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Appointment>>(
      future: _fetchCancelledAppointmentsForMechanic(userId),
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
                  "Citas Canceladas",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 15),
                appointments.isNotEmpty
                    ? SingleChildScrollView(
                  child: Column(
                    children: appointments.map((appointment) {
                      return CardAppointment(appointment.id, appointment);
                    }).toList(),
                  ),
                )
                    : const _NoCancelledAppointmentsMessage(),
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

class _NoCancelledAppointmentsMessage extends StatelessWidget {
  const _NoCancelledAppointmentsMessage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 45,
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
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Aún no tiene servicios cancelados",
              style: TextStyle(color: Colors.black54),
            )
          ],
        ),
      ),
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

  @override
  void initState() {
    super.initState();
    _getAppointment(widget.appointmentId);
  }

  void _getAppointment(String appointmentId) async {
    var appointment = await AppointmentService().getAppointment(appointmentId);
    setState(() {
      _appointment = appointment;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_appointment == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (_appointment!.status == "Cancelado") {
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
                  _appointment!.auto, //signo porque puede ser nulo
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(_appointment!.motivo),
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
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _appointment!.status,
                        style: const TextStyle(color: Colors.black54),
                      ),
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
                      _openAppointmentDetails(context, _appointment);
                    },
                    child: Container(
                      width: 300,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.green[300],
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
      return const SizedBox.shrink(); // No mostrar nada si no está cancelado
    }
  }

  void _openAppointmentDetails(BuildContext context, Appointment? appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ScheduleDetailsPage(appointment!)),
    );
  }
}