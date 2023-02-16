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
    _getData(latitud, longitud);
  }

  Future<void> _getData(String latitud, String longitud) async {
    myName = await _data.getData('myName');
    nameContact = await _data.getData('name');
    phoneContact = await _data.getData('phone');
    if (phoneContact.isEmpty || phoneContact == null) phoneContact = '69341427';
    if (phoneContact.length >= 9) {
      phoneContact = phoneContact.substring(0, 8);
    }
    phoneContact = '+591$phoneContact';
    _createBody(latitud, longitud);
  }

  void _createBody(String latitud, String longitud) {
    _body =
        'Hola $nameContact, soy $myName y te envío mi ubicación actual. \n\n';
    _body += 'Mi ubicación actual es: \n\n';
    String lat = latitud;
    String lng = longitud;
    _body += 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
  }

  sendSms() async {
    if (await Permission.sms.request().isGranted) {
      print(_body);
      String _result = await sendSMS(
          message: _body, recipients: [phoneContact], sendDirect: true);
      _tts.speak('Mensaje enviado');
    } else {
      print('No se pudo enviar el SMS');
      _tts.speak('No se pudo enviar el SMS');
    }
  }
}
