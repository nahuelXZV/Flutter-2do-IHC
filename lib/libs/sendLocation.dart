// ignore: file_names
import 'package:flutter_email_sender/flutter_email_sender.dart';
import '../data/data.dart';
import 'speak.dart';

class SendLocation {
  String nameContact = '';
  String emailContact = '';
  String phoneContact = '';
  String myName = '';
  String _body = '';

  late Data _data;
  final SpeakClass _tts = SpeakClass(3);

  SendLocation(String latitud, String longitud) {
    _data = Data();
    _getData();
    _createBody(latitud, longitud);
  }

  Future<void> _getData() async {
    nameContact = await _data.getData('nameContact');
    emailContact = await _data.getData('emailContact');
    phoneContact = await _data.getData('phoneContact');
    myName = await _data.getData('myName');
  }

  void _createBody(String latitud, String longitud) {
    _body =
        'Hola $nameContact, soy $myName y te envío mi ubicación actual. \n\n';
    _body += 'Mi ubicación actual es: \n\n';
    String _lat = latitud;
    String _lng = longitud;
    _body += 'https://www.google.com/maps/search/?api=1&query=$_lat,$_lng';
  }

  Future<void> send() async {
    final Email email = Email(
      body: _body,
      subject: 'Mi ubicación actual: $myName',
      recipients: [emailContact],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
      _tts.speak('Ubicación enviada');
      Future.delayed(const Duration(seconds: 3));
    } catch (error) {
      print(error);
    }
  }
}
