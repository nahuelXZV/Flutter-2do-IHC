// ignore_for_file: library_private_types_in_public_api
import 'package:ihc_maps/main.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'libs/speak.dart';
import 'libs/microphono.dart';
import 'data/data.dart';
import 'libs/form.dart';

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

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    openApp();
    _checkIfFirstTime();
    _getFormDone();
  }

  Future<void> _getFormDone() async {
    String bool = await _data.getData('formDone');
    print('formDonePrincipal: $bool');
    if (bool == 'true') {
      _tts = SpeakClass(1);
      // Aqui iria la logica del mover el celular hacelo en una funcion aparte en las carpetas libs, que solo llame a la funcion aqui
      //
    } else {
      _initForm();
    }
  }

  Future<void> _checkIfFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? seen = prefs.getBool('seen');
    if (!seen!) {
      // This is the first time the app is being run
      prefs.setBool('seen', true);
      prefs.setString('formDone', 'false');
      // Execute your code here
    }
  }

  _initForm() async {
    _form = FormClass();
    Future.delayed(const Duration(seconds: 7), () async {
      await _form.questions();
      _tts = SpeakClass(2);
    });
  }

  openApp() async {
    final Stream<AccelerometerEvent> stream =
        SensorsPlatform.instance.accelerometerEvents;
    stream.listen((AccelerometerEvent event) {
      // si el celular se mueve abrir esta aplicacion
      if (event.x > 0.5 || event.y > 0.5 || event.z > 0.5) {
        runApp(const MyApp());
      }
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
          backgroundColor: Color.fromRGBO(118, 74, 188, 1),
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: const [
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 300,
                  height: 300,
                  child: Microphono(onAnimated: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
