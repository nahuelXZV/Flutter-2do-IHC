import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Ayudame'),
          ),
          body: Center(
            child: MyHomePage(),
          )),
    );
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
