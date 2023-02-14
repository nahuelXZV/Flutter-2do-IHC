import 'package:permission_handler/permission_handler.dart';
import 'package:speech_recognition/speech_recognition.dart';

class SpeechClass {
  late SpeechRecognition _speech;
  // ignore: unused_field
  bool _speechRecognitionAvailable = false; // cuando se detecta el micrófono
  bool _isListening = false; // cuando se está escuchando
  String transcription = ''; // lo que se está escuchando
  String currentText = ''; // lo que se está escuchando
  String _currentLocale = 'es-BO';
  int count = 1;
  bool isComplete = false;

  SpeechClass() {
    _activateSpeechRecognizer(); // activar el micrófono
  }

  startSpeech() {
    _speech
        .listen(locale: _currentLocale)
        .then((result) {})
        .catchError((error) {});
    transcription = '';
    isComplete = false;
  }

  stopSpeech() {
    _speech.stop().then((result) {
      print('Deteniendo Reconocimiento' + result.toString());
      transcription = result.toString();
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
    _speech.setErrorHandler(onError);
    _speech.activate().then((res) => _speechRecognitionAvailable = res);
  }

  //----- Speech related methods -----//
  void onSpeechAvailability(bool result) =>
      _speechRecognitionAvailable = result; // cuando se detecta el micrófono

  void onCurrentLocale(String text) {
    _currentLocale = text;
    print('current locale: $_currentLocale');
  }

  void onRecognitionStarted() {
    _isListening = true;
  }

  void onRecognitionResult(String text) {
    transcription = text;
    print('recognized text is- $transcription');
  }

  void onRecognitionComplete() async {
    if (count == 2) {
      print('Reconocimiento completo');
      _isListening = false; // se desactiva la escucha
      count = 1;
      isComplete = true;
    } else {
      count++;
    }
  }

  void onError() {
    isComplete = true;
    _isListening = false;
    transcription = '';
    count = 1;
  }
}
