import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'libs/openApp.dart';
import 'principal.dart';
import 'data/data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _initSeen();
  await initializeService();
  runApp(const MyApp());
}

_initSeen() async {
  final Data data = Data();
  bool seen = await data.getDataBool('seen');
  if (!seen) {
    await data.saveDataBool('seen', true);
  }
  print({
    'seenMain': await data.getDataBool('seen'),
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Ayudame',
        //  sacar el banner de debug
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const Principal());
  }
}

class MyHomePage extends StatelessWidget {
  final FlutterTts flutterTts = FlutterTts();
  MyHomePage({Key? key}) : super(key: key);

  speak(String text) async {
    await flutterTts.setLanguage("es-ES");
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
  }

  double dx = 200, dy = 200;
  double dx1 = 200, dy1 = 200;

  @override
  Widget build(BuildContext context) {
    speak(
        'Si quires saber tu ubicacion actual gira el celular a la derecha. Si quieres enviar tu ubicacion actual gira el celular a la izquierda');
    return Scaffold(
      body: StreamBuilder<GyroscopeEvent>(
        stream: SensorsPlatform.instance.gyroscopeEvents,
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            dx1 = dx1 + (snapshot.data!.y * 10);
            dy1 = dy1 + (snapshot.data!.x * 10);
            if (dx1.toInt() != dx.toInt() && dy1.toInt() != dy.toInt()) {
              if (dx1.toInt() > (dx.toInt() + 80) && dx1.toInt() != 100) {
                speak('derecha');
                dx = dx1;
                return Transform.translate(
                    offset: Offset(dx1, dy1),
                    child: const CircleAvatar(
                      radius: 20,
                    ));
              } else if (dx1.toInt() < (dx.toInt() - 80) &&
                  dx1.toInt() != 100) {
                speak('izquierda');
                dx = dx1;
                return Transform.translate(
                    offset: Offset(dx1, dy1),
                    child: const CircleAvatar(
                      radius: 20,
                    ));
              }
            }
          }
          return Transform.translate(
              offset: Offset(dx1, dy1),
              child: const CircleAvatar(
                radius: 20,
              ));
        },
      ),
    );
  }
}
