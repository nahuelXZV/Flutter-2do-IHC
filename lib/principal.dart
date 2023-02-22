// ignore_for_file: library_private_types_in_public_api
import 'package:flutter_background_service/flutter_background_service.dart'
    show
        AndroidConfiguration,
        FlutterBackgroundService,
        IosConfiguration,
        ServiceInstance;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'libs/speak.dart';
import 'data/data.dart';
import 'libs/form.dart';
import 'libs/sendLocation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

    await _data.saveData('lat', position.latitude.toString());
    await _data.saveData('lon', position.longitude.toString());
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
      _initForm(1);
      await _data.saveDataBool('seen', false);
      _menuSensor();
    }
  }

  Future<void> _menuSensor() async {
    var acelerometro;
    String address = '';
    double x = 0, y = 0;
    acelerometro = accelerometerEvents.listen((AccelerometerEvent event) async {
      x = event.x;
      y = event.y;
      if (x > 8) {
        //Opcion de decir la ubicacion actual
        print('izquierda');
        // acelerometro.cancel();
        getAddress().then((value) {
          address = 'Su direccion actual es: $value';
          print(value);
          _tts.speak(address);
          Future.delayed(const Duration(seconds: 10), () {});
        }).catchError((error) => print(error));
      } else if (x <= -8) {
        //Opcion de enviar la ubicacion actual
        print('derecha');
        // acelerometro.cancel();
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
      } else if (y <= -5) {
        print('atras');
        _initForm(2);
      }else if(y >= 5){
        print('adelante');
        _lugaresCercanos();
      }
    });
  }

  _lugaresCercanos() async{
    Position position = await Geolocator.getCurrentPosition();
    String lat = position.latitude.toString();
    String lon = position.longitude.toString();
    String url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lon&radius=70&key=YOUR_KEY';
    var response = await http.get(Uri.parse(url)).onError((error, stackTrace) => _tts.speak('Conectate a internet por favor'));
    if(response.statusCode==200){
      var apiLugares = (json.decode(response.body))['results'];
      List<String> listaLugares = [];
      for (var lugar in apiLugares) {
        listaLugares.add(lugar['name']);
      }
      String lugares = 'Los lugares cercanos son: ';
      int c = 0;
      for (var i = 0; i < listaLugares.length ; i++) {
        lugares = '$lugares${listaLugares[i]}  ,  ';
        c++;
        if(c == 4) break;
      }
      lugares = lugares.toLowerCase();
      if(lugares == "") {
        _tts.speak('No hay lugares cercanos');
      }else {
        print(lugares);
        _tts.speak(lugares);
      }
    }else{
      print('error');
      _tts.speak('Ocurrio un error');
    }
  }

  _initForm(type) async {
    _form = FormClass(type);
    Future.delayed(const Duration(seconds: 9), () async {
      await _form.questions();
      if (type == 1) _tts = SpeakClass(2);
    });
  }

  Future<void> _startService() async {
    final service = FlutterBackgroundService();
    var isRunning = await service.isRunning();
    print('isRunning: $isRunning');
    if (!isRunning) {
      service.startService();
    } else {
      service.invoke("stopService");
    }
  }

  @override
  void dispose() {
    // cuando se cierra la app
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    _startService();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // cuando se minimiza la app
    switch (state) {
      case AppLifecycleState.resumed: // cuando se vuelve a abrir la app
        _startService();
        break;
      case AppLifecycleState.inactive: // cuando se minimiza la app
        _tts.dispose();
        _startService();
        break;
      case AppLifecycleState.paused: // cuando se minimiza la app
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromARGB(233, 225, 225, 225),
        appBar: AppBar(
          title: const Text(
            'Ayúdame',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
            ),
          ),
          backgroundColor: Color.fromARGB(255, 243, 104, 62),
          centerTitle: true,
          elevation: 14,
          toolbarHeight: 80,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          )),
        ),
        body: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/ayudame.png'),
              const SizedBox(height: 20), // Espacio entre el texto y el icono
              Container(
                height: 70,
                width: 70,
                alignment: Alignment.center,
                decoration: const BoxDecoration(boxShadow: [
                  BoxShadow(blurRadius: 7, spreadRadius: 3, color: Color.fromARGB(255, 155, 155, 155))
                ], shape: BoxShape.circle, color: Color.fromARGB(255, 243, 104, 62)),
                child: const Icon(
                  IconData(0xf8bd, fontFamily: 'MaterialIcons'),
                  color: Colors.white,
                  size: 50.0,
                ),
              ), // Icono que deseas colocar debajo del texto
            ],
          ),
        ),
      ),
    );
  }
}
