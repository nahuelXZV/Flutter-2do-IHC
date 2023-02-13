import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'libs/speak.dart';
import 'libs/microphono.dart';

class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  _SpeechToTextDemoState createState() => _SpeechToTextDemoState();
}

class _SpeechToTextDemoState extends State<Principal>
    with WidgetsBindingObserver {
  final TextEditingController _myController = TextEditingController();
  late SpeechRecognition _speech;
  final SpeakClass _tts = SpeakClass();

  // ignore: unused_field
  bool _speechRecognitionAvailable = false; // cuando se detecta el micrófono
  bool _isListening = false; // cuando se está escuchando
  String transcription = ''; // lo que se está escuchando
  String currentText = ''; // lo que se está escuchando
  String _currentLocale = 'es-BO';
  int count = 1;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _activateSpeechRecognizer(); // activar el micrófono
    Future.delayed(const Duration(seconds: 11), () {
      // esperar 3 segundos y activar el micrófono
      try {
        _startSpeechRecognition();
      } catch (e) {
        setState(() {
          _isListening = false;
        });
        _tts.ttsError();
      }
    });
  }

  _startSpeechRecognition() {
    _speech.listen(locale: _currentLocale).then((result) {});
  }

  _stopSpeechRecognition() {
    _speech.stop().then((result) {
      print('Deteniendo Reconocimiento' + result.toString());
      transcription = result.toString();
      setState(() {
        _isListening = false;
      });
    });
  }

  //----- Init methods -----//
  void _requestPermission() async {
    if (!await Permission.microphone.request().isGranted) {
      // You can request multiple permissions at once.
      Map<Permission, PermissionStatus> statuses =
          await [Permission.microphone].request();
      print(statuses[Permission.location]);
    }
  }

  void _activateSpeechRecognizer() {
    _requestPermission();
    _speech = SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setCurrentLocaleHandler(onCurrentLocale);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
    _speech
        .activate()
        .then((res) => setState(() => _speechRecognitionAvailable = res));
  }

  //----- Speech related methods -----//
  void onSpeechAvailability(bool result) => setState(() =>
      _speechRecognitionAvailable = result); // cuando se detecta el micrófono

  void onCurrentLocale(String text) {
    setState(() {
      _currentLocale = text;
      print('current locale: $_currentLocale');
    });
  }

  void onRecognitionStarted() {
    setState(() {
      _isListening = true;
    });
  }

  void onRecognitionResult(String text) {
    transcription = text;
    setState(() {
      print('recognized text is- $transcription');
    });
  }

  void onRecognitionComplete() {
    if (count == 2) {
      print('Reconocimiento completo');
      setState(() {
        _isListening = false; // se desactiva la escucha
      });
      _myController.text = transcription;
      _processRequest(transcription);
      count = 1;
    } else {
      count++;
    }
  }

  _processRequest(String transcription) async {
    await _tts.ttlSpeak(transcription);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _myController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        _stopSpeechRecognition();
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
              children: [
                const SizedBox(
                  height: 10,
                ),
                if (_isListening) ...[
                  const SizedBox(
                    width: 300,
                    height: 300,
                    child: Microphono(),
                  )
                ] else ...[
                  const SizedBox(
                    width: 300,
                    height: 300,
                    child: Microphono(onAnimated: false),
                  )
                ],
                Center(
                  child: TextField(
                    controller: _myController,
                    readOnly: true,
                    //focusNode: _nodeText1,
                    cursorColor: Colors.grey,
                    style: GoogleFonts.poppins(
                        textStyle: const TextStyle(fontSize: 15)),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintStyle: GoogleFonts.nunito(),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
