import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:fimech/screens/user/schedule.dart';
import 'package:fimech/screens/user/widgets/sectionheading.dart';
import 'package:fimech/services/appointment_service.dart';

class CiteForm extends StatefulWidget {
  final Map<String, dynamic>? workshopData;
  const CiteForm({super.key, required this.workshopData});

  @override
  State<CiteForm> createState() => _CiteFormState();
}

class _CiteFormState extends State<CiteForm> {
  late String userId;
  // Lista de talleres disponibles
  List<Map<String, String>> _workshops = [];
  bool _isLoadingWorkshops = false;
  String? _selectedWorkshopId; // id del taller seleccionado
  String? _selectedWorkshopName;
  String? _selectedWorkshopAddress;
  // Preferencia del usuario
  String? _userPreferredWorkshopId;
  String? _userPreferredWorkshopName;

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
      // Cargar preferencia del usuario y talleres disponibles
      await _loadUserPreferredWorkshop();
      await _loadWorkshops();
      // Si se pasó workshopData desde la pantalla de Talleres, úsalo como predeterminado
      if (widget.workshopData != null && widget.workshopData!['id'] != null) {
        final wid = widget.workshopData!['id'] as String;
        _selectedWorkshopId = wid;
        _selectedWorkshopName = widget.workshopData!['workshopName'] as String? ?? widget.workshopData!['name'] as String?;
        _selectedWorkshopAddress = widget.workshopData!['workshopAddress'] as String? ?? '';
      }
    } else {
      userId = '';
    }
  }

  Future<void> _loadUserPreferredWorkshop() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('client').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        _userPreferredWorkshopId = (data?['preferredWorkshopId'] as String?) ?? '';
        _userPreferredWorkshopName = (data?['preferredWorkshopName'] as String?) ?? '';
        // Inicialmente seleccionar la preferencia del usuario
        if ((_userPreferredWorkshopId ?? '').isNotEmpty) {
          _selectedWorkshopId = _userPreferredWorkshopId;
          _selectedWorkshopName = _userPreferredWorkshopName;
        }
      }
    } catch (e) {
      debugPrint('Error cargando preferencia de taller del usuario: $e');
    }
    setState(() {});
  }

  Future<void> _loadWorkshops() async {
    setState(() {
      _isLoadingWorkshops = true;
    });
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('admin')
          .where('isMechanic', isEqualTo: true)
          .get();
      _workshops = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': (data['workshopName'] ?? data['name'] ?? 'Taller sin nombre') as String,
          'address': (data['workshopAddress'] ?? '') as String,
        };
      }).toList();

      // Si no hay selección pero el usuario tiene preferencia, intentar poblarla con la info de la lista
      if ((_selectedWorkshopId ?? '').isNotEmpty) {
        final sel = _workshops.firstWhere(
            (w) => w['id'] == _selectedWorkshopId,
            orElse: () => {});
        if (sel.isNotEmpty) {
          _selectedWorkshopName = sel['name'];
          _selectedWorkshopAddress = sel['address'];
        }
      }
      // Si no se seleccionó ningún taller pero la pantalla fue abierta desde TalleresScreen con data, aplicar la selección ahora
      if ((_selectedWorkshopId ?? '').isEmpty && widget.workshopData != null && widget.workshopData!['id'] != null) {
        final wid = widget.workshopData!['id'] as String;
        final sel2 = _workshops.firstWhere((w) => w['id'] == wid, orElse: () => {});
        if (sel2.isNotEmpty) {
          _selectedWorkshopId = sel2['id'];
          _selectedWorkshopName = sel2['name'];
          _selectedWorkshopAddress = sel2['address'];
        }
      }
    } catch (e) {
      debugPrint('Error cargando talleres: $e');
      _workshops = [];
    } finally {
      setState(() {
        _isLoadingWorkshops = false;
      });
    }
  }

  // Estado de la cita
  final _formKey = GlobalKey<FormState>();
  String _model = '';
  String _reason = '';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<String> getUserEmail(String userId) async {
    var userDoc =
        await FirebaseFirestore.instance.collection('client').doc(userId).get();
    if (userDoc.exists) {
      return userDoc.data()!['email'];
    } else {
      return '';
    }
  }

  void _selectTime() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (newTime != null) {
      final DateTime selectedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        newTime.hour,
        newTime.minute,
      );

      // Verificar si la hora seleccionada está dentro del rango permitido
      final TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
      final TimeOfDay endTime = const TimeOfDay(hour: 17, minute: 0);

      if (_isTimeInRange(newTime, startTime, endTime)) {
        setState(() {
          _selectedTime = newTime;
          _selectedDate = selectedDateTime;
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Hora no válida'),
              content: const Text(
                  'Por favor, seleccione una hora entre las 9 am y las 5 pm.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        );
      }
    }
  }
//Configuración de limite de agendar hora
  bool _isTimeInRange(TimeOfDay time, TimeOfDay startTime, TimeOfDay endTime) {
    final int hour = time.hour;
    final int minute = time.minute;

    final int startHour = startTime.hour;
    final int startMinute = startTime.minute;

    final int endHour = endTime.hour;
    final int endMinute = endTime.minute;

    if (hour < startHour || (hour == startHour && minute < startMinute)) {
      return false;
    }

    if (hour > endHour || (hour == endHour && minute > endMinute)) {
      return false;
    }

    return true;
  }

  Future<String> IdCiti(String userId) async {
    var citiId =
        await AppointmentService().getAppointmentTraking(userId, "Pendiente");
    return citiId.id;
  }

  Future<void> _saveCite() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingrese todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _formKey.currentState!.save();
    final DateTime dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Validar que la hora esté dentro del rango permitido (9:00 - 17:00)
    final TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    final TimeOfDay endTime = const TimeOfDay(hour: 17, minute: 0);
    if (!_isTimeInRange(_selectedTime, startTime, endTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione una hora entre las 9:00 y las 17:00'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar que la fecha/hora no esté en el pasado
    if (dateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha y hora seleccionada no puede estar en el pasado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    DocumentReference appointmentRef =
        await FirebaseFirestore.instance.collection('citas').add({
      'userId': userId,
      'automovil': _model,
      'date': dateTime,
      'motivo': _reason,
      'status': 'Pendiente',
      'status2': 'Pendiente',
      'reason': 'Evaluando proceso',
      'reason2': 'Evaluando proceso',
      'progreso': 'Pendiente de evaluar',
      'progreso2': '',
      'date_update': dateTime,
      'costo': "",
      'idMecanico': _selectedWorkshopId ?? '',
      'workshopName': _selectedWorkshopName ?? '',
      'workshopAddress': _selectedWorkshopAddress ?? '',
      'descriptionService': "",
    });

    await appointmentRef.collection('citasDiagnostico').doc('Aceptado').set({
      'progreso2': "",
      'date_update': dateTime,
      'reason2': "",
      'costo': "",
      'descriptionService': "",
      'status2': '',
    }, SetOptions(merge: true));
    await appointmentRef
        .collection('citasDiagnostico')
        .doc('Completado')
        .set({
      'progreso2': "",
      'date_update': dateTime,
      'reason2': "",
      'costo': "",
      'descriptionService': "",
      'status2': '',
    }, SetOptions(merge: true));
    await appointmentRef
        .collection('citasDiagnostico')
        .doc('Reparacion')
        .set({
      'progreso2': "",
      'date_update': dateTime,
      'reason2': "",
      'costo': "",
      'descriptionService': "",
      'status2': '',
    }, SetOptions(merge: true));
    await appointmentRef.collection('citasDiagnostico').doc('Revision').set({
      'progreso2': "",
      'date_update': dateTime,
      'reason2': "",
      'costo': "",
      'descriptionService': "",
      'status2': '',
    }, SetOptions(merge: true));
    // Obtener el email del usuario

    String userEmail = await getUserEmail(userId);

    // Enviar correo con confirmación
    EmailSender.sendMailFromGmail(userEmail);

    // Mostrar SnackBar de confirmación e información adicional
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('La cita se ha agendado correctamente. Se le enviarán actualizaciones por correo.'),
        duration: Duration(seconds: 2),
      ),
    );

    // Dar tiempo al usuario para ver el SnackBar y luego navegar a Home
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    // Navegar al calendario mostrando el botón de regreso (para volver al formulario)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SchedulePage(showReturnButton: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xF3FFF8F2),
        title: const Text(
          'Agendar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SectionHeading(
                    title: "Detalles de la cita",
                    showActionButton: false,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Ingresa el modelo de automovil:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                        hintText: 'Modelo del automóvil',
                        hintStyle: TextStyle(fontSize: 14)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese un modelo';
                      }
                      return null;
                    },
                    onSaved: (value) => _model = value!,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Ingresa el motivo:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                        hintText: 'Motivo de la cita',
                        hintStyle: TextStyle(fontSize: 14)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese un motivo';
                      }
                      return null;
                    },
                    onSaved: (value) => _reason = value!,
                  ),
                  const SizedBox(
                    height: 24,
                  ),

                  // Dropdown para seleccionar taller
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Selecciona el taller:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _isLoadingWorkshops
                      ? const SizedBox(height: 40, child: Center(child: CircularProgressIndicator()))
                      : DropdownButtonFormField<String>(
                    initialValue: _selectedWorkshopId == '' ? null : _selectedWorkshopId,
                    hint: const Text('Seleccione un taller'),
                    items: [
                      ..._workshops.map((w) => DropdownMenuItem<String>(
                        value: w['id'],
                        child: Text(w['name'] ?? 'Taller'),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedWorkshopId = value ?? '';
                        if ((_selectedWorkshopId ?? '').isEmpty) {
                          _selectedWorkshopName = '';
                          _selectedWorkshopAddress = '';
                        } else {
                          final sel = _workshops.firstWhere((e) => e['id'] == _selectedWorkshopId, orElse: () => {});
                          if (sel.isNotEmpty) {
                            _selectedWorkshopName = sel['name'];
                            _selectedWorkshopAddress = sel['address'];
                          } else {
                            _selectedWorkshopName = '';
                            _selectedWorkshopAddress = '';
                          }
                        }
                      });
                    },
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Ingresa el día y hora:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox( height: 2,),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "* El horario de atención es de 9:00 am a 5:00 pm",
                      style:
                      TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: _selectDate,
                          child: Text(
                            'Fecha: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: _selectTime,
                          child: Text(
                            'Hora: ${_selectedTime.format(context)}',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 150,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              "Cancelar",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          await _saveCite();
                          //sendMail();
                          setState(
                              () {}); // Actualiza la pantalla después de guardar la cita
                        },
                        child: Container(
                          width: 150,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.green[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              "Guardar",
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
/*Metodo para mandar correo al momento de agendar una cita*/

class EmailSender {
  static final gmailSmtp =
      gmail(dotenv.env["GMAIL_EMAIL"]!, dotenv.env["GMAIL_PASSWORD"]!);

  static Future<void> sendMailFromGmail(String userEmail) async {
    final message = Message()
      ..from = Address(dotenv.env["GMAIL_EMAIL"]!, 'MechanicTracking')
      ..recipients.add(userEmail)
      ..subject = 'Confirmación de cita'
      ..html =
          '<body style="text-align: center; font-family: Tahoma, Geneva, Verdana, sans-serif;"> <div style="margin:auto; border-radius: 10px; width: 300px; padding: 10px; box-shadow: 1px 1px 1px 1px rgb(174, 174, 174);"> <h2>Hola, se ha agendado la cita en la lista de espera del taller mecanico</h2> <p>Espere a nuevas actualizaciones para saber sobre su estatus</p></div></body>';

    try {
      await send(message, gmailSmtp);
    } on MailerException {
      // Message not sent - handle or log as needed
    }
  }
}
