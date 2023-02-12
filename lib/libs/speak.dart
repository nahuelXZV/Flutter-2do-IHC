import 'package:text_to_speech/text_to_speech.dart';

class SpeakClass {
  late TextToSpeech tts;

  final String _greet =
      'Hola, soy tu asistente virtual, incline el celular a la izquierda para saber su ubicacion o a la derecha para enviar su ubicacion a su contacto de emergencia';
  final String _noIdea = 'Lo siento no entendi, por favor puede repetir';

  SpeakClass() {
    tts = TextToSpeech();
    _handlerTextToSpeech();
    _ttsGreet();
  }

  void _handlerTextToSpeech() async {
    double volume = 1.0;
    tts.setVolume(volume);
    double rate = 0.7;
    tts.setRate(rate);
    double pitch = 1.0;
    tts.setPitch(pitch);
    String language = 'es-BO';
    tts.setLanguage(language);
  }

  void _ttsGreet() async {
    await tts.speak(_greet);
  }

  void ttsError() async {
    await tts.speak(_noIdea);
  }

  ttlSpeak(String transcription) async {
    await tts.speak(transcription);
  }
}
