// ignore_for_file: library_private_types_in_public_api
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'libs/speak.dart';
import 'libs/microphono.dart';
import 'data/data.dart';
import 'libs/form.dart';
import 'libs/sendLocation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  _SpeechToTextDemoState createState() => _SpeechToTextDemoState();
}

class _SpeechToTextDemoState extends State<Principal>
    with WidgetsBindingObserver {
  late final SpeakClass _tts;
  final Data _data = Data();
  late FormClass _form;
  late SendLocation _sendLocation;
  bool _timeSendSms = true;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _getFormDone();
    // mostrar los datos de name, phone y myName

    _data.getData('name').then((value) => print('name: $value'));
    _data.getData('phone').then((value) => print('phone: $value'));
    _data.getData('myName').then((value) => print('myName: $value'));
  }

  Future<String> getAddress() async {
    // obtener permiso de ubicacion actual
    await Geolocator.requestPermission();
    // Obtiene la ubicación actual del usuario
    Position position = await Geolocator.getCurrentPosition();

    // Convierte las coordenadas de la ubicación actual en una dirección
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];

    // Construye la dirección como una cadena de texto
    String address =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}';
    return address;
  }

  Future<void> _getFormDone() async {
    bool seen = await _data.getDataBool('seen');
    String name = await _data.getData('name');
    String phone = await _data.getData('phone');
    String myName = await _data.getData('myName');
    print('formDonePrincipal: $seen');
    if (name != '' && phone != '' && myName != '') {
      _tts = SpeakClass(1);
      Future.delayed(const Duration(seconds: 10), () {});
      _menuSensor();
    } else {
      _initForm();
      await _data.saveDataBool('seen', false);
      _menuSensor();
    }
  }

  Future<void> _menuSensor() async {
    var giroscopio;
    String address = '';
    double x = 0, y =0;
    giroscopio = accelerometerEvents.listen((AccelerometerEvent event) async {
      x = event.x;
      y = event.y;
      if (x > 8) {
        //Opcion de decir la ubicacion actual
        print('izquierda');
        // giroscopio.cancel();
        getAddress().then((value) {
          address = 'Su direccion actual es: $value';
          print(value);
          _tts.speak(address);
          Future.delayed(const Duration(seconds: 10), () {});
        }).catchError((error) => print(error));
      } else if (x <= -8) {
        //Opcion de enviar la ubicacion actual
        print('derecha');
        // giroscopio.cancel();
        Position position = await Geolocator.getCurrentPosition();
        // pasar de double a string
        String lat = position.latitude.toString();
        String lon = position.longitude.toString();
        if (_timeSendSms) {
          _sendLocation = SendLocation(lat, lon);
          _sendLocation.sendSms();
          _timeSendSms = false;
        }
        Future.delayed(const Duration(minutes: 1), () {
          _timeSendSms = true;
        });
      }else if(y > 8){
      }
    });
  }

  _initForm() async {
    _form = FormClass();
    Future.delayed(const Duration(seconds: 9), () async {
      await _form.questions();
      _tts = SpeakClass(2);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        _tts.dispose();
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Ayúdame'),
          backgroundColor: Color.fromARGB(255, 243, 104, 62),
        ),
        body: Container(
          child: Center(
            child: Image.asset('assets/images/ayudame.png'),
          ),
        ),
      ),
    );
  }
}
