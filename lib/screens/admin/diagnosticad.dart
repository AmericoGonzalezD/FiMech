import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fimech/model/appointment.dart';
import 'package:fimech/screens/admin/widgets/whatsappbuttonad.dart';
import 'package:fimech/screens/user/galleryscreen.dart';
import 'package:fimech/screens/user/home.dart';
import 'package:fimech/screens/user/widgets/sectionheading.dart';

import '../../services/appointment_service.dart';

class DiagnosticPageAD extends StatefulWidget {
  final Appointment _appointment;
  final Diagnostico _diagnostico;

  const DiagnosticPageAD(this._appointment, this._diagnostico, {super.key});

  @override
  State<DiagnosticPageAD> createState() => _DiagnosticPageADState();
}

class _DiagnosticPageADState extends State<DiagnosticPageAD> {
  void setAppointment(Appointment appointment) {}
  String? userPhoneNumber;

  @override
  void initState() {
    super.initState();
    _getUserPhoneNumber();
  }

  Future<void> _getUserPhoneNumber() async {
    userPhoneNumber = await getUserPhoneNumber(widget._appointment.userId);
    setState(() {}); // To trigger a rebuild with the updated phone number
  }

  Future<void> _cancelCite() async {
    await FirebaseFirestore.instance
        .collection('citas')
        .doc(widget._appointment.id)
        .update({'status': 'Cancelado'});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('La cita se ha cancelado correctamente'),
      ),
    );
    setState(() {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  Future<void> _acceptCite() async {
    await FirebaseFirestore.instance
        .collection('citas')
        .doc(widget._appointment.id)
        .update({
      'costo': "Aceptado",
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('La cotización se ha aceptado correctamente'),
      ),
    );
    setState(() {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Diagnostico',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: (userPhoneNumber == null || userPhoneNumber!.isEmpty)
          ? const SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator()),
            )
          : WhatsappButtonAD(widget._appointment.id, widget._appointment.auto, userPhoneNumber!),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SectionHeading(
                title: "Diagnostico del automovil",
                showActionButton: false,
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Automovil:",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      maxLines: 2,
                      widget._appointment.auto,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.black54),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 14,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Reparacion:",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      maxLines: 2,
                      widget._appointment.motivo,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.black54),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 14,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Descripcion:",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      maxLines: 15,
                      widget._diagnostico.descriptionService,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.black54),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 14,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Costo:",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      maxLines: 15,
                      widget._diagnostico.costo + " MXN",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.black54),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 18,
              ),
              /*Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Imagenes adjuntas:",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      maxLines: 15,
                      "",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.black54),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 14,
              ),
              Expanded(
                child: Flexible(
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    padding: const EdgeInsets.all(8),
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    children: _imagesList(context),
                  ),
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _imagesList(BuildContext context) {
    List<Widget> imagesWidgetsList = [];

    for (var image in images) {
      imagesWidgetsList.add(GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GalleryPage(image: image)));
        },
        child: Hero(
            tag: image,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.network(image, fit: BoxFit.cover),
            )),
      ));
    }

    return imagesWidgetsList;
  }
}

List images = [
  "https://autocentermty.com.mx/wp-content/uploads/2021/08/Reparaciones-generales-1024x683.jpg",
  "https://autocentermty.com.mx/wp-content/uploads/2021/01/Mecanica-express-2.jpg",
  "https://sp-ao.shortpixel.ai/client/to_webp,q_glossy,ret_img,w_1024,h_737/https://carexpress.mx/wp-content/uploads/2020/03/3-1024x737.jpg",
  "https://laopinion.com/wp-content/uploads/sites/3/2019/04/shutterstock_253755247.jpg?w=1200",
  "https://www.apeseg.org.pe/wp-content/uploads/2021/07/GettyImages-1306026621.jpg",
  "https://proautos.com.co/wp-content/uploads/2023/08/10-Ventajas-de-reparar-el-motor-de-tu-auto_1-1080x675.jpg",
];
