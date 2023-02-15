// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'libs/speak.dart';
import 'libs/microphono.dart';
import 'data/data.dart';
import 'libs/form.dart';
import 'libs/sendLocation.dart';

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

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _checkIfFirstTime();
  }

  Future<void> _checkIfFirstTime() async {
    bool seen = await _data.getDataBool('seen');
    if (seen) {
      _initForm();
      await _data.saveDataBool('seen', false);
    } else {
      _initForm();
      // _tts = SpeakClass(1);
      Future.delayed(const Duration(seconds: 10), () {});
      // logica del sensor

      // logica de la ubicacion

      // logica de enviar la ubicacion
      // _sendLocation = SendLocation('-17.778546', '-63.182126');
      // await _sendLocation.send();
    }
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
          backgroundColor: const Color.fromRGBO(118, 74, 188, 1),
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
