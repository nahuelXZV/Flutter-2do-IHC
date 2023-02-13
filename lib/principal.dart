// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
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
    // ignore: unrelated_type_equality_checks
    if (_data.getData('formDone') == 'true') {
      _tts = SpeakClass(1);
      // Aqui iria la logica del mover el celular hacelo en una funcion aparte en las carpetas libs, que solo llame a la funcion aqui
      //
      //

    } else {
      _initForm();
    }
  }

  _initForm() async {
    _form = FormClass();
    Future.delayed(const Duration(seconds: 8), () async {
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
