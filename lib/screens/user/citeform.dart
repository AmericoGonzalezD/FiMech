import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fimech/services/appointment_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fimech/screens/user/home.dart';
import 'package:fimech/screens/user/widgets/sectionheading.dart';

class CiteForm extends StatefulWidget {
  final Map<String, dynamic>? workshopData;

  const CiteForm({super.key, this.workshopData});

  @override
  State<CiteForm> createState() => _CiteFormState();
}

class _CiteFormState extends State<CiteForm> {
  late String userId;
  String? selectedWorkshopName;
  String? workshopAddress;
  final TextEditingController _workshopAddressController =
  TextEditingController();
  List<Map<String, dynamic>> workshops = [];

  @override
  void initState() {
    super.initState();
    getUserId();
    _loadWorkshops();
    if (widget.workshopData != null) {
      selectedWorkshopName = widget.workshopData!['workshopName'];
      workshopAddress = widget.workshopData!['workshopAddress'];
      _workshopAddressController.text = workshopAddress ?? '';
    }
  }

  Future<void> _loadWorkshops() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance
          .collection('admin')
          .where('isMechanic', isEqualTo: true)
          .get();
      setState(() {
        workshops = snapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      print("Error loading workshops: $e");
      // Handle error appropriately
    }
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
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final DateTime dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Verificar si ya existe una cita en la misma fecha y hora
      QuerySnapshot existingAppointments = await FirebaseFirestore.instance
          .collection('citas')
          .where('date', isEqualTo: dateTime)
          .get();

      if (existingAppointments.docs.isNotEmpty) {
        // Mostrar alerta si ya hay una cita en ese horario
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Cita no disponible'),
              content: const Text('Ya existe una cita agendada en esta fecha y hora. Por favor, elige otro horario.'),
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
        return; // Detener el proceso de guardado
      }

      // Si no hay citas en esa fecha y hora, proceder con la creación
      DocumentReference appointmentRef =
      await FirebaseFirestore.instance.collection('citas').add({
        'userId': userId,
        'automovil': _model,
        'date': dateTime,
        'motivo': _reason,
        'status': 'Pendiente',
        'workshopName': selectedWorkshopName,
        'workshopAddress': _workshopAddressController.text,
        'status2': 'Pendiente',
        'reason': 'Evaluando proceso',
        'reason2': 'Evaluando proceso',
        'progreso': 'Pendiente de evaluar',
        'progreso2': '',
        'date_update': dateTime,
        'costo': "",
        'idMecanico': "",
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

      // Obtener el email del usuario
      String userEmail = await getUserEmail(userId);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La cita se ha agendado correctamente'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Agendar Cita',
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
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const SectionHeading(
    title: "Detalles de la cita",
    showActionButton: false,
    ),
    const SizedBox(height: 30),
    const Text(
    "Taller seleccionado:",
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 6),
    DropdownButtonFormField<String>(
    decoration: const InputDecoration(
    hintText: 'Seleccione un taller',
    border: OutlineInputBorder(),
    ),
    value: selectedWorkshopName,
    items: workshops.map((workshop) {
    return DropdownMenuItem<String>(
    value: workshop['workshopName'],
    child: Text(workshop['workshopName'] ?? 'Nombre no disponible'),
    );
    }).toList(),
    onChanged: (String? newValue) {
    setState(() {
    selectedWorkshopName = newValue;
    workshopAddress = workshops.firstWhere(
    (workshop) => workshop['workshopName'] == newValue,
    orElse: () => {},
    )['workshopAddress'];
    _workshopAddressController.text = workshopAddress ?? '';
    });
    },
    validator: (value) {
    if(value == null || value.isEmpty) {
      return 'Por favor, seleccione un taller';
    }
    return null;
    },
    ),
      const SizedBox(height: 24),
      const Text(
        "Dirección del taller:",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 6),
      TextFormField(
        controller: _workshopAddressController,
        readOnly: true, // La dirección se rellena automáticamente
        decoration: const InputDecoration(
          hintText: 'La dirección del taller se mostrará aquí',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 24),
      Container(
        alignment: Alignment.centerLeft,
        child: const Text(
          "Ingresa el modelo de automovil:",
          style:
          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      const SizedBox(height: 6),
      TextFormField(
        decoration: const InputDecoration(
            hintText: 'Modelo del automóvil',
            border: OutlineInputBorder(),
            hintStyle: TextStyle(fontSize: 14)),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, ingrese un modelo';
          }
          return null;
        },
        onSaved: (value) => _model = value!,
      ),
      const SizedBox(height: 24),
      Container(
        alignment: Alignment.centerLeft,
        child: const Text(
          "Ingresa el motivo:",
          style:
          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      const SizedBox(height: 6),
      TextFormField(
        decoration: const InputDecoration(
            hintText: 'Motivo de la cita',
            border: OutlineInputBorder(),
            hintStyle: TextStyle(fontSize: 14)),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, ingrese un motivo';
          }
          return null;
        },
        onSaved: (value) => _reason = value!,
      ),
      const SizedBox(height: 24),
      Container(
        alignment: Alignment.centerLeft,
        child: const Text(
          "Ingresa el día y hora:",
          style:
          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      const SizedBox(height: 6),
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
          const SizedBox(width: 10),
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
      const SizedBox(height: 30),
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
              setState(() {}); // Actualiza la pantalla después de guardar la cita
            },
            child: Container(
              width: 150,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF258EB4),
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