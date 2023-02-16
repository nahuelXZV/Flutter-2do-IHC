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
import 'package:shake/shake.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../data/data.dart';
import 'form.dart';
// igno../re_for_file: depend_on_referenced_packages

final service = FlutterBackgroundService();
final flutterTts = FlutterTts();
ShakeDetector? detector;
int _counter = 0;
late final SpeakClass _tts;
final Data _data = Data();
late FormClass _form;
late SendLocation _sendLocation;
bool _timeSendSms = true;

Future initializeService() async {
  _initShakeListen();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will executed when app is in foreground or background in separated isolate
      onStart: onStart,
      // auto start service
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
  await service.startService();
}

bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  print('FLUTTER BACKGROUND FETCH');

  return true;
}

void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  _initShakeListen();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      //set as foreground
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) async {
      //set as background
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });
  // bring to foreground
  Timer.periodic(const Duration(seconds: 2), (timer) async {
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "Ayúdame esta encendido",
        content: "Pendientes de tu seguridad",
      );
    }

    // _getFormDone();

    /// you can see this log in logcat
    // print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

    // // test using external plugin
    // service.invoke(
    //   'update',
    //   {
    //     "current_date": DateTime.now().toIso8601String(),
    //     "counter": _counter,
    //   },
    // );
  });
}

void _initShakeListen() async {
  detector = ShakeDetector.waitForStart(onPhoneShake: openApp);
}

void _startListening() async {
  detector?.startListening();
}

void _stopListening() async {
  detector?.stopListening();
}

Future<String> getAddress() async {
  // obtener permiso de ubicacion actual si ya los tengo no pregunto
  if (await Geolocator.isLocationServiceEnabled()) {
    print('location service enabled');
  } else {
    print('location service disabled');
    await Geolocator.requestPermission();
  }

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
    } else if (x <= -10) {
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
    }
  });
}

void openApp() {
  // abrir la aplicacion
  _getFormDone();
  _counter++;
}
