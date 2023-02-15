// ignore: file_names
import '../data/data.dart';
import 'speak.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:permission_handler/permission_handler.dart';

class SendLocation {
  String nameContact = '';
  String phoneContact = '';
  String myName = '';
  String _body = '';

  late Data _data;
  late final SpeakClass _tts;

  SendLocation(String latitud, String longitud) {
    _data = Data();
    _tts = SpeakClass(3);
    _getData();
    _createBody(latitud, longitud);
  }

  Future<void> _getData() async {
    myName = await _data.getData('myName');
    nameContact = await _data.getData('nameContact');
    phoneContact = await _data.getData('phoneContact');
    if (phoneContact.isEmpty || phoneContact == null) phoneContact = '69341427';
    if (phoneContact.length >= 9) {
      phoneContact = phoneContact.substring(0, 8);
    }
    phoneContact = '+591$phoneContact';
  }

  void _createBody(String latitud, String longitud) {
    _body =
        'Hola $nameContact, soy $myName y te envío mi ubicación actual. \n\n';
    _body += 'Mi ubicación actual es: \n\n';
    String _lat = latitud;
    String _lng = longitud;
    _body += 'https://www.google.com/maps/search/?api=1&query=$_lat,$_lng';
  }

  sendSms() async {
    if (await Permission.sms.request().isGranted) {
      String _result = await sendSMS(
          message: _body, recipients: [phoneContact], sendDirect: true);
      print(_result);
      _tts.speak('Mensaje enviado');
    } else {
      print('No se pudo enviar el SMS');
      _tts.speak('No se pudo enviar el SMS');
    }
  }
}
