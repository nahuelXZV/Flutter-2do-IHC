import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_background_service/flutter_background_service.dart'
    show
        AndroidConfiguration,
        FlutterBackgroundService,
        IosConfiguration,
        ServiceInstance;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ihc_maps/libs/sendLocation.dart';
import 'package:ihc_maps/libs/speak.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../data/data.dart';
import 'form.dart';

final service = FlutterBackgroundService();
final flutterTts = FlutterTts();
int _counter = 0;
late SpeakClass _tts;
final Data _data = Data();
late FormClass _form;
late SendLocation _sendLocation;
bool _timeSendSms = true;

Future initializeService() async {
  _tts = SpeakClass(3);
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
  await service.startService();
}

bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}

void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) async {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });
  Timer.periodic(const Duration(seconds: 2), (timer) async {
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "Ayúdame esta encendido",
        content: "Pendientes de tu seguridad",
      );
    }
    _getFormDone();
  });
}

Future<String> getAddress() async {
  // obtener permiso de ubicacion guardada
  String _lat = await _data.getData('lat');
  String _lon = await _data.getData('lon');

  // pasar a double
  double _late = double.parse(_lat);
  double _long = double.parse(_lon);

  // Convierte las coordenadas de la ubicación actual en una dirección
  List<Placemark> placemarks = await placemarkFromCoordinates(_late, _long);
  Placemark place = placemarks[0];

  // Construye la dirección como una cadena de texto
  String address =
      '${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}';
  return address;
}

Future<void> _getFormDone() async {
  String name = await _data.getData('name');
  String phone = await _data.getData('phone');
  String myName = await _data.getData('myName');
  if (name != '' && phone != '' && myName != '') {
    _menuSensor();
  }
}

Future<void> _menuSensor() async {
  var giroscopio;
  String address = '';
  double x = 0;
  giroscopio = accelerometerEvents.listen((AccelerometerEvent event) async {
    x = event.x;
    if (x > 8 || x <= -10) {
      //Opcion de decir la ubicacion actual
      print('izquierda | derecha');
      getAddress().then((value) {
        address = 'Su direccion actual es: $value';
        print(value);
        _tts = SpeakClass(3);
        _tts.speak(address);
        Future.delayed(const Duration(seconds: 10), () {});
      }).catchError((error) => print(error));
    }
  });
}
