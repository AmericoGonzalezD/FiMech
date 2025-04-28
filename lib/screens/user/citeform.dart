import 'package:cloud_firestore/cloud_firestore.dart';
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
  String? workshopName;
  String? workshopAddress;
  final TextEditingController _workshopNameController = TextEditingController();
  final TextEditingController _workshopAddressController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserId();
    if (widget.workshopData != null) {
      workshopName = widget.workshopData!['workshopName'];
      workshopAddress = widget.workshopData!['workshopAddress'];
      _workshopNameController.text = workshopName ?? '';
      _workshopAddressController.text = workshopAddress ?? '';
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

      await FirebaseFirestore.instance.collection('citas').add({
        'userId': userId,
        'automovil': _model,
        'date': dateTime,
        'motivo': _reason,
        'status': 'Pendiente',
        'workshopName': workshopName ?? _workshopNameController.text,
        'workshopAddress': workshopAddress ?? _workshopAddressController.text,
      });

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
    children: [
    const SectionHeading(
    title: "Detalles de la cita",
    showActionButton: false,
    ),
    const SizedBox(height: 30),
    if (workshopName != null)
    Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text(
    "Taller seleccionado:",
    style: TextStyle(
    fontSize: 16, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 6),
    Text(
    workshopName!,
    style: const TextStyle(fontSize: 14),
    ),
    const SizedBox(height: 12),
    const Text(
    "Dirección del taller:",
    style: TextStyle(
    fontSize: 16, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 6),
    Text(
    workshopAddress!,
    style: const TextStyle(fontSize: 14),
    ),
    const SizedBox(height: 24),
    ],
    )
    else
    Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text(
    "Nombre del taller:",
    style: TextStyle(
    fontSize: 16, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 6),
    TextFormField(
    controller: _workshopNameController,
    decoration: const InputDecoration(
    hintText: 'Ingrese el nombre del taller',
    hintStyle: TextStyle(fontSize: 14)),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Por favor, ingrese el nombre del taller';
    }
    return null;
    },
    ),
    const SizedBox(height: 24),
    const Text(
    "Dirección del taller:",
    style: TextStyle(
    fontSize: 16, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 6),
    TextFormField(
    controller: _workshopAddressController,
    decoration: const InputDecoration(
    hintText: 'Ingrese la dirección del taller',
    hintStyle: TextStyle(fontSize: 14)),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Por favor, ingrese la dirección del taller';
    }
    return null;
    },
    ),
    const SizedBox(height: 24),
    ],
    ),
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
              setState(
                      () {}); // Actualiza la pantalla después de guardar la cita
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