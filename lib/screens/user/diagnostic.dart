import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:fimech/model/appointment.dart';
import 'package:fimech/screens/user/galleryscreen.dart';
import 'package:fimech/screens/user/home.dart';
import 'package:fimech/screens/user/widgets/sectionheading.dart';

class DiagnosticPage extends StatefulWidget {
  final Appointment _appointment;
  final Diagnostico _diagnostico;

  const DiagnosticPage(this._appointment, this._diagnostico, {super.key});

  @override
  State<DiagnosticPage> createState() => _DiagnosticPageState();
}

class _DiagnosticPageState extends State<DiagnosticPage> {
  void setAppointment(Appointment appointment) {}

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

  Future<String> getUserEmail(String userId) async {
    var userDoc =
        await FirebaseFirestore.instance.collection('client').doc(userId).get();
    if (userDoc.exists) {
      return userDoc.data()!['email'];
    } else {
      return '';
    }
  }

  Future<String> getUserEmailMecanico(String userId) async {
    var userDoc =
        await FirebaseFirestore.instance.collection('admin').doc(userId).get();
    if (userDoc.exists) {
      return userDoc.data()!['email'];
    } else {
      return '';
    }
  }

  Future<void> _acceptCite() async {
    await FirebaseFirestore.instance
        .collection('citas')
        .doc(widget._appointment.id)
        .update({
      'costo': "Aceptado",
    });
    String userEmail = await getUserEmail(widget._appointment.userId);
    //String userEmailMecanico = await getUserEmail(widget._appointment.userId);
    EmailSender.sendMailFromGmailDiagnostico(userEmail);
    String userEmailMecanico =
        await getUserEmailMecanico(widget._appointment.idMecanico);
    EmailSender.sendMailFromGmailMecanico(
        userEmailMecanico, widget._appointment.auto);
    //EmailSender.sendMailFromGmailDiagnostico(userEmailMecanico);
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      _cancelCite();
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
                          "Rechazar cotizacion",
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
                    onTap: () {
                      _acceptCite();
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
                          "Aceptar Cotización",
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
                height: 14,
              ),
              Row(
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
              ),
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

class EmailSender {
  static final gmailSmtp =
      gmail(dotenv.env["GMAIL_EMAIL"]!, dotenv.env["GMAIL_PASSWORD"]!);

  static Future<void> sendMailFromGmailDiagnostico(String userEmail) async {
    final message = Message()
      ..from = Address(dotenv.env["GMAIL_EMAIL"]!, 'MechanicTracking')
      ..recipients.add(userEmail)
      ..subject = 'Confirmación de diagnostico'
      ..html =
          '<body style="text-align: center; font-family: Tahoma, Geneva, Verdana, sans-serif;"> <div style="margin:auto; border-radius: 10px; width: 300px; padding: 10px; box-shadow: 1px 1px 1px 1px rgb(174, 174, 174);"> <h2>Confirmacion de aceptación de diagnostico</h2> <p>Ha aceptado el diagnostico de reparacion de su vehiculo. El vehiculo entrará en la lista de reparación de inmediato</p><p>Este al pendiente de las actualizaciones del estatus de su vehiculo.</p></div></body>';

    try {
      final sendReport = await send(message, gmailSmtp);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  static Future<void> sendMailFromGmailMecanico(
      String userEmail, String auto) async {
    final message = Message()
      ..from = Address(dotenv.env["GMAIL_EMAIL"]!, 'MechanicTracking')
      ..recipients.add(userEmail)
      ..subject = 'Confirmación de cita'
      ..html =
          '<body style="text-align: center; font-family: Tahoma, Geneva, Verdana, sans-serif;"> <div style="margin:auto; border-radius: 10px; width: 300px; padding: 10px; box-shadow: 1px 1px 1px 1px rgb(174, 174, 174);"> <h2>Nueva cotización aceptada</h2> <p>Hola,</p><p>Un nuevo cliente ha aceptado la cotizacipón propuesta.</p><p>Automovil de la cotización aceptada: $auto</p></div></body>';

    try {
      final sendReport = await send(message, gmailSmtp);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
}
